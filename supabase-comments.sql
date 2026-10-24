CREATE TABLE IF NOT EXISTS public.game_comments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    game_id BIGINT NOT NULL REFERENCES public.games(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    author_name TEXT NOT NULL,
    author_email TEXT NOT NULL,
    content TEXT NOT NULL CHECK (char_length(content) BETWEEN 1 AND 2000),
    author_rating SMALLINT CHECK (author_rating BETWEEN 1 AND 5),
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

ALTER TABLE public.game_comments
    ADD COLUMN IF NOT EXISTS author_rating SMALLINT
    CHECK (author_rating BETWEEN 1 AND 5);

CREATE INDEX IF NOT EXISTS game_comments_game_created_idx
    ON public.game_comments (game_id, created_at, id);

ALTER TABLE public.game_comments ENABLE ROW LEVEL SECURITY;

GRANT SELECT ON public.game_comments TO anon, authenticated;
GRANT INSERT ON public.game_comments TO authenticated;
GRANT DELETE ON public.game_comments TO authenticated;
REVOKE UPDATE ON public.game_comments FROM anon, authenticated;
GRANT UPDATE (author_rating) ON public.game_comments TO authenticated;

CREATE OR REPLACE FUNCTION public.set_game_comment_author()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $$
DECLARE
    account_email TEXT;
    account_name TEXT;
BEGIN
    IF auth.uid() IS NULL OR NEW.user_id IS DISTINCT FROM auth.uid() THEN
        RAISE EXCEPTION 'You can only post as your signed-in account';
    END IF;

    SELECT users.email,
           COALESCE(NULLIF(users.raw_user_meta_data ->> 'full_name', ''), users.email)
    INTO account_email, account_name
    FROM auth.users AS users
    WHERE users.id = auth.uid();

    IF account_email IS NULL THEN
        RAISE EXCEPTION 'Could not find the signed-in account';
    END IF;

    NEW.author_email := account_email;
    NEW.author_name := account_name;
    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS set_game_comment_author ON public.game_comments;
CREATE TRIGGER set_game_comment_author
    BEFORE INSERT ON public.game_comments
    FOR EACH ROW
    EXECUTE FUNCTION public.set_game_comment_author();

DROP POLICY IF EXISTS "Anyone can read game comments" ON public.game_comments;
CREATE POLICY "Anyone can read game comments"
    ON public.game_comments
    FOR SELECT
    USING (true);

DROP POLICY IF EXISTS "Authenticated users can post as themselves" ON public.game_comments;
CREATE POLICY "Authenticated users can post as themselves"
    ON public.game_comments
    FOR INSERT
    TO authenticated
    WITH CHECK (
        auth.uid() = user_id
        AND char_length(trim(content)) BETWEEN 1 AND 2000
    );

DROP POLICY IF EXISTS "Users can delete their own game comments" ON public.game_comments;
CREATE POLICY "Users can delete their own game comments"
    ON public.game_comments
    FOR DELETE
    TO authenticated
    USING (auth.uid() = user_id);

DROP FUNCTION IF EXISTS public.get_game_comment_vote_summary(UUID[]);
DROP TABLE IF EXISTS public.game_comment_votes;

DROP POLICY IF EXISTS "Users can rate their own comments" ON public.game_comments;
CREATE POLICY "Users can rate their own comments"
    ON public.game_comments
    FOR UPDATE
    TO authenticated
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);
