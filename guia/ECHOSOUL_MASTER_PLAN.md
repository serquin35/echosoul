# EchoSoul — Master Plan de Desarrollo

> **Versión:** 3.0 (Unificada) | **Fecha:** Mayo 2026 | **Autor:** Serquin + Antigravity  
> **Repositorio:** serquin35/echosoul | **Rama activa:** `master`

---

## 🎯 VISIÓN DEL PRODUCTO

**EchoSoul** es una aplicación de **compañero virtual proactivo** impulsada por IA que combate la soledad mediante interacciones empáticas, mensajes automáticos, check-ins emocionales y llamadas de voz personalizadas. El usuario siente que tiene un compañero que se preocupa por él de forma genuina.

**Propuesta de valor única:**
- Proactividad real: EchoSoul inicia conversaciones, no solo responde
- Memoria a largo plazo: recuerda quién eres, qué te preocupa, qué te gusta
- Voz natural: llamadas de audio cortas (3-7 min) generadas por IA
- Ética by design: disclaimers, límites de uso, manejo de crisis

---

## 🏗️ ARQUITECTURA TÉCNICA

### Stack Completo

| Capa | Tecnología | Estado |
|------|-----------|--------|
| Frontend móvil/web | Flutter (Dart) 3.x | ✅ Activo |
| Estado | Riverpod 2.x + go_router 14.x | ✅ Activo |
| Backend/Auth/DB | Supabase (PostgreSQL + Auth + Storage) | ✅ Activo |
| Automatizaciones | n8n (VPS Contabo) | ✅ Workflows base listos |
| IA conversacional | Claude Sonnet 4.6 (chat) + Claude Haiku (memoria) | ✅ En n8n |
| Voz proactiva | Retell AI / Vapi.ai + ElevenLabs | 🔲 Pendiente |
| Mensajería push | FCM (Android) + Email fallback (Web) | 🔲 Pendiente |
| WhatsApp | Twilio / WhatsApp Business API | 🔲 Pendiente |
| Landing Web | Vite + HTML/CSS vanilla | ✅ Activo |
| Deploy Web | Vercel (CDN) via GitHub Actions | ✅ Activo |
| Deploy Android | Google Play Console (AAB) | 🔲 Pendiente |
| Monetización | Google Play Billing (Android) + Paddle (Web) | 🔲 Pendiente |

### Infraestructura

```
Android App ─┐
              ├──▶ Supabase (Auth · DB · Storage · Realtime)
Web (Vercel) ─┘         │
                         ▼
                  VPS Contabo
                  └── n8n (workflows proactivos, LLM proxy)
```

### Pipeline CI/CD

```
git push (master) → GitHub Actions
  ├── flutter build web --release
  ├── Inject secrets (.env)
  └── Deploy → Vercel (CDN global)
```

---

## 📁 ESTRUCTURA DEL REPOSITORIO

```
No More Alone/                     ← Raíz del repo
├── echosoul/                      ← App Flutter principal
│   ├── lib/
│   │   ├── main.dart
│   │   ├── core/
│   │   │   ├── config/            ← Supabase init, env
│   │   │   ├── constants/         ← EsColors, EsTypography
│   │   │   ├── errors/            ← Failure classes
│   │   │   ├── router/            ← app_router.dart, route_names.dart
│   │   │   ├── theme/             ← AppTheme
│   │   │   └── utils/             ← EsPlatform (detección plataforma)
│   │   ├── features/
│   │   │   ├── auth/              ← Login, ResetPassword
│   │   │   ├── onboarding/        ← OnboardingScreen (multi-step)
│   │   │   ├── companion/         ← CompanionHome, Chat, VoiceCall, MainLayout
│   │   │   ├── mood/              ← MoodTracker
│   │   │   ├── profile/           ← ProfileScreen
│   │   │   ├── legal/             ← LegalScreen
│   │   │   └── landing/           ← LandingScreen (Flutter web splash)
│   │   ├── automation/            ← Wrappers n8n, LLM, Voz
│   │   └── shared/
│   │       └── design_system/
│   │           └── atoms/         ← EsButton, EsTextField, etc.
│   ├── .github/workflows/
│   │   └── deploy.yml             ← CI/CD → Vercel
│   └── assets/images/             ← logo_icon.png, etc.
├── fluosN8N/                      ← Workflows n8n exportados
│   ├── echosoul-chat-proxy.json
│   ├── echosoul-crisis-detector.json
│   ├── echosoul-memory-extractor.json
│   └── echosoul-n8n-setup.md
├── landing/                       ← Landing page web (Vite)
│   ├── index.html
│   ├── src/main.js
│   └── public/app/status.html
├── guia/                          ← Documentación del proyecto
│   ├── ECHOSOUL_MASTER_PLAN.md    ← ESTE ARCHIVO
│   ├── Especificación de Requerimientos.md
│   ├── Arquitectura Multi-Plataforma.md
│   └── Buenas Practicas.md
└── vercel.json                    ← Routing SPA config
```

