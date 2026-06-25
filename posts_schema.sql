-- 1. Create 'posts' table with strict constraints
CREATE TABLE public.posts (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    creator_id uuid NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    content text NOT NULL CHECK (char_length(content) <= 2000),
    image_url text CHECK (
        image_url IS NULL OR 
        image_url LIKE 'https://zrgtnzmvqtdvaragqgoj.supabase.co/storage/v1/object/public/posts/%'
    ),
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now()
);

-- 2. Create 'post_likes' table (M:N join table)
CREATE TABLE public.post_likes (
    post_id uuid NOT NULL REFERENCES public.posts(id) ON DELETE CASCADE,
    user_id uuid NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    created_at timestamptz NOT NULL DEFAULT now(),
    PRIMARY KEY (post_id, user_id)
);

-- 3. Create 'post_comments' table (Flat comments)
CREATE TABLE public.post_comments (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    post_id uuid NOT NULL REFERENCES public.posts(id) ON DELETE CASCADE,
    creator_id uuid NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    content text NOT NULL CHECK (char_length(content) <= 500),
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now()
);

-- Create indexes for performance
CREATE INDEX idx_posts_created_at_id ON public.posts(created_at DESC, id DESC);
CREATE INDEX idx_comments_post_created ON public.post_comments(post_id, created_at ASC);

-- 4. Timestamp Spoofing Prevention Triggers
CREATE OR REPLACE FUNCTION public.set_created_at_protection()
RETURNS TRIGGER AS $$
BEGIN
    NEW.created_at = COALESCE(NEW.created_at, now());
    IF TG_OP = 'INSERT' THEN
        NEW.created_at = now();
    ELSIF TG_OP = 'UPDATE' THEN
        NEW.created_at = OLD.created_at;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER posts_set_created_at
BEFORE INSERT OR UPDATE ON public.posts
FOR EACH ROW EXECUTE FUNCTION public.set_created_at_protection();

CREATE OR REPLACE TRIGGER comments_set_created_at
BEFORE INSERT OR UPDATE ON public.post_comments
FOR EACH ROW EXECUTE FUNCTION public.set_created_at_protection();

-- Enable RLS on all tables
ALTER TABLE public.posts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.post_likes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.post_comments ENABLE ROW LEVEL SECURITY;

-- 5. RLS Policies for 'posts'
CREATE POLICY "Anyone can view posts" ON public.posts
    FOR SELECT TO authenticated USING (true);

CREATE POLICY "Users can create posts" ON public.posts
    FOR INSERT TO authenticated WITH CHECK (auth.uid() = creator_id);

CREATE POLICY "Users can update own posts" ON public.posts
    FOR UPDATE TO authenticated 
    USING (auth.uid() = creator_id)
    WITH CHECK (auth.uid() = creator_id);

CREATE POLICY "Users can delete own posts" ON public.posts
    FOR DELETE TO authenticated USING (auth.uid() = creator_id);

-- 6. RLS Policies for 'post_likes'
CREATE POLICY "Anyone can view likes" ON public.post_likes
    FOR SELECT TO authenticated USING (true);

CREATE POLICY "Users can toggle own likes" ON public.post_likes
    FOR INSERT TO authenticated WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete own likes" ON public.post_likes
    FOR DELETE TO authenticated USING (auth.uid() = user_id);

-- 7. RLS Policies for 'post_comments'
CREATE POLICY "Anyone can view comments" ON public.post_comments
    FOR SELECT TO authenticated USING (true);

CREATE POLICY "Users can add comments" ON public.post_comments
    FOR INSERT TO authenticated WITH CHECK (auth.uid() = creator_id);

CREATE POLICY "Users can delete own comments" ON public.post_comments
    FOR DELETE TO authenticated USING (auth.uid() = creator_id);

-- 8. Configure Storage Bucket for 'posts'
INSERT INTO storage.buckets (id, name, public) VALUES ('posts', 'posts', true)
ON CONFLICT (id) DO NOTHING;

-- Enforce Bucket-Level Restrictions (Images only, max 5MB)
UPDATE storage.buckets 
SET 
  allowed_mime_types = ARRAY['image/jpeg', 'image/png', 'image/webp']::text[],
  file_size_limit = 5242880 -- 5MB in bytes
WHERE id = 'posts';

-- Storage Policies with Strict Ownership & Path Security
CREATE POLICY "Allow public read access to posts storage"
ON storage.objects FOR SELECT TO public USING (bucket_id = 'posts'::text);

CREATE POLICY "Allow authenticated users to upload posts images to own folder"
ON storage.objects FOR INSERT TO authenticated 
WITH CHECK (
    bucket_id = 'posts'::text AND 
    (storage.foldername(name))[1] = auth.uid()::text
);

CREATE POLICY "Allow authenticated users to delete own posts images"
ON storage.objects FOR DELETE TO authenticated 
USING (
    bucket_id = 'posts'::text AND 
    owner = auth.uid()
);
