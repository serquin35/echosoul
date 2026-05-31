# EchoSoul — Master Plan de Desarrollo

> **Versión:** 5.2 | **Fecha:** 17 Mayo 2026 | **Autor:** Serquin + Antigravity
> **Repositorio:** `serquin35/echosoul` | **Rama activa:** `master`
> **⚠️ Este archivo es la ÚNICA fuente de verdad del proyecto.**

---

## 🎯 VISIÓN DEL PRODUCTO

**EchoSoul** combate la soledad mediante un compañero virtual proactivo con IA empática:
- Conversación con **memoria a largo plazo** personalizada
- **Check-ins emocionales** diarios (mensaje y voz)
- **Buenos días / buenas noches** automáticos por n8n
- **Llamadas de voz proactivas** cortas (3–7 min) via Retell/Vapi
- **Detección ética de crisis** con escalada a recursos reales

**Plataformas:** Android-first (compañía íntima) · Web (adquisición + onboarding)

---

## 🏗️ ARQUITECTURA TÉCNICA

| Capa | Tecnología | Estado |
|------|-----------|--------|
| App móvil/web | Flutter 3.x + Riverpod 2.x + go_router 14.x | ✅ Activo |
| Auth / DB / Storage | Supabase (`pleeiqlldiwipaxqoumu`) | ✅ Activo |
| Automatizaciones | n8n en VPS Contabo/Dokploy (`n8n.cheosdesign.info`) | ✅ 8 workflows activos |
| IA conversacional | GPT-4o (chat) · GPT-4o-mini (memoria) · Claude Haiku (crisis) | ✅ En n8n |
| Push notifications | FCM v1 API (Android) · Email Gmail OAuth2 (Web) | ✅ FCM E2E validado en dispositivo físico |
| Voz proactiva | Retell AI / Vapi.ai | 🔲 Pendiente |
| Web deploy | Vercel via GitHub Actions (`echosoul.dev`) | ✅ Activo |
| Android deploy | Google Play Console | ✅ Prueba cerrada activa |
| Pagos | Google Play Billing (Android) · Paddle (Web) | 🔲 Pendiente |

### Pipeline de datos

```
Flutter ──POST /webhook/new-user──► new-user-welcome ──► drip-sequence (cron/1h)
Flutter ──POST /webhook/chat──────► chat-proxy ──┬──► crisis-detector (Claude Haiku)
                                                  └──► memory-extractor (GPT-4o-mini, fire&forget)
Flutter ──POST /webhook/mood-entry► mood-insights ──► FCM / Email
n8n cron 09:00 ───────────────────► daily-checkin ──► FCM / Email
n8n cron */6h  ───────────────────► smart-nudge   ──► FCM / Email (si inactivo >6h)
```

### CI/CD

```
git push → GitHub Actions → flutter build web → Vercel (CDN)
                           → flutter build aab → Google Play Console (pendiente)
```

---

## 🗄️ BASE DE DATOS SUPABASE

**11 tablas — todas con RLS activo (Mayo 2026)**

| Tabla | CRUD Cliente | Notas |
|-------|-------------|-------|
| `profiles` | ✅ Completo | Incluye `email`, `platform`, `fcm_token` |
| `messages` | SELECT · INSERT · DELETE | n8n escribe via `service_role` |
| `user_memories` | SELECT · INSERT · DELETE | n8n upserta. Deduplicación por `content_hash` |
| `user_plans` | ✅ Completo | `free` (20 msg/día) / `premium` |
| `user_onboarding` | ✅ Completo | State machine drip steps 0–3 |
| `companion_settings` | ✅ Completo | Preferencias del companion por usuario |
| `checkins` | ✅ Completo | triggered_by: `daily-checkin` · `smart-nudge` · `mood-insight` |
| `crisis_flags` | ✅ Completo | Banderas activas de crisis |
| `mood_entries` | ✅ Completo | Escala 1–10 |
| `user_preferences` | ✅ Completo | Preferencias de notificación |
| `crisis_events` | ❌ Sin policy cliente | Solo `service_role`. Solo hash, nunca texto. GDPR Art.5 |

> ⚠️ Los JSON en `/onboardingN8N/` referencian `user_profiles` (schema antiguo). La tabla activa es `profiles`. Los JSON son backups, no la fuente de verdad.

---

## 🤖 WORKFLOWS N8N — INVENTARIO COMPLETO

### Chat & IA (`/flujosN8N/`)