---

## 🗄️ MODELO DE DATOS (Supabase)

### Tablas implementadas / necesarias

```sql
-- AUTH (gestionada por Supabase Auth)
auth.users  ← base

-- PERFIL Y PREFERENCIAS
CREATE TABLE profiles (
  id            UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  display_name  TEXT,
  avatar_url    TEXT,
  age           INTEGER,
  tone          TEXT DEFAULT 'amigo',  -- amigo | terapeuta | motivador
  onboarding_completed BOOLEAN DEFAULT FALSE,
  created_at    TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE user_preferences (
  user_id           UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  safe_hours_start  TIME DEFAULT '08:00',
  safe_hours_end    TIME DEFAULT '22:00',
  proactivity_level INTEGER DEFAULT 3,  -- 1=bajo, 5=alto
  favorite_topics   TEXT[],
  updated_at        TIMESTAMPTZ DEFAULT NOW()
);

-- CHAT Y MEMORIA (implementadas en n8n setup)
CREATE TABLE messages (
  id          UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id     UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  session_id  UUID NOT NULL,
  role        TEXT NOT NULL CHECK (role IN ('user', 'assistant')),
  content     TEXT NOT NULL,
  created_at  TIMESTAMPTZ DEFAULT NOW()
);

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

-- MOOD TRACKER
CREATE TABLE mood_entries (
  id         UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id    UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  mood_score INTEGER NOT NULL CHECK (mood_score BETWEEN 1 AND 5),
  note       TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- CRISIS Y SEGURIDAD (append-only, anonimizado)
CREATE TABLE crisis_events (
  id         UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id    UUID NOT NULL REFERENCES auth.users(id),
  level      TEXT NOT NULL CHECK (level IN ('low', 'medium', 'high')),
  msg_hash   TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- PLANES Y LÍMITES
CREATE TABLE user_plans (
  user_id      UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  plan         TEXT DEFAULT 'free' CHECK (plan IN ('free', 'premium')),
  daily_limit  INTEGER DEFAULT 20,
  updated_at   TIMESTAMPTZ DEFAULT NOW()
);

-- INTERACCIONES PROACTIVAS (log)
CREATE TABLE interactions_log (
  id         UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id    UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  type       TEXT NOT NULL,  -- buenos_dias | checkin | llamada | recordatorio
  channel    TEXT NOT NULL,  -- push | whatsapp | in_app
  sent_at    TIMESTAMPTZ DEFAULT NOW()
);
```

---

## 🔀 NAVEGACIÓN Y RUTAS

### Rutas implementadas (GoRouter)

| Ruta | Nombre | Pantalla | Estado |
|------|--------|----------|--------|
| `/` | `splash` | `LandingScreen` | ✅ |
| `/login` | `login` | `LoginScreen` | ✅ |
| `/reset-password` | `resetPassword` | `ResetPasswordScreen` | ✅ |
| `/onboarding` | `onboarding` | `OnboardingScreen` | ✅ |
| `/home` | `companionHome` | `CompanionHomeScreen` | ✅ |
| `/home/chat` | `chat` | `ChatScreen` | ✅ |
| `/home/voice` | `voiceCall` | `VoiceCallScreen` | ✅ (UI base) |
| `/mood` | `mood` | `MoodTrackerScreen` | ✅ |
| `/profile` | `profile` | `ProfileScreen` | ✅ |
| `/legal` | `legal` | `LegalScreen` | ✅ |

### Lógica de Guards (auth redirect)

```
/ (splash) → si logueado + onboarding OK → /home
           → si logueado + sin onboarding  → /onboarding
           → si no logueado               → permanece en /
/login     → si logueado → /home
/home/**   → si no logueado → /login
            → si sin onboarding → /onboarding
```

### Navegación Adaptativa

- **Android/iOS** (< 720dp): `BottomNavigationBar` (Inicio · Ánimo · Perfil)
- **Web/Tablet** (≥ 720dp): `Sidebar` (Inicio · Chat · Ánimo · Perfil · Legal + Banner Premium)
- Detectado automáticamente via `EsPlatform.useSidebarNavigation`

---

## 🤖 WORKFLOWS N8N

### Arquitectura de Workflows

```
Flutter App → POST /webhook/chat
                  │
                  ▼
         echosoul-chat-proxy
              │        │
              ▼        ▼
    crisis-detector   memory-extractor (fire & forget)
              │        │
              ▼        ▼
         Supabase    Supabase
         (crisis_    (user_
          events)     memories)
```

### Workflows Implementados

