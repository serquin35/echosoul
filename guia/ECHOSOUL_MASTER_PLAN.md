# EchoSoul — Master Plan de Desarrollo

> **Versión:** 4.0 | **Fecha:** Mayo 2026 | **Autor:** Serquin + Antigravity
> **Repositorio:** serquin35/echosoul | **Rama activa:** `master`

---

## 🎯 VISIÓN DEL PRODUCTO

**EchoSoul** combate la soledad mediante un compañero virtual proactivo con IA empática, memoria a largo plazo, check-ins emocionales y llamadas de voz personalizadas.

---

## 🏗️ ARQUITECTURA TÉCNICA

| Capa | Tecnología | Estado |
|------|-----------|--------|
| Frontend móvil/web | Flutter (Dart) 3.x | ✅ Activo |
| Estado | Riverpod 2.x + go_router 14.x | ✅ Activo |
| Backend/Auth/DB | Supabase (`pleeiqlldiwipaxqoumu`) | ✅ Activo |
| Automatizaciones | n8n (VPS Contabo via Dokploy) | ✅ 5 workflows activos |
| IA conversacional | GPT-4o (chat) + GPT-4o-mini (memoria) + Claude Haiku (crisis) | ✅ En n8n |
| Voz proactiva | Retell AI / Vapi.ai | 🔲 Pendiente |
| Push notifications | FCM v1 (Android) + Email (Web) | 🔲 Test real pendiente |
| Landing Web | Vite + HTML/CSS | ✅ Activo |
| Deploy Web | Vercel via GitHub Actions | ✅ Activo |
| Deploy Android | Google Play Console | 🔲 Pendiente |

### Infraestructura n8n (n8n.cheosdesign.info)

```
Flutter → /webhook/new-user → new-user-welcome → drip-sequence (cron)
Flutter → /webhook/chat    → chat-proxy → crisis-detector + memory-extractor
```

---

## 🗄️ BASE DE DATOS SUPABASE

### Estado de tablas (mayo 2026)

| Tabla | RLS | Policies | Notas |
|-------|-----|----------|-------|
| `profiles` | ✅ | SELECT·INSERT·UPDATE·DELETE | ✅ |
| `messages` | ✅ | SELECT·INSERT·DELETE | ✅ n8n escribe via service_role |
| `user_memories` | ✅ | SELECT·INSERT·DELETE | ✅ n8n upserta via service_role |
| `user_plans` | ✅ | SELECT·INSERT·UPDATE·DELETE | ✅ |
| `user_onboarding` | ✅ | SELECT·INSERT·UPDATE·DELETE | ✅ |
| `companion_settings` | ✅ | SELECT·INSERT·UPDATE·DELETE | ✅ |
| `checkins` | ✅ | SELECT·INSERT·UPDATE·DELETE | ✅ |
| `crisis_flags` | ✅ | SELECT·INSERT·UPDATE·DELETE | ✅ |
| `mood_entries` | ✅ | SELECT·INSERT·UPDATE·DELETE | ✅ |
| `user_preferences` | ✅ | SELECT·INSERT·UPDATE·DELETE | ✅ |
| `crisis_events` | ✅ | *(sin policy cliente — intencional)* | Solo n8n service_role |

> `crisis_events`: RLS activo sin policies de cliente = nadie desde Flutter puede leer/escribir. Solo `service_role` (n8n). Cumple GDPR Art. 5 (minimización de datos).

---

## 🤖 WORKFLOWS N8N ACTIVOS

| Workflow | Endpoint | IA | Estado |
|----------|----------|----|--------|
| `new-user-welcome` | `POST /webhook/new-user` | — | ✅ |
| `drip-sequence` | Cron (cada hora) | — | ✅ |
| `chat-proxy` | `POST /webhook/chat` | GPT-4o | ✅ |
| `crisis-detector` | `POST /webhook/crisis-check` | Claude Haiku | ✅ |
| `memory-extractor` | `POST /webhook/extract-memory` | GPT-4o-mini | ✅ |

### Variables n8n (Dokploy)

| Variable | Valor |
|----------|-------|
| `SUPABASE_URL` | `https://pleeiqlldiwipaxqoumu.supabase.co` |
| `SUPABASE_SERVICE_KEY` | Service Role Key |
| `CLAUDE_API_KEY` | API Key Anthropic |
| `N8N_BASE_URL` | `https://n8n.cheosdesign.info` |
| `APP_URL` | `https://echosoul-one.vercel.app` |
| `FCM_PROJECT_ID` | `echosoul-f2b89` |
| `FCM_SERVER_KEY` | Firebase Cloud Messaging Key |
| `ADMIN_ALERT_WEBHOOK` | Slack webhook para crisis HIGH |

