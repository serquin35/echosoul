# EchoSoul — Guía Proactividad Workflows

## Orden de importación
```
1. echosoul-proactividad-daily-checkin.json
2. echosoul-proactividad-smart-nudge.json
3. echosoul-proactividad-mood-insights.json
```

## SQL previo requerido (ejecutar ANTES de activar)

```sql
-- Añadir columnas necesarias a profiles
ALTER TABLE profiles
  ADD COLUMN IF NOT EXISTS email      TEXT,
  ADD COLUMN IF NOT EXISTS platform   TEXT DEFAULT 'web',
  ADD COLUMN IF NOT EXISTS fcm_token  TEXT;

-- Índice para smart-nudge (consulta inactividad)
CREATE INDEX IF NOT EXISTS idx_messages_user_created
  ON messages (user_id, created_at DESC);

CREATE INDEX IF NOT EXISTS idx_checkins_user_created
  ON checkins (user_id, created_at DESC);
```

## Actualizar new-user-welcome

Añade `email` y `platform` al body del INSERT a profiles:
```json
{
  "id":           "...",
  "display_name": "...",
  "email":        "{{ $('Webhook New User').first().json.body.email }}",
  "platform":     "{{ $('Webhook New User').first().json.body.platform ?? 'web' }}",
  "timezone":     "...",
  "language":     "es",
  "onboarding_completed": false,
  "avatar_url":   null
}
```

## Variables adicionales
| Variable | Descripción |
|---|---|
| `FCM_SERVER_KEY` | Firebase → Project Settings → Cloud Messaging → Server Key |

Reemplaza `YOUR_FCM_SERVER_KEY` en los nodos FCM de los 3 workflows.
Reemplaza `YOUR_GMAIL_CREDENTIAL_ID` con el ID de tu credencial Gmail en n8n.

## Credenciales n8n

Los headers de Supabase usan `$credentials.EchoSoulSupabase.value` y los de Claude
usan `$credentials.EchoSoulClaude.value`. Si tus credenciales tienen nombres distintos,
actualiza esos valores en todos los nodos HTTP.

## Trigger de mood-insights desde Flutter

Llama al webhook al guardar una entrada de mood:
```dart
await http.post(
  Uri.parse('https://n8n.cheosdesign.info/webhook/mood-entry'),
  headers: {'Content-Type': 'application/json'},
  body: jsonEncode({
    'user_id':    supabase.auth.currentUser!.id,
    'mood_score': selectedScore,  // int
    'note':       noteController.text,
  }),
);
```

## Escala de mood_score

El análisis de patrón en mood-insights asume escala **1-10** donde ≤3 = bajo.
Si tu app usa otra escala (ej: 1-5), ajusta el umbral en el nodo
**Analyze mood pattern** cambiando `s <= 3` por el valor apropiado.

## Frecuencias de los crons

| Workflow | Cron | Frecuencia |
|---|---|---|
| daily-checkin | `0 9 * * *` | Diario a las 9:00 AM |
| smart-nudge | `0 */6 * * *` | Cada 6 horas |

## Checkins table — triggered_by values

| Valor | Origen |
|---|---|
| `daily-checkin` | Mensaje matutino diario |
| `smart-nudge` | Reactivación por inactividad |
| `mood-insight` | Respuesta a patrón de mood bajo |
