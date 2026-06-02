-- Migration: Add custom_daily_limit to user_preferences
ALTER TABLE public.user_preferences
ADD COLUMN custom_daily_limit INTEGER DEFAULT NULL;

COMMENT ON COLUMN public.user_preferences.custom_daily_limit IS 'Límite diario personalizado definido por el usuario. NULL = usar límite del plan.';

-- Update mood_entries constraint from 1-5 to 1-10 to match Flutter app
ALTER TABLE public.mood_entries DROP CONSTRAINT IF EXISTS mood_entries_mood_score_check;
ALTER TABLE public.mood_entries ADD CONSTRAINT mood_entries_mood_score_check
  CHECK (mood_score >= 1 AND mood_score <= 10);