| Archivo | Webhook | Función |
|---------|---------|---------|
| `echosoul-chat-proxy.json` | `POST /webhook/chat` | Orquestador principal. Llama a Claude Sonnet, maneja historial, devuelve `reply`, `is_crisis`, `tokens_used` |
| `echosoul-crisis-detector.json` | `POST /webhook/crisis-check` | Analiza texto con Claude Haiku. Clasifica nivel (low/medium/high). Alerta admin vía Slack si high |
| `echosoul-memory-extractor.json` | `POST /webhook/extract-memory` | Extrae memorias importantes del chat y las guarda en `user_memories`. Deduplicado por hash |

### Variables n8n requeridas

| Variable | Descripción |
|----------|------------|
| `SUPABASE_URL` | URL del proyecto Supabase |
| `SUPABASE_SERVICE_KEY` | Service Role Key (no la anon) |
| `CLAUDE_API_KEY` | API Key Anthropic |
| `N8N_BASE_URL` | URL pública de n8n |
| `UPGRADE_URL` | URL de pricing |
| `ADMIN_ALERT_WEBHOOK` | Slack Incoming Webhook para alertas de crisis |

### Payload Flutter → n8n

```dart
// En n8n_chat_repository_impl.dart
POST /webhook/chat
{
  "user_id":    "<uuid>",
  "session_id": "<uuid>",
  "message":    "<texto del usuario>",
  "plan_limit": 20
}

// Respuesta:
{
  "reply":       "<respuesta de EchoSoul>",
  "is_crisis":   false,
  "tokens_used": 342
}
```

---

## 🎨 SISTEMA DE DISEÑO

### Principios
- **Dark mode first** (fondo `#0F0E17`)
- **Paleta azul-cian**: `primaryBlue` + `neonCyan` como acentos
- **Glassmorphism** en cards y overlays
- **Animaciones suaves** (micro-interactions, duración 180-300ms)
- **Tipografía**: Inter / SF Pro (sistema)

### Tokens de Color (EsColors)
```dart
backgroundDark    → #0F0E17
surfaceDark       → #1A1929
surfaceElevated   → #252438
primaryBlue       → #3B82F6
neonCyan          → #2DD4BF
textPrimaryDark   → #F1F0FF
textSecondaryDark → #9B99B5
divider           → #2A2940
```

### Componentes Atómicos implementados
- `EsButton` — Botón con variantes (primary, secondary, ghost)
- `EsTypography` — Sistema tipográfico completo
- `EsColors` — Tokens de color

---

## 📊 ESTADO ACTUAL DEL DESARROLLO

### ✅ FASE 0 — Infraestructura Base (COMPLETADA)

- [x] Proyecto Flutter creado con Clean Architecture
- [x] Supabase configurado (Auth + DB)
- [x] GitHub Actions → Vercel CI/CD pipeline
- [x] Autenticación Email + contraseña
- [x] Reset de contraseña (implicit flow, PKCE resuelto)
- [x] Sistema de routing GoRouter con auth guards
- [x] Detección de plataforma (`EsPlatform`)
- [x] Logo integrado en sidebar y app

### ✅ FASE 1 — MVP Web (MAYORMENTE COMPLETADA)

- [x] Landing Screen (Flutter Web splash)
- [x] Landing Page externa (Vite, estilo Replika)
- [x] Navegación adaptativa (Sidebar web / BottomNav mobile)
- [x] ChatScreen básico conectado a n8n
- [x] CompanionHomeScreen con Dashboard
- [x] OnboardingScreen (multi-step con preferencias)
- [x] MoodTrackerScreen con gráfica de tendencia
- [x] ProfileScreen
- [x] LegalScreen (Términos + Privacidad)
- [x] VoiceCallScreen (UI base implementada)
- [x] n8n workflows base (chat, crisis, memoria)
- [x] Deploy estable en Vercel con SPA routing
- [ ] Dominio custom configurado en Vercel
- [ ] Google Sign-In funcional en web

### 🎯 FASE 2 — MVP Android (PENDIENTE)

- [ ] Google Sign-In nativo (android/app/google-services.json)
- [ ] FCM Push Notifications configurado
- [ ] Workflow n8n: Buenos Días (trigger cron matutino)
- [ ] Workflow n8n: Check-in emocional (trigger por estado)
- [ ] Workflow n8n: Llamada proactiva (Retell/Vapi)
- [ ] Integración Retell AI o Vapi.ai para voz
- [ ] VoiceCallScreen conectado a servicio real
- [ ] Modo offline con Hive (cache local de mensajes)
- [ ] Build AAB firmado → Google Play Console
- [ ] Data Safety Form completado en Play Console

### 💳 FASE 3 — Monetización (PENDIENTE)

- [ ] Google Play Billing integrado
- [ ] Paddle para pagos web
- [ ] Tabla `user_plans` con límites por plan
- [ ] Lógica free vs premium en app
- [ ] Webhook n8n para sincronizar suscripción → Supabase
- [ ] UI de paywall y upgrade