| Workflow | Trigger | IA | Estado |
|----------|---------|-----|--------|
| `chat-proxy` | `POST /webhook/chat` | GPT-4o | ✅ |
| `crisis-detector` | Interno desde chat-proxy | Claude Haiku | ✅ |
| `memory-extractor` | Fire&forget desde chat-proxy | GPT-4o-mini | ✅ |

### Onboarding (`/onboardingN8N/`)

| Workflow | Trigger | Canal | Estado |
|----------|---------|-------|--------|
| `new-user-welcome` | `POST /webhook/new-user` | Email Gmail OAuth2 | ✅ |
| `drip-sequence` | Cron cada hora | Email + FCM v1 | ✅ |

**Pasos del drip:**
| Paso | Contenido | Delay | Canal |
|------|-----------|-------|-------|
| 0 | Bienvenida | Inmediato | Email |
| 1 | "¿Cómo fue tu primer día?" | +24h | Email + FCM |
| 2 | Intro Mood Tracker | +72h | Email + FCM |
| 3 | Soft upsell Premium | +120h | Email + FCM |

### Proactividad (`/ProactividadN8N/`)

| Workflow | Trigger | Canal | Estado |
|----------|---------|-------|--------|
| `daily-checkin` | Cron `0 9 * * *` | FCM + Email | ✅ (sin test FCM real) |
| `smart-nudge` | Cron `0 */6 * * *` | FCM + Email | ✅ (sin test FCM real) |
| `mood-insights` | `POST /webhook/mood-entry` | FCM + Email | ✅ (sin test FCM real) |

### Variables de entorno — n8n/Dokploy

| Variable | Valor |
|----------|-------|
| `SUPABASE_URL` | `https://pleeiqlldiwipaxqoumu.supabase.co` |
| `SUPABASE_SERVICE_KEY` | Service Role Key |
| `CLAUDE_API_KEY` | API Key Anthropic |
| `N8N_BASE_URL` | `https://n8n.cheosdesign.info` |
| `APP_URL` | `https://echosoul.dev` |
| `FCM_PROJECT_ID` | `echosoul-f2b89` |
| `FCM_SERVER_KEY` | Firebase Cloud Messaging Server Key |
| `ADMIN_ALERT_WEBHOOK` | Slack Incoming Webhook (alertas crisis HIGH) |

### Variables Flutter (`echosoul/.env`)

```env
SUPABASE_URL=https://pleeiqlldiwipaxqoumu.supabase.co
SUPABASE_ANON_KEY=eyJh...
AUTH_REDIRECT_URL=https://echosoul.dev/reset-password
N8N_CHAT_WEBHOOK_URL=https://n8n.cheosdesign.info/webhook/chat
```

---

## 📱 FLUTTER — FEATURES IMPLEMENTADAS

| Feature | Pantallas / Estado |
|---------|-------------------|
| `auth` | Login · Reset Password ✅ |
| `companion` | Home · Chat · Layout · Voice UI ✅ |
| `mood` | Mood Tracker ✅ |
| `onboarding` | Flujo completo ✅ |
| `profile` | Perfil de usuario ✅ |
| `legal` | Política + T&C ✅ |
| `landing` | Landing page ✅ |

**Arquitectura:** Clean Architecture · UI tonta + Lógica ciega · `EsPlatform` wrapper · Navegación adaptativa (Bottom Nav Android / Sidebar Web ≥720dp)

---

## 📊 ESTADO DEL DESARROLLO POR FASES

### ✅ FASE 0 — Infraestructura Base [COMPLETADA]
- [x] Flutter + Supabase + GoRouter + auth guards
- [x] CI/CD GitHub Actions → Vercel
- [x] Auth email + reset password (PKCE)
- [x] 11 tablas Supabase con RLS completo

### ✅ FASE 1 — MVP Web [COMPLETADA ~85%]
- [x] Todas las pantallas implementadas (Landing, Auth, Onboarding, Chat, Mood, Profile, Legal, Voice UI)
- [x] 8 workflows n8n activos y funcionando
- [x] Memoria a largo plazo con deduplicación por hash
- [x] Detección de crisis (3 niveles) con alerta admin Slack
- [x] Drip onboarding (pasos 0–3) + FCM Firebase v1
- [x] Deploy Vercel estable
- [x] Política de Privacidad + T&C en URL pública
- [ ] Google Sign-In web — pendiente
- [ ] Dominio custom en Vercel — pendiente

### 🎯 FASE 2 — MVP Android [EN PROGRESO ~65%]

