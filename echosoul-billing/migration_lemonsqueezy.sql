-- ============================================================
-- EchoSoul — Migration for Lemon Squeezy Integration
-- ============================================================

-- 1. Modificar la restricción CHECK de la tabla subscriptions para incluir lemonsqueezy
ALTER TABLE public.subscriptions DROP CONSTRAINT IF EXISTS subscriptions_provider_check;
ALTER TABLE public.subscriptions ADD CONSTRAINT subscriptions_provider_check 
  CHECK (provider IN ('paddle', 'google_play', 'lemonsqueezy'));

-- 2. Asegurar índices de búsqueda rápida para lemonsqueezy
CREATE INDEX IF NOT EXISTS idx_subscriptions_lemonsqueezy 
  ON public.subscriptions (provider_sub_id) WHERE provider = 'lemonsqueezy';