### 🛡️ FASE 4 — Ética y Cumplimiento (PENDIENTE)

- [ ] Sistema de crisis completo (3 niveles)
- [ ] Respuestas de emergencia con recursos reales (números de crisis)
- [ ] Límites diarios de interacción configurables
- [ ] Opción "pausar compañero"
- [ ] GDPR: exportar datos del usuario (JSON)
- [ ] GDPR: eliminar cuenta + todos los datos
- [ ] Disclaimers éticos en todos los puntos de entrada
- [ ] Política de Privacidad publicada (URL pública)
- [ ] Términos y Condiciones publicados (URL pública)
- [ ] Play Store review final

### 🚀 FASE 5 — Post-MVP (FUTURO)

- [ ] Memoria vectorial (pgvector en Supabase)
- [ ] Challenges IRL ("hoy intenta llamar a un amigo")
- [ ] Integración calendario
- [ ] Notificaciones WhatsApp (Twilio)
- [ ] iOS (App Store)
- [ ] Comunidad entre usuarios (TBD)
- [ ] Multi-idioma (inglés)

---

## ⚙️ VARIABLES DE ENTORNO

### echosoul/.env (Flutter)

```env
SUPABASE_URL=https://xxxx.supabase.co
SUPABASE_ANON_KEY=eyJh...
AUTH_REDIRECT_URL=https://echosoul.vercel.app/reset-password
N8N_CHAT_WEBHOOK_URL=https://n8n.tudominio.com/webhook/chat
```

### GitHub Actions Secrets

```
SUPABASE_URL
SUPABASE_ANON_KEY
AUTH_REDIRECT_URL
N8N_CHAT_WEBHOOK_URL
VERCEL_TOKEN
VERCEL_ORG_ID
VERCEL_PROJECT_ID
```

---

## 🔧 REGLAS DE DESARROLLO

### Principios Arquitectónicos
1. **UI tonta** — Las pantallas solo renderizan estado, nunca lógica de negocio
2. **Lógica ciega** — Los providers/use cases no saben nada de la UI
3. **Automatizaciones separadas** — n8n es una capa independiente, nunca lógica mixta
4. **Wrappers siempre** — Nunca llamar directamente a Supabase/Claude/Retell desde UI. Usar repositorios
5. **`EsPlatform` siempre** — Nunca usar `kIsWeb` directamente en features

### Convenciones de Código

```dart
// ✅ Correcto — usar EsPlatform
if (EsPlatform.supportsVoiceCalls) { ... }

// ❌ Incorrecto
if (!kIsWeb) { ... }
```

### Checklist antes de cada commit
- [ ] ¿Respeto Clean Architecture (Presentation / Domain / Data)?
- [ ] ¿Es ético y seguro para datos de salud mental?
- [ ] ¿Funciona correctamente con n8n?
- [ ] ¿Los estados Loading/Error/Empty/Success están manejados?
- [ ] ¿No hay lógica hardcodeada en widgets?

---

## 🚦 CRITERIOS DE ACEPTACIÓN MVP

Para considerar el MVP listo para Play Store:

1. ✅ Usuario puede registrarse con email
2. 🔲 Usuario puede registrarse con Google
3. ✅ Chat fluido con EchoSoul (respuestas IA via n8n)
4. ✅ Memoria a largo plazo funcional
5. 🔲 Buenos días / check-ins proactivos (FCM + n8n cron)
6. 🔲 Llamadas de voz proactivas funcionales
7. ✅ Mood tracker operativo
8. ✅ Disclaimers éticos visibles
9. 🔲 Manejo de crisis con recursos reales
10. 🔲 Política de Privacidad y Términos en URL pública
11. 🔲 App firmada y subida a Play Console
12. 🔲 Data Safety Form completado

---

## 📞 REFERENCIA RÁPIDA DE SKILLS DISPONIBLES

| Skill | Cuándo usarla |
|-------|--------------|
| `echosoul-flutter-lead` | Implementar features Flutter, revisar arquitectura |
| `echosoul-automation-specialist` | Diseñar/depurar workflows n8n |
| `echosoul-data-architect` | Diseñar tablas, RLS, migraciones Supabase |
| `echosoul-ethical-ai-strategist` | Prompts del companion, manejo de crisis |
| `echosoul-landing-architect` | Landing page web |
| `n8n-mcp-tools-expert` | Usar herramientas MCP de n8n |
| `n8n-expression-syntax` | Sintaxis de expresiones n8n |
| `n8n-code-javascript` | Código JavaScript en nodos n8n |

---

*Documento generado automáticamente consolidando todos los planes de conversaciones previas.  
Mantener actualizado con cada sprint completado.*