**Completado en sesión 17/05/2026:**
- [x] `google-services.json` en `android/app/` + `AndroidManifest.xml` con permisos FCM
- [x] `fcm_service.dart` — maneja Foreground / Background / Terminated
- [x] Sincronización FCM token en login → Supabase `profiles.fcm_token`
- [x] Test push E2E real — daily-checkin, smart-nudge y mood-insights validados en Xiaomi físico
- [x] **Deep Routing en Tap de Notificaciones (FCM)** — Configuración de `rootNavigatorKey` en `app_router.dart` y redirección en `fcm_service.dart` para llevar al usuario al screen correcto (Chat, Mood, Home) al abrir notificaciones en background/terminated.
- [x] **Google Sign-In Android** — configurado con SHA-1 en Firebase + flow nativo funcional
- [x] **Fix Android Companion Info Sheet** — bug crítico de renderizado negro resuelto:
  - Causa raíz: `Border()` con colores no uniformes + `borderRadius` → excepción Flutter en Android
  - Fix: `Border.all()` uniforme + `backgroundColor` sólido en `showModalBottomSheet`
  - Fix adicional: `MediaQuery.sizeOf` leído del contexto exterior (no del builder del modal)
- [x] **Modal Dialog Responsivo para Web/Escritorio (≥600px)** — En pantallas anchas (como monitores de 27 pulgadas), la info del compañero ahora se dibuja centrada y premium como un `Dialog` con un botón de cierre (`Icons.close`), eliminando el desplazamiento vertical excesivo.
- [x] Páginas legales públicas (`/privacy`, `/terms`, `/cookies`) con navegación correcta
- [x] Botón (i) de info del companion funcional en Android y Web

**Pendiente:**
- [ ] Conectar workflow `buenos-dias` al cron de n8n
- [ ] Integración Retell AI / Vapi.ai (voz proactiva)
- [x] Build AAB firmado → Google Play Console
- [ ] Test flujo completo E2E en dispositivo físico (onboarding → chat → push → mood)

### 💳 FASE 3 — Monetización [PENDIENTE]
- [ ] Google Play Billing (compra in-app Android)
- [ ] Paddle (billing web externo)
- [ ] UI paywall + lógica free/premium en Flutter
- [ ] Webhook n8n → sincronizar suscripción en `user_plans`

### 🛡️ FASE 4 — Ética y Cumplimiento [EN PROGRESO ~40%]
- [x] Disclaimers éticos en onboarding y chat
- [x] Política de Privacidad + T&C públicos
- [x] `crisis_events` anonimizado (hash, sin texto)
- [x] Crisis: teléfonos de emergencia reales por país (ES: 024, 112)
- [x] Opción "pausar compañero" (UI + lógica n8n)
- [x] GDPR: exportar datos del usuario desde la app
- [x] GDPR: eliminar cuenta + todos los datos desde la app
- [x] Data Safety Form Play Store
- [ ] Límites diarios de interacción configurables

### 🚀 FASE 5 — Post-MVP / Futuro [PENDIENTE]
- [ ] Memoria vectorial (pgvector embeddings)
- [ ] WhatsApp Business API (Twilio)
- [ ] iOS (App Store)
- [ ] Multi-idioma (i18n — español + inglés)
- [ ] Challenges IRL (hábitos sociales)
- [ ] Modo offline real (Hive cache — package ya instalado)
- [ ] Accesibilidad TalkBack / VoiceOver
- [ ] Comunidad entre usuarios (TBD)

---

## 🚦 CRITERIOS MVP PLAY STORE

| # | Criterio | Estado |
|---|----------|--------|
| 1 | Registro email | ✅ |
| 2 | Registro Google Sign-In | ✅ |
| 3 | Chat IA fluido con memoria | ✅ |
| 4 | Memoria a largo plazo | ✅ |
| 5 | Buenos días / check-ins proactivos (FCM E2E ✅) | ✅ (`daily-checkin`) |
| 6 | Llamadas de voz proactivas | 🔲 |
| 7 | Mood tracker funcional | ✅ |
| 8 | Disclaimers éticos visibles | ✅ |
| 9 | Crisis con recursos reales (teléfonos) | ✅ |
| 10 | Privacidad + T&C públicos | ✅ |
| 11 | App firmada en Play Console | ✅ |
| 12 | Data Safety Form completado | ✅ |

**11/12 completados — falta 1 (voz proactiva, opcional) para publicar.**

---

## 🎯 HITOS PENDIENTES — MAYOR A MENOR IMPORTANCIA

### 🔴 CRÍTICO — Bloqueantes para publicar en Play Store

