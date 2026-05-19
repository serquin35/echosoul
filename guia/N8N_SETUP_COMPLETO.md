# EchoSoul — Guía Completa de Configuración de Workflows n8n

> **Versión:** 1.0 | **Fecha:** Mayo 2026
> Este documento unifica las instrucciones de configuración para todos los flujos de n8n (Chat & IA, Onboarding, Proactividad).

---

## 1. Orden de Importación Global

Importa los workflows en tu instancia de n8n en este orden estricto para que las referencias cruzadas funcionen:

1. `echosoul-crisis-detector.json`
2. `echosoul-memory-extractor.json`
3. `echosoul-chat-proxy.json`
4. `echosoul-onboarding-new-user-welcome.json`
5. `echosoul-onboarding-drip.json`
6. `echosoul-proactividad-daily-checkin.json`
7. `echosoul-proactividad-smart-nudge.json`
8. `echosoul-proactividad-mood-insights.json`

---

## 2. Variables de Entorno (Dokploy / n8n)

Añade estas variables en tu entorno (Settings → Variables en n8n, o docker-compose):

| Variable | Valor de ejemplo | Descripción |
|---|---|---|
| `SUPABASE_URL` | `https://abcxyz.supabase.co` | URL de tu proyecto Supabase |
| `SUPABASE_SERVICE_KEY` | `eyJh...` | Service Role Key (NUNCA la anon key) |
| `CLAUDE_API_KEY` | `sk-ant-...` | API Key de Anthropic |
| `N8N_BASE_URL` | `https://n8n.tudominio.com` | URL pública de tu n8n |
| `APP_URL` | `https://echosoul.app` | URL de la landing/app web |
| `FCM_SERVER_KEY` | `AAAA...` | Firebase Cloud Messaging Server Key (Consola Firebase → Project Settings → Cloud Messaging) |
| `UPGRADE_URL` | `https://echosoul.app/pricing` | URL de página de pagos |
| `ADMIN_ALERT_WEBHOOK`| `https://hooks.slack.com/...` | Webhook de Slack/Discord para alertas de crisis |

---

## 3. Credenciales en n8n

1. **Supabase & Claude:** Los headers de los nodos HTTP referencian `$credentials.EchoSoulSupabase.value` y `$credentials.EchoSoulClaude.value`. Asegúrate de que los nombres de tus credenciales coincidan.
2. **Gmail OAuth2:** Para enviar emails (Onboarding), crea una credencial Gmail OAuth2 (**Credentials → New → Gmail OAuth2**). Asígnala en los nodos *Send welcome email* y *Send drip email*.

---

## 4. Workflows de Chat & IA

- **crisis-detector** y **memory-extractor** son sub-workflows llamados por **chat-proxy**. Tu app Flutter solo necesita llamar a `POST /webhook/chat`.
- El modelo de extracción usa `claude-haiku-4-5` por economía, el chat principal usa `claude-sonnet-4-6`.
- *memory-extractor* funciona de modo *fire & forget* gracias al nodo `Respond 200 Immediately`.

---

## 5. Workflows de Onboarding & Drip

- El webhook `new-user-welcome` se dispara desde Flutter tras un registro exitoso. Fallos en este webhook no deben impedir el login del usuario (maneja el error silenciosamente en Flutter).
- **Lógica Drip (Cron horario):**
  - Paso 0: Bienvenida (Inmediato, Email)
  - Paso 1: ¿Cómo fue tu día? (+24h, Email/FCM)
  - Paso 2: Mood Tracker (+72h, Email/FCM)
  - Paso 3: Upsell Premium (+120h, Email/FCM)
- Tras el paso 3, el campo `completed` pasa a `true` y el cron deja de procesar al usuario.

---

## 6. Workflows de Proactividad

### Crons configurados:
- **daily-checkin:** `0 9 * * *` (Todos los días a las 9:00 AM)
- **smart-nudge:** `0 */6 * * *` (Cada 6 horas, chequea inactividad)

### Consideraciones:
- Llama a `POST /webhook/mood-entry` desde Flutter cuando el usuario guarda su estado de ánimo.
- La lógica de `mood-insights` asume una escala de 1-10. Si el score es $\le 3$, se envía un mensaje empático especial. Ajusta este umbral en el nodo *Analyze mood pattern* si cambias la escala.
