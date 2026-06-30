-- 1. Create Enum
CREATE TYPE public.notification_type AS ENUM ('comment', 'like', 'event_update');

-- 2. Create user_tokens table
CREATE TABLE public.user_tokens (
    user_id uuid NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    fcm_token text PRIMARY KEY,
    device_platform text NOT NULL CHECK (device_platform IN ('android', 'ios', 'web')),
    updated_at timestamptz NOT NULL DEFAULT now()
);

-- 3. Create notifications table
CREATE TABLE public.notifications (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id uuid NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    actor_id uuid REFERENCES public.profiles(id) ON DELETE CASCADE,
    type public.notification_type NOT NULL,
    target_id uuid NOT NULL,
    title text NOT NULL,
    body text NOT NULL,
    is_read boolean NOT NULL DEFAULT false,
    created_at timestamptz NOT NULL DEFAULT now()
);

-- 4. Enable RLS
ALTER TABLE public.user_tokens ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;

-- 5. Create RLS Policies
CREATE POLICY "Users can manage their own tokens" ON public.user_tokens
    FOR ALL TO authenticated USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can view their own notifications" ON public.notifications
    FOR SELECT TO authenticated USING (auth.uid() = user_id);

CREATE POLICY "Users can update their own notifications" ON public.notifications
    FOR UPDATE TO authenticated USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);

-- 6. Trigger for created_at protection
CREATE OR REPLACE TRIGGER notifications_set_created_at
BEFORE INSERT OR UPDATE ON public.notifications
FOR EACH ROW EXECUTE FUNCTION public.set_created_at_protection();

-- 7. Trigger for post comments (Notify post owner)
CREATE OR REPLACE FUNCTION public.handle_comment_added()
RETURNS TRIGGER AS $$
DECLARE
    v_post_owner_id uuid;
    v_commenter_name text;
    v_post_content text;
BEGIN
    -- Find post owner
    SELECT creator_id, content INTO v_post_owner_id, v_post_content FROM public.posts WHERE id = NEW.post_id;
    
    -- Only notify if commenter is not the post owner
    IF NEW.creator_id <> v_post_owner_id THEN
        -- Fetch commenter full name
        SELECT full_name INTO v_commenter_name FROM public.profiles WHERE id = NEW.creator_id;
        
        INSERT INTO public.notifications (user_id, actor_id, type, target_id, title, body)
        VALUES (
            v_post_owner_id,
            NEW.creator_id,
            'comment',
            NEW.post_id,
            'تعليق جديد',
            COALESCE(v_commenter_name, 'شخص ما') || ' علّق على منشورك: "' || substring(NEW.content from 1 for 40) || '"'
        );
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE TRIGGER trg_comment_added
AFTER INSERT ON public.post_comments
FOR EACH ROW EXECUTE FUNCTION public.handle_comment_added();

-- 8. Trigger for post likes (Notify post owner with Milestone Logic)
CREATE OR REPLACE FUNCTION public.handle_post_liked()
RETURNS TRIGGER AS $$
DECLARE
    v_post_owner_id uuid;
    v_liker_name text;
    v_like_count int;
    v_milestones int[] := ARRAY[1, 5, 10, 20, 50, 100, 200, 500, 1000];
BEGIN
    -- Find post owner
    SELECT creator_id INTO v_post_owner_id FROM public.posts WHERE id = NEW.post_id;
    
    -- Only notify if the liker is not the post owner
    IF NEW.user_id <> v_post_owner_id THEN
        -- Count total likes for this post
        SELECT count(*) INTO v_like_count FROM public.post_likes WHERE post_id = NEW.post_id;
        
        -- Check if count is a milestone
        IF v_like_count = ANY(v_milestones) THEN
            SELECT full_name INTO v_liker_name FROM public.profiles WHERE id = NEW.user_id;
            
            -- If count is 1, customize text. Otherwise, show milestone text
            IF v_like_count = 1 THEN
                INSERT INTO public.notifications (user_id, actor_id, type, target_id, title, body)
                VALUES (
                    v_post_owner_id,
                    NEW.user_id,
                    'like',
                    NEW.post_id,
                    'إعجاب جديد',
                    COALESCE(v_liker_name, 'شخص ما') || ' أعجب بمنشورك.'
                );
            ELSE
                INSERT INTO public.notifications (user_id, actor_id, type, target_id, title, body)
                VALUES (
                    v_post_owner_id,
                    NEW.user_id,
                    'like',
                    NEW.post_id,
                    'تفاعل متزايد',
                    'حصل منشورك على ' || v_like_count || ' إعجاباً!'
                );
            END IF;
        END IF;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE TRIGGER trg_post_liked
AFTER INSERT ON public.post_likes
FOR EACH ROW EXECUTE FUNCTION public.handle_post_liked();

-- 9. Trigger for event updates (Notify users who saved the event, exclude creator)
CREATE OR REPLACE FUNCTION public.handle_event_updated()
RETURNS TRIGGER AS $$
DECLARE
    v_record record;
BEGIN
    FOR v_record IN 
        SELECT user_id 
        FROM public.saved_events 
        WHERE event_id = NEW.id AND user_id <> NEW.creator_id
    LOOP
        INSERT INTO public.notifications (user_id, actor_id, type, target_id, title, body)
        VALUES (
            v_record.user_id,
            NEW.creator_id,
            'event_update',
            NEW.id,
            'تحديث في الفعالية',
            'تم تحديث تفاصيل الفعالية: "' || NEW.title || '"'
        );
    END LOOP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE TRIGGER trg_event_updated
AFTER UPDATE OF title, description, start_date, end_date, city, location_name, cover_url, status
ON public.events
FOR EACH ROW
EXECUTE FUNCTION public.handle_event_updated();