| # | Hito | Descripción | Esfuerzo |
|---|------|-------------|---------|
| ~~**H1**~~ | ~~FCM real: `google-services.json` + token~~ | ~~✅ COMPLETADO~~ | ✅ |
| ~~**H2**~~ | ~~Build AAB firmado + Play Console~~ | ~~✅ COMPLETADO~~ | ✅ |
| ~~**H3**~~ | ~~Data Safety Form Play Store~~ | ~~✅ COMPLETADO~~ | ✅ |
| ~~**H4**~~ | ~~Google Sign-In Android~~ | ~~✅ COMPLETADO — SHA-1 + flow nativo~~ | ✅ |
| ~~**H5**~~ | ~~Crisis con teléfonos de emergencia reales~~ | ~~✅ COMPLETADO~~ | ✅ |

### 🟠 ALTA PRIORIDAD — Core del producto

| # | Hito | Descripción | Esfuerzo |
|---|------|-------------|---------|
| ~~**H6**~~ | ~~Conectar workflow `buenos-dias` al cron~~ | ~~✅ Sustituido por `daily-checkin`~~ | ✅ |
| ~~**H7**~~ | ~~Test E2E notificaciones push reales~~ | ~~✅ COMPLETADO — daily-checkin + smart-nudge + mood-insights en Xiaomi~~ | ✅ |
| ~~**H8**~~ | ~~Opción "pausar compañero"~~ | ~~✅ COMPLETADO — Switch UI + flag de base de datos + exclusión en flujos n8n~~ | ✅ |
| ~~**H9**~~ | ~~Eliminar cuenta desde la app (GDPR)~~ | ~~✅ COMPLETADO — Edge Function + cascade deletes~~ | ✅ |

### 🟡 MEDIA PRIORIDAD — Mejoras de producto

| # | Hito | Descripción | Esfuerzo |
|---|------|-------------|---------|
| **H10** | Voz proactiva (Retell/Vapi) | Integrar SDK + definir pricing por llamada | 🔴 Alto |
| **H11** | Monetización (Play Billing + Paddle) | Paywall UI + lógica free/premium + webhook Supabase | 🔴 Alto |
| ~~**H12**~~ | ~~Exportar datos GDPR~~ | ~~✅ COMPLETADO — Función SQL / RPC + Share nativo~~ | ✅ |
| **H13** | Dominio custom Vercel | Apuntar DNS al dominio definitivo | 🟢 Bajo |
| **H14** | Fuentes Inter en Flutter | Descomentar sección `fonts` en `pubspec.yaml` + añadir TTF | 🟢 Bajo |

### 🟢 BAJA PRIORIDAD — Post-MVP / Futuro

| # | Hito | Descripción | Esfuerzo |
|---|------|-------------|---------|
| **H15** | Memoria vectorial (pgvector) | Embeddings semánticos para búsqueda de memoria precisa | 🔴 Alto |
| **H16** | WhatsApp Business (Twilio) | Canal adicional de notificaciones proactivas | 🔴 Alto |
| **H17** | Multi-idioma (i18n) | `flutter_localizations` + ARB files EN/ES | 🟡 Medio |
| **H18** | iOS (App Store) | Build + certificados Apple + review | 🔴 Alto |
| **H19** | Challenges IRL | Feature hábitos sociales ("llama a un amigo hoy") | 🟡 Medio |
| **H20** | Accesibilidad (TalkBack/VoiceOver) | Semantics en widgets clave | 🟡 Medio |
| **H21** | Modo offline real (Hive cache) | Cache de mensajes — `hive_flutter` ya instalado | 🟡 Medio |

---

## ⚠️ DEUDA TÉCNICA

| Ítem | Urgencia |
|------|---------|
| FCM token sin actualizar en re-login (token caduca al reinstalar) | 🟡 Media |
| Fuentes Inter comentadas en `pubspec.yaml` | 🟡 Media |
| Escala mood 1-10 no validada entre Flutter y n8n | 🟡 Media |
| JSON legacy referenciando `user_profiles` (tabla renombrada a `profiles`) | 🟢 Baja (son backups) |
| Modo offline sin implementar (hive instalado, sin usar) | 🟢 Baja |

### ✅ Deuda técnica resuelta (17/05/2026)
| Ítem resuelto | Fix aplicado |
|---------------|--------------|
| `Border()` no uniforme + `borderRadius` → excepción Android | `Border.all()` uniforme en `_CompanionInfoContent` |
| `showModalBottomSheet` con `Colors.transparent` → negro en Android | `backgroundColor: EsColors.backgroundDark` + `shape` nativo |
| `MediaQuery` leído del contexto del builder modal → dimensiones incorrectas | `MediaQuery.sizeOf` leído del contexto exterior pre-modal |
| `DraggableScrollableSheet` sin `expand: false` → sheet vacío en web | Reemplazado por `SizedBox` con altura calculada |

