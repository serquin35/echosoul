# EchoSoul — Walkthrough de Infraestructura (Mayo 2026)

Resumen de todos los hitos completados en n8n, Supabase y CI/CD.

---

## ✅ HITO 1 — Pipeline de Chat IA (chat-proxy + crisis + memoria)

**Workflows activos:** `chat-proxy`, `crisis-detector`, `memory-extractor`

### Qué hace el pipeline
1. Flutter envía `POST /webhook/chat` con `{user_id, session_id, message, plan_limit}`
2. **chat-proxy** comprueba límite diario de mensajes (`messages` table)
3. Carga memorias del usuario (`user_memories`) y últimos 8 mensajes de sesión
4. Llama a **GPT-4o** con system prompt personalizado + historial
5. En paralelo asíncrono: **crisis-detector** analiza el mensaje con Claude Haiku
6. Guarda los dos mensajes (user + assistant) en `messages`
7. Dispara **memory-extractor** (fire & forget) → GPT-4o-mini extrae datos relevantes → upserta en `user_memories` con deduplicación por `content_hash`
8. Responde `{reply, is_crisis, tokens_used}` al cliente

### Decisiones técnicas clave
- **Fire & forget**: memory-extractor responde 200 inmediatamente y procesa en background
- **Deduplicación**: `content_hash = user_id + content[0:50]` previene memorias duplicadas
- **Crisis anonimizado**: `crisis_events` solo guarda `user_id + level + msg_hash`, nunca el texto
- **Límites de uso**: `user_plans.daily_limit` (default: 20 msg/día en plan free)

---

## ✅ HITO 2 — Pipeline de Onboarding (new-user + drip)

**Workflows activos:** `new-user-welcome`, `drip-sequence`

### Flujo de registro
1. Flutter llama `POST /webhook/new-user` tras signup exitoso
2. n8n crea/actualiza registros en: `profiles`, `user_plans` (free, 20 msg/día), `user_onboarding` (step=1)
3. Envía email de bienvenida HTML via Gmail OAuth2
4. Cron horario ejecuta `drip-sequence` → procesa usuarios con `next_step_at <= now()` y `completed = false`

### Pasos del drip
| Paso | Contenido | Delay | Canal |
|------|-----------|-------|-------|
| 0 | Bienvenida | Inmediato | Email |
| 1 | "¿Cómo fue tu primer día?" | +24h | Email + FCM |
| 2 | Intro al Mood Tracker | +72h | Email + FCM |
| 3 | Soft upsell Premium | +120h | Email + FCM |

**FCM**: Migrado a Firebase v1 API (Legacy API deprecated). Credencial Google Cloud Service Account (`echosoul-f2b89`) configurada en n8n.

---

## ✅ HITO 3 — Supabase RLS Completo

**11 tablas** con Row Level Security activo. Policies CRUD completas aplicadas en mayo 2026.

### Resumen de policies por tabla

| Tabla | SELECT | INSERT | UPDATE | DELETE | Notas |
|-------|--------|--------|--------|--------|-------|
| `profiles` | ✅ | ✅ | ✅ | ✅ | |
| `messages` | ✅ | ✅ | — | ✅ | n8n escribe via service_role |
| `user_memories` | ✅ | ✅ | — | ✅ | n8n upserta via service_role |
| `user_plans` | ✅ | ✅ | ✅ | ✅ | |
| `user_onboarding` | ✅ | ✅ | ✅ | ✅ | |
| `companion_settings` | ✅ | ✅ | ✅ | ✅ | |
| `checkins` | ✅ | ✅ | ✅ | ✅ | |
| `crisis_flags` | ✅ | ✅ | ✅ | ✅ | |
| `mood_entries` | ✅ | ✅ | ✅ | ✅ | **Añadido mayo 2026** |
| `user_preferences` | ✅ | ✅ | ✅ | ✅ | **Añadido mayo 2026** |
| `crisis_events` | — | — | — | — | Solo service_role (n8n). Intencional. |

Todas las policies usan `auth.uid() = user_id` (o `auth.uid() = id` en `profiles`).

---

## ✅ HITO 4 — Estabilización de Workflows

Correcciones aplicadas durante mayo 2026:

- **UUID validation**: validación de `user_id` en chat-proxy antes de consultas Supabase
- **Migración a OpenAI**: chat-proxy y memory-extractor migrados de Claude a GPT-4o / GPT-4o-mini
- **URL hardcodeadas resueltas**: uso de `$env.SUPABASE_URL` y `$env.SUPABASE_SERVICE_KEY`
- **Error handling**: `onError: continueRegularOutput` en nodos críticos
- **Schema fix**: tabla `profiles` (era `user_profiles` en onboarding antiguo)
- **FCM v1**: migración de Legacy API a Google Cloud Service Account

---

## 🔧 Variables de entorno requeridas (Dokploy / n8n)

```env
SUPABASE_URL=https://pleeiqlldiwipaxqoumu.supabase.co
SUPABASE_SERVICE_KEY=<service_role_key>
CLAUDE_API_KEY=<anthropic_key>
N8N_BASE_URL=https://n8n.cheosdesign.info
APP_URL=https://echosoul-one.vercel.app
FCM_PROJECT_ID=echosoul-f2b89
FCM_SERVER_KEY=<firebase_server_key>
ADMIN_ALERT_WEBHOOK=<slack_incoming_webhook>
```

## 🔧 Variables de entorno Flutter (echosoul/.env)

```env
SUPABASE_URL=https://pleeiqlldiwipaxqoumu.supabase.co
SUPABASE_ANON_KEY=<anon_key>
AUTH_REDIRECT_URL=https://echosoul-one.vercel.app/reset-password
N8N_CHAT_WEBHOOK_URL=https://n8n.cheosdesign.info/webhook/chat
```

---

## ✅ HITO 5 — i18n Multi-idioma (ES/EN)

**Completado 31/05/2026:**

- [x] ARB files con traducciones completas (160+ keys ES, 153 keys EN)
- [x] `LocaleProvider` con persistencia vía SharedPreferences
- [x] Migración de 9 pantallas Flutter a `S.of(context)`
- [x] Language switcher en perfil (ES ↔ EN) con sync a `profiles.preferred_language`
- [x] Landing pages legales en inglés (`/cookies-en`, `/privacy-en`, `/terms-en`)
- [x] Build AAB firmado para Google Play Console (v1.0.1+2)
- [x] Commit y push a `master`

---

## 📌 Pendientes inmediatos

- [x] **Test FCM real**: validar notificaciones push con el nuevo build AAB
- [x] **Gmail credential**: asignar credencial Gmail en nodos de email de los workflows
- [x] **Dominio custom**: configurar en Vercel
- [x] **Google Sign-In web**: implementado
- [x] **FCM sync en initState**: ConsumerStatefulWidget con addPostFrameCallback
- [x] **SenderName en emails n8n**: "EchoSoul" como remitente en todos los workflows
- [ ] **Voz proactiva (Retell/Vapi)**: integración pendiente
- [ ] **Monetización**: Google Play Billing + Paddle
