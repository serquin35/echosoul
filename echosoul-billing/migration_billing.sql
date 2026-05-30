-- ============================================================
-- EchoSoul — Billing Migration (Paddle Hybrid)
-- ============================================================

-- 1. Tabla de suscripciones (webhooks de Paddle)
CREATE TABLE IF NOT EXISTS subscriptions (
  id              UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id         UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  provider        TEXT NOT NULL CHECK (provider IN ('paddle', 'google_play')),
  provider_sub_id TEXT,
  status          TEXT NOT NULL DEFAULT 'active',
  plan_id         TEXT,
  expires_at      TIMESTAMPTZ,
  raw_event       JSONB,
  created_at      TIMESTAMPTZ DEFAULT NOW(),
  updated_at      TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, provider)
);

CREATE INDEX IF NOT EXISTS idx_subscriptions_user_provider
  ON subscriptions (user_id, provider);
CREATE INDEX IF NOT EXISTS idx_subscriptions_provider_sub_id
  ON subscriptions (provider_sub_id) WHERE provider_sub_id IS NOT NULL;

-- 2. Tabla de planes (caché rápida para Flutter)
CREATE TABLE IF NOT EXISTS user_plans (
  user_id         UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  plan            TEXT NOT NULL DEFAULT 'free',
  daily_limit     INT NOT NULL DEFAULT 20,
  messages_used   INT NOT NULL DEFAULT 0,
  last_reset_date DATE DEFAULT CURRENT_DATE,
  updated_at      TIMESTAMPTZ DEFAULT NOW()
);

-- 3. Trigger: crear user_plan al registrarse
CREATE OR REPLACE FUNCTION handle_new_user_plan()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.user_plans (user_id, plan, daily_limit, messages_used, last_reset_date)
  VALUES (NEW.id, 'free', 20, 0, CURRENT_DATE)
  ON CONFLICT (user_id) DO NOTHING;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS on_auth_user_created_plan ON auth.users;
CREATE TRIGGER on_auth_user_created_plan
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION handle_new_user_plan();

-- 4. RLS
ALTER TABLE user_plans ENABLE ROW LEVEL SECURITY;
ALTER TABLE subscriptions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "users can view own plan"
  ON user_plans FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "users can view own subscriptions"
  ON subscriptions FOR SELECT
  USING (auth.uid() = user_id);

-- 5. Función para incrementar contador de mensajes
CREATE OR REPLACE FUNCTION increment_messages_used(p_user_id UUID)
RETURNS void AS $$
BEGIN
  UPDATE user_plans
  SET messages_used = messages_used + 1,
      updated_at = NOW()
  WHERE user_id = p_user_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