> ⚠️ El JSON `onboarding/echosoul-onboarding-new-user-welcome.json` en disco referencia `user_profiles` (schema antiguo). La configuración **activa en n8n** usa la tabla correcta `profiles`. Los JSONs son referencia, no la fuente de verdad.

---

## 📊 ESTADO DEL DESARROLLO

### ✅ FASE 0 — Infraestructura (COMPLETADA)
- [x] Flutter + Supabase + GoRouter + auth guards
- [x] CI/CD GitHub Actions → Vercel
- [x] Autenticación email + reset password (PKCE)
- [x] 11 tablas Supabase con RLS completo (todas las políticas CRUD)

### ✅ FASE 1 — MVP Web (COMPLETADA EN SU MAYOR PARTE)
- [x] Landing, Auth, Onboarding, Chat, Mood, Profile, Legal, Voice UI
- [x] 5 workflows n8n activos y funcionando
- [x] Memoria a largo plazo con deduplicación por hash
- [x] Detección de crisis (3 niveles) con alerta admin
- [x] Drip emails de onboarding (pasos 0-3) + FCM Firebase v1
- [x] Deploy Vercel estable
- [ ] Google Sign-In web
- [ ] Dominio custom

### 🎯 FASE 2 — MVP Android (PENDIENTE)
- [ ] `google-services.json` en `android/app/`
- [ ] FCM Push con token real
- [ ] Workflows: Buenos Días + Check-in emocional + Llamada proactiva
- [ ] Integración Retell AI / Vapi.ai para voz
- [ ] Build AAB firmado → Play Console

### 💳 FASE 3 — Monetización (PENDIENTE)
- [ ] Google Play Billing + Paddle web
- [ ] UI de paywall + lógica free/premium
- [ ] Webhook n8n → sincronizar suscripción en Supabase

### 🛡️ FASE 4 — Ética y Cumplimiento (PENDIENTE)
- [ ] Crisis con recursos reales (teléfonos de emergencia)
- [ ] Opción "pausar compañero"
- [ ] GDPR: exportar + eliminar datos desde la app
- [ ] Política de Privacidad + T&C en URL pública
- [ ] Data Safety Form Play Store

### 🚀 FASE 5 — Post-MVP (FUTURO)
- [ ] Memoria vectorial (pgvector)
- [ ] WhatsApp (Twilio), iOS, Multi-idioma

---

## 🚦 CRITERIOS MVP PLAY STORE

| # | Criterio | Estado |
|---|----------|--------|
| 1 | Registro email | ✅ |
| 2 | Registro Google | 🔲 |
| 3 | Chat IA fluido | ✅ |
| 4 | Memoria largo plazo | ✅ |
| 5 | Buenos días / check-ins proactivos | 🔲 |
| 6 | Llamadas de voz | 🔲 |
| 7 | Mood tracker | ✅ |
| 8 | Disclaimers éticos | ✅ |
| 9 | Crisis con recursos reales | 🔲 |
| 10 | Privacidad + T&C públicos | 🔲 |
| 11 | App firmada en Play Console | 🔲 |
| 12 | Data Safety Form | 🔲 |

**5/12 completados** — MVP Android en progreso.

---

## ⚙️ VARIABLES DE ENTORNO

### echosoul/.env (Flutter)
```env
SUPABASE_URL=https://pleeiqlldiwipaxqoumu.supabase.co
SUPABASE_ANON_KEY=eyJh...
AUTH_REDIRECT_URL=https://echosoul-one.vercel.app/reset-password
N8N_CHAT_WEBHOOK_URL=https://n8n.cheosdesign.info/webhook/chat
```

---

## 🔧 PRINCIPIOS ARQUITECTÓNICOS

1. **UI tonta** — pantallas solo renderizan estado
2. **Lógica ciega** — providers/use cases no conocen la UI
3. **n8n separado** — nunca lógica mixta en flujos
4. **Wrappers siempre** — repositorios entre UI y APIs externas
5. **`EsPlatform`** — nunca `kIsWeb` directamente

---

## 📞 SKILLS DISPONIBLES

| Skill | Uso |
|-------|-----|
| `echosoul-flutter-lead` | Features Flutter, arquitectura |
| `echosoul-automation-specialist` | Workflows n8n |
| `echosoul-data-architect` | Tablas, RLS, migraciones |
| `echosoul-ethical-ai-strategist` | Prompts, crisis |
| `echosoul-landing-architect` | Landing page |
| `n8n-mcp-tools-expert` | MCP tools n8n |

---

*Última actualización: Mayo 2026*