---

## 🔧 PRINCIPIOS ARQUITECTÓNICOS

1. **UI tonta** — Pantallas solo renderizan estado del provider
2. **Lógica ciega** — Providers/use cases sin conocimiento de UI
3. **n8n separado** — Sin lógica mixta en flujos de automatización
4. **Wrappers siempre** — Repositorios entre UI y APIs externas
5. **`EsPlatform`** — Nunca `kIsWeb` directamente en features

---

## 🌐 ARQUITECTURA MULTI-PLATAFORMA

EchoSoul opera con **una sola base de código Flutter** y **un único backend (Supabase + n8n)**, pero presenta **dos experiencias diferenciadas**:

| Dimensión | Android (Play Store) | Web (Vercel) |
|---|---|---|
| Propósito | Compañía íntima diaria | Adquisición, onboarding, billing |
| Notificaciones | FCM Push nativas | Email fallback |
| Voz proactiva | ✅ Retell / Vapi | ❌ No disponible |
| Modo offline | ✅ Cache local (Hive) | ❌ No |
| Pagos | Google Play Billing | Paddle (web) |
| Navegación | Bottom Navigation Bar | Sidebar |

**Detección de Plataforma en Código:**
Nunca uses `kIsWeb` directamente en código de feature — usa siempre `EsPlatform` (`EsPlatform.isWeb`, `EsPlatform.supportsVoiceCalls`).

---

## ⚙️ REQUERIMIENTOS NO FUNCIONALES

- **Usabilidad:** Mobile-first, botones grandes, interfaz cálida y minimalista.
- **Rendimiento:** Respuestas rápidas, llamadas fluidas.
- **Privacidad:** Cumplir GDPR/CCPA. Datos sensibles protegidos.
- **Ética:** Transparencia total sobre el uso de IA.
- **Offline:** Chat básico con sincronización posterior.
- **Accesibilidad:** Soporte TalkBack / VoiceOver.

---

## 🔑 CREDENCIALES ANDROID (Keystore)

Para compilar el App Bundle (.aab) firmado, las credenciales están configuradas en `echosoul/android/key.properties`:
- **Contraseña de Keystore y Key:** `[REDACTED - VER key.properties LOCAL]`
- **Alias:** `upload`
- **Archivo Keystore:** `upload-keystore.jks` (Generado vía `keytool` y excluido en `.gitignore`)

---
## 🛠️ GUÍA DE DEBUGGING — REGLAS APRENDIDAS

| Situación | Herramienta correcta | Trampa común |
|-----------|---------------------|--------------|
| Debug en Android físico | `flutter run -d <device_id>` desde terminal | Android Studio con APK instalado no muestra logs de excepción |
| Ver device IDs | `flutter devices` | — |
| Hot reload (cambios UI) | `r` en la terminal de flutter run | No funciona tras cambios estructurales |
| Hot restart (cambios lógica) | `R` mayúscula en la terminal | — |
| `Border()` con `borderRadius` | Usar siempre `Border.all()` (colores uniformes) | `Border()` con lados distintos lanza excepción silenciosa en Android |
| `MediaQuery` en `showModalBottomSheet` | Leer ANTES de abrir el modal, del contexto exterior | El contexto del builder vive en el Overlay (dimensiones incorrectas en Android) |
| `backgroundColor` en bottom sheets | Usar color sólido real, nunca `Colors.transparent` | Transparencias apiladas causan bug de composición GPU en ciertos Android |

---

## 📚 SKILLS DISPONIBLES

| Skill | Uso |
|-------|-----|
| `echosoul-flutter-lead` | Features Flutter, arquitectura |
| `echosoul-automation-specialist` | Workflows n8n |
| `echosoul-data-architect` | Tablas, RLS, migraciones |
| `echosoul-ethical-ai-strategist` | Prompts, crisis, ética |
| `echosoul-landing-architect` | Landing page |
| `n8n-mcp-tools-expert` | MCP tools n8n |

---

## 📚 MAPA DE DOCUMENTACIÓN

| Archivo | Propósito | Rol |
|---------|-----------|-----|
| `guia/ECHOSOUL_MASTER_PLAN.md` | **Este archivo** — Estado global, fases, workflows, DB | 🟢 Fuente de verdad |
| `guia/N8N_SETUP_COMPLETO.md` | Guía unificada de instalación de workflows (Chat, Onboarding, Proactividad) | 📖 Referencia técnica |
| `onboardingN8N/walkthrough.md` | Historial de hitos completados | 📖 Histórico |

---

*Última actualización: 19 Mayo 2026*
