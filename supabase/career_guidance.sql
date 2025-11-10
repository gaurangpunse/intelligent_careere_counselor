-- Create career_guidance table for storing assessment results and recommendations
CREATE TABLE public.career_guidance (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL,
  prompt text NOT NULL,
  response text NOT NULL,
  assessment_data jsonb NOT NULL DEFAULT '{}'::jsonb,
  created_at timestamp with time zone NULL DEFAULT now(),
  updated_at timestamp with time zone NULL DEFAULT now(),
  CONSTRAINT career_guidance_pkey PRIMARY KEY (id),
  CONSTRAINT career_guidance_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users (id) ON DELETE CASCADE
) TABLESPACE pg_default;

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_career_guidance_user_id ON public.career_guidance USING btree (user_id) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS idx_career_guidance_created_at ON public.career_guidance USING btree (created_at DESC) TABLESPACE pg_default;

-- Enable Row Level Security (RLS)
ALTER TABLE public.career_guidance ENABLE ROW LEVEL SECURITY;

-- Create policy for users to view their own career guidance
CREATE POLICY "Users can view their own career guidance" ON public.career_guidance
    FOR SELECT USING (auth.uid() = user_id);

-- Create policy for users to insert their own career guidance
CREATE POLICY "Users can insert their own career guidance" ON public.career_guidance
    FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Create policy for users to update their own career guidance
CREATE POLICY "Users can update their own career guidance" ON public.career_guidance
    FOR UPDATE USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);

-- Create policy for users to delete their own career guidance
CREATE POLICY "Users can delete their own career guidance" ON public.career_guidance
    FOR DELETE USING (auth.uid() = user_id);

-- Create trigger to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_career_guidance_updated_at
    BEFORE UPDATE ON career_guidance
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();