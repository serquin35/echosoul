# EchoSoul — Guía de Onboarding Workflows

## Orden de importación

```
1. echosoul-onboarding-new-user-welcome.json
2. echosoul-onboarding-drip.json
```

---

## Variables n8n adicionales

Añade en Dokploy → Environment (o docker-compose):

| Variable | Descripción |
|---|---|
| `APP_URL` | URL pública de tu app, ej: `https://echosoul.app` |
| `FCM_SERVER_KEY` | Server Key de Firebase (Android push) · Consola Firebase → Project Settings → Cloud Messaging |

Las variables `SUPABASE_URL`, `SUPABASE_SERVICE_KEY` y `CLAUDE_API_KEY` ya las tienes del setup anterior.

---

## Tablas Supabase nuevas

Ejecuta en el SQL Editor de Supabase:

```sql
-- Perfiles de usuario
CREATE TABLE IF NOT EXISTS user_profiles (
  user_id      UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  display_name TEXT DEFAULT '',
  email        TEXT,
  platform     TEXT DEFAULT 'web' CHECK (platform IN ('web','android','ios')),
  fcm_token    TEXT,
  timezone     TEXT DEFAULT 'Europe/Madrid',
  created_at   TIMESTAMPTZ DEFAULT NOW()
);

-- Planes de usuario (si no la creaste con el grupo Chat & IA)
CREATE TABLE IF NOT EXISTS user_plans (
  user_id      UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  plan         TEXT DEFAULT 'free' CHECK (plan IN ('free','premium')),
  daily_limit  INTEGER DEFAULT 20,
  updated_at   TIMESTAMPTZ DEFAULT NOW()
);

-- State machine de onboarding
CREATE TABLE user_onboarding (
  user_id      UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  step         INTEGER DEFAULT 1,
  platform     TEXT DEFAULT 'web',
  next_step_at TIMESTAMPTZ DEFAULT NOW() + INTERVAL '24 hours',
  completed    BOOLEAN DEFAULT FALSE,
  created_at   TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX ON user_onboarding (completed, next_step_at)
  WHERE completed = false;
```

---

## Configurar Gmail en n8n

1. En n8n: **Credentials → New → Gmail OAuth2**
2. Sigue el wizard (necesitas un proyecto en Google Cloud Console con Gmail API habilitada)
3. Una vez creada, abre el workflow `new-user-welcome` y en el nodo **Send welcome email** selecciona tu credencial
4. Haz lo mismo en `onboarding-drip` → **Send drip email**
5. Reemplaza `YOUR_GMAIL_CREDENTIAL_ID` si lo ves en el JSON

---

## Integración Flutter — llamar al webhook tras registro

Añade esta llamada en tu `AuthService`, justo después del `signUp` exitoso:

```dart
Future<void> triggerOnboarding({
  required User user,
  required String displayName,
  required String platform,   // 'web' | 'android'
  String? fcmToken,
}) async {
  try {
    await http.post(
      Uri.parse('$n8nBaseUrl/webhook/new-user'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'user_id':      user.id,
        'email':        user.email,
        'display_name': displayName,
        'platform':     platform,
        'fcm_token':    fcmToken,
        'timezone':     DateTime.now().timeZoneName,
      }),
    );
  } catch (e) {
    // No bloques el registro si el onboarding falla
    debugPrint('Onboarding webhook error: $e');
  }
}
```

> **Importante**: El `try/catch` es deliberado. Si n8n está caído o hay un error de red,
> el registro del usuario **no debe fallar** por ello. El onboarding es un proceso de
> mejora de experiencia, no un requisito crítico.

---

## Lógica del drip — resumen de pasos

| Paso | Se envía | Cuándo | Canal |
|------|----------|--------|-------|
| 0 | Email de bienvenida | Inmediato tras registro | Email |
| 1 | "¿Cómo fue tu primer día?" | +24h | Email / FCM |
| 2 | Intro al Mood Tracker | +72h (día 3) | Email / FCM |
| 3 | Soft upsell Premium | +120h (día 5) | Email / FCM |

Después del paso 3, el campo `completed = true` y el cron ignora ese usuario para siempre.

---

## Cómo añadir un paso nuevo

1. Abre el workflow `onboarding-drip`
2. Edita el nodo **Build step content**
3. Añade una nueva entrada al objeto `STEPS`:

```javascript
4: {
  subject:    `Tu nuevo mensaje ✨`,
  body:       `<div>...</div>`,
  push_title: '...',
  push_body:  '...',
  delay_h:    null  // null = último paso, completed = true
}
```

4. Cambia el `delay_h` del paso anterior de `null` a las horas que quieras esperar

No necesitas tocar ningún otro nodo.

---

## Troubleshooting

**El email de bienvenida no llega**
→ Verifica que la credencial Gmail esté seleccionada en ambos nodos de envío
→ Revisa la carpeta de spam del destinatario
→ En n8n → Executions, revisa si el nodo Gmail devuelve error de autenticación

**El cron no procesa usuarios**
→ Asegúrate de que el workflow `onboarding-drip` está **Activo** (toggle en la esquina superior derecha)
→ Verifica que la tabla `user_onboarding` tiene filas con `completed = false`
→ Comprueba que `next_step_at <= now()` para esas filas

**FCM push no llega en Android**
→ Verifica `FCM_SERVER_KEY` en tus variables de entorno
→ Comprueba que `fcm_token` no es null en `user_profiles`
→ El token FCM caduca si el usuario desinstala/reinstala — actualízalo en cada login
