# EchoSoul — Guía de Instalación de Workflows n8n

## Orden de importación

Importa los workflows en este orden para que las referencias de webhook funcionen:

1. `echosoul-crisis-detector.json`
2. `echosoul-memory-extractor.json`
3. `echosoul-chat-proxy.json`

## Paso 1 — Variables n8n

En tu instancia n8n → **Settings → Variables**, crea estas variables:

| Variable                 | Valor de ejemplo                              | Descripción                         |
|--------------------------|-----------------------------------------------|-------------------------------------|
| `SUPABASE_URL`           | `https://abcxyz.supabase.co`                  | URL de tu proyecto Supabase         |
| `SUPABASE_SERVICE_KEY`   | `eyJh...`                                     | Service Role Key (no la anon key)   |
| `CLAUDE_API_KEY`         | `sk-ant-...`                                  | API Key de Anthropic                |
| `N8N_BASE_URL`           | `https://n8n.tudominio.com`                   | URL pública de tu n8n               |
| `UPGRADE_URL`            | `https://echosoul.app/pricing`                | URL de tu página de precios         |
| `ADMIN_ALERT_WEBHOOK`    | `https://hooks.slack.com/services/...`        | Slack Incoming Webhook para alertas |

## Paso 2 — Tablas Supabase

Ejecuta este SQL en el SQL Editor de Supabase:

```sql
-- Historial de mensajes de chat
CREATE TABLE messages (
  id          UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id     UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  session_id  UUID NOT NULL,
  role        TEXT NOT NULL CHECK (role IN ('user', 'assistant')),
  content     TEXT NOT NULL,
  created_at  TIMESTAMPTZ DEFAULT NOW()
);
CREATE INDEX ON messages (session_id, created_at DESC);
CREATE INDEX ON messages (user_id, created_at DESC);

-- Memorias a largo plazo
CREATE TABLE user_memories (
  id           UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id      UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  content      TEXT NOT NULL,
  category     TEXT DEFAULT 'personal',
  importance   INTEGER DEFAULT 3 CHECK (importance BETWEEN 1 AND 5),
  content_hash TEXT UNIQUE NOT NULL,
  updated_at   TIMESTAMPTZ DEFAULT NOW(),
  created_at   TIMESTAMPTZ DEFAULT NOW()
);
CREATE INDEX ON user_memories (user_id, importance DESC, updated_at DESC);

-- Eventos de crisis (append-only, sin texto del mensaje)
CREATE TABLE crisis_events (
  id         UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id    UUID NOT NULL REFERENCES auth.users(id),
  level      TEXT NOT NULL CHECK (level IN ('low', 'medium', 'high')),
  msg_hash   TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);
CREATE INDEX ON crisis_events (user_id, created_at DESC);

-- Plan del usuario (para límites de uso)
CREATE TABLE user_plans (
  user_id      UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  plan         TEXT DEFAULT 'free' CHECK (plan IN ('free', 'premium')),
  daily_limit  INTEGER DEFAULT 20,
  updated_at   TIMESTAMPTZ DEFAULT NOW()
);
```

## Paso 3 — Payload que tu app Flutter debe enviar

```dart
// En tu servicio de chat en Flutter
final response = await http.post(
  Uri.parse('$n8nBaseUrl/webhook/chat'),
  headers: {'Content-Type': 'application/json'},
  body: jsonEncode({
    'user_id':    supabase.auth.currentUser!.id,
    'session_id': currentSessionId,  // UUID de la sesión actual
    'message':    userMessage,
    'plan_limit': userPlan.dailyLimit,  // desde tu tabla user_plans
  }),
);
final data = jsonDecode(response.body);
// data['reply']      → texto de respuesta de EchoSoul
// data['is_crisis']  → bool, para mostrar recursos si true
// data['tokens_used'] → para telemetría
```

## Paso 4 — Activar workflows

1. Importa cada JSON: **Workflows → Import from file**
2. Entra a cada workflow y haz clic en **Activate** (toggle superior derecho)
3. Los webhooks estarán disponibles en:
   - `POST https://n8n.tudominio.com/webhook/chat`
   - `POST https://n8n.tudominio.com/webhook/extract-memory`
   - `POST https://n8n.tudominio.com/webhook/crisis-check`

## Notas importantes

- **crisis-detector** y **memory-extractor** son llamados internamente por **chat-proxy**.
  Tu app Flutter solo llama a `/webhook/chat`.
- El modelo de extracción usa `claude-haiku-4-5` (económico) para reducir costes.
  El chat principal usa `claude-sonnet-4-6`.
- La alerta de admin en crisis-detector usa un Slack Incoming Webhook.
  Puedes cambiarlo por un nodo Gmail si prefieres email.
- El **fire & forget** de memory-extractor funciona porque el nodo
  `Respond 200 Immediately` está al inicio del flujo.
  n8n responde al caller y sigue ejecutando en background.
