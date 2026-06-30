import { createClient } from "jsr:@supabase/supabase-js@2";

// CORS Headers
const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

// RS256 signing for Google OAuth2 token exchange
async function getAccessToken(serviceAccount: any): Promise<string> {
  const pemHeader = "-----BEGIN PRIVATE KEY-----";
  const pemFooter = "-----END PRIVATE KEY-----";
  
  // Format private key properly
  const privateKeyPem = serviceAccount.private_key;
  const pemContents = privateKeyPem
    .replace(pemHeader, "")
    .replace(pemFooter, "")
    .replace(/\s/g, "");
    
  const binaryDerString = atob(pemContents);
  const binaryDer = new Uint8Array(binaryDerString.length);
  for (let i = 0; i < binaryDerString.length; i++) {
    binaryDer[i] = binaryDerString.charCodeAt(i);
  }

  const key = await crypto.subtle.importKey(
    "pkcs8",
    binaryDer,
    {
      name: "RSASSA-PKCS1-v1_5",
      hash: "SHA-256",
    },
    false,
    ["sign"]
  );

  const header = btoa(JSON.stringify({ alg: "RS256", typ: "JWT" }))
    .replace(/=/g, "")
    .replace(/\+/g, "-")
    .replace(/\//g, "_");

  const now = Math.floor(Date.now() / 1000);
  const payload = btoa(
    JSON.stringify({
      iss: serviceAccount.client_email,
      scope: "https://www.googleapis.com/auth/firebase.messaging",
      aud: "https://oauth2.googleapis.com/token",
      exp: now + 3600,
      iat: now,
    })
  )
    .replace(/=/g, "")
    .replace(/\+/g, "-")
    .replace(/\//g, "_");

  const data = new TextEncoder().encode(`${header}.${payload}`);
  const signatureBuffer = await crypto.subtle.sign(
    "RSASSA-PKCS1-v1_5",
    key,
    data
  );
  
  const signatureArray = new Uint8Array(signatureBuffer);
  const signature = btoa(String.fromCharCode(...signatureArray))
    .replace(/=/g, "")
    .replace(/\+/g, "-")
    .replace(/\//g, "_");

  const jwt = `${header}.${payload}.${signature}`;

  const response = await fetch("https://oauth2.googleapis.com/token", {
    method: "POST",
    headers: {
      "Content-Type": "application/x-www-form-urlencoded",
    },
    body: new URLSearchParams({
      grant_type: "urn:ietf:params:oauth:grant-type:jwt-bearer",
      assertion: jwt,
    }),
  });

  const resBody = await response.json();
  if (!response.ok) {
    throw new Error(`Failed to get OAuth token: ${JSON.stringify(resBody)}`);
  }
  return resBody.access_token;
}

Deno.serve(async (req) => {
  // Handle CORS preflight
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    // 1. Parse webhook payload
    const payload = await req.json();
    console.log("Received database webhook payload:", JSON.stringify(payload));

    const { type, table, record } = payload;
    
    // Validate that it's a notification insert event
    if (table !== "notifications" || type !== "INSERT") {
      return new Response(
        JSON.stringify({ message: "Ignored event. Only notifications INSERT is processed." }),
        { status: 200, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    if (!record) {
      return new Response(
        JSON.stringify({ error: "Missing record data." }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    // 2. Initialize Supabase Client with Service Role Key to bypass RLS
    const supabaseUrl = Deno.env.get("SUPABASE_URL") || "";
    const supabaseServiceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") || "";
    const supabase = createClient(supabaseUrl, supabaseServiceKey);

    // 3. Fetch recipient tokens
    const { data: userTokens, error: tokenError } = await supabase
      .from("user_tokens")
      .select("fcm_token, device_platform")
      .eq("user_id", record.user_id);

    if (tokenError) {
      console.error("Error fetching FCM tokens:", tokenError);
      return new Response(
        JSON.stringify({ error: "Database error fetching user tokens" }),
        { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    if (!userTokens || userTokens.length === 0) {
      console.log(`No FCM tokens found for user_id: ${record.user_id}`);
      return new Response(
        JSON.stringify({ message: "No tokens registered for user." }),
        { status: 200, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    // 4. Retrieve Firebase Service Account
    const serviceAccountStr = Deno.env.get("FIREBASE_SERVICE_ACCOUNT");
    if (!serviceAccountStr) {
      console.error("FIREBASE_SERVICE_ACCOUNT environment variable is not set.");
      return new Response(
        JSON.stringify({ error: "Firebase Service Account secret is not configured." }),
        { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }
    
    const serviceAccount = JSON.parse(serviceAccountStr);

    // 5. Get Google Access Token
    const accessToken = await getAccessToken(serviceAccount);

    // 6. Send push notifications to all registered tokens
    const dispatchPromises = userTokens.map(async (t) => {
      const fcmUrl = `https://fcm.googleapis.com/v1/projects/${serviceAccount.project_id}/messages:send`;
      const fcmPayload = {
        message: {
          token: t.fcm_token,
          notification: {
            title: record.title,
            body: record.body,
          },
          data: {
            type: String(record.type),
            target_id: String(record.target_id),
          },
          android: {
            priority: "high",
            notification: {
              click_action: "FLUTTER_NOTIFICATION_CLICK",
              sound: "default",
            },
          },
          apns: {
            headers: {
              "apns-priority": "10",
            },
            payload: {
              aps: {
                category: "FLUTTER_NOTIFICATION_CLICK",
                sound: "default",
                badge: 1,
              },
            },
          },
        },
      };

      try {
        const res = await fetch(fcmUrl, {
          method: "POST",
          headers: {
            Authorization: `Bearer ${accessToken}`,
            "Content-Type": "application/json",
          },
          body: JSON.stringify(fcmPayload),
        });

        const resData = await res.json();
        
        if (!res.ok) {
          console.error(`FCM send failed for token: ${t.fcm_token}`, JSON.stringify(resData));
          
          // Identify invalid/expired tokens
          const errorCode = resData.error?.status;
          const errorMessage = resData.error?.message || "";
          
          if (
            errorCode === "UNREGISTERED" ||
            errorCode === "INVALID_ARGUMENT" ||
            errorMessage.includes("Requested entity was not found")
          ) {
            return { token: t.fcm_token, cleanup: true };
          }
        }
        return { token: t.fcm_token, cleanup: false };
      } catch (err) {
        console.error(`Network error sending to FCM for token ${t.fcm_token}:`, err);
        return { token: t.fcm_token, cleanup: false };
      }
    });

    const results = await Promise.all(dispatchPromises);
    const tokensToCleanup = results.filter((r) => r.cleanup).map((r) => r.token);

    // 7. Non-blocking asynchronous cleanup of invalid/expired tokens
    if (tokensToCleanup.length > 0) {
      console.log(`Scheduling async cleanup of ${tokensToCleanup.length} invalid tokens...`);
      supabase
        .from("user_tokens")
        .delete()
        .in("fcm_token", tokensToCleanup)
        .then(({ error }) => {
          if (error) {
            console.error("Async token cleanup failed:", error);
          } else {
            console.log(`Async token cleanup successful for: ${tokensToCleanup.join(", ")}`);
          }
        });
    }

    return new Response(
      JSON.stringify({
        message: `Successfully dispatched notifications to ${userTokens.length - tokensToCleanup.length} devices.`,
        dispatched: userTokens.length,
        failed: tokensToCleanup.length,
      }),
      { status: 200, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );

  } catch (error: any) {
    console.error("Error processing webhook:", error);
    return new Response(
      JSON.stringify({ error: error.message }),
      { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  }
});
