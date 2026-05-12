# EchoSoul — Arquitectura Multi-Plataforma

> **Versión:** 2.0 | **Fecha:** Mayo 2026 | **Autor:** Serquin + Antigravity

---

## Decisión Central: Dos Experiencias, Un Backend

EchoSoul opera con **una sola base de código Flutter** y **un único backend (Supabase + n8n)**,  
pero presenta **dos experiencias diferenciadas** según el canal:

| Dimensión | Android (Play Store) | Web (Vercel) |
|---|---|---|
| Propósito | Compañía íntima diaria | Adquisición, onboarding, billing |
| Notificaciones | FCM Push nativas | Email fallback |
| Voz proactiva | ✅ Retell / Vapi | ❌ No disponible |
| Modo offline | ✅ Cache local | ❌ No |
| Pagos | Google Play Billing | Paddle (web) |
| Navegación | Bottom Navigation Bar | Sidebar |
| Target | Usuario habitual | Usuario nuevo |

---

## Infraestructura

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
git push → GitHub Actions → flutter build web → Vercel (CDN)
                          → flutter build aab  → Google Play Console
```

---

## Detección de Plataforma en Código

```dart
// core/utils/es_platform.dart
EsPlatform.isWeb                  // true en navegador
EsPlatform.supportsVoiceCalls     // false en web
EsPlatform.useSidebarNavigation   // true en web (y tablets anchos ≥720dp)
```

Nunca uses `kIsWeb` directamente en código de feature — usa siempre `EsPlatform`.

---

## Navegación

- **Android/iOS:** `BottomNavigationBar` (Inicio · Ánimo · Perfil)
- **Web/Tablet:** `Sidebar` (Inicio · Chat · Ánimo · Perfil · Legal + Banner Premium)

La detección es automática en `MainLayoutScreen` usando `EsPlatform` + breakpoint de `720dp`.

---

## Features por Plataforma

| Feature | Android | Web |
|---|---|---|
| Chat texto | ✅ | ✅ |
| Voz proactiva | ✅ | ❌ |
| Push notifications | ✅ (FCM) | ❌ (email fallback) |
| Mood tracker | ✅ | ✅ |
| Dashboard stats | ✅ | ✅ |
| Onboarding | ✅ | ✅ |
| Billing | Google Play | Paddle |
| Offline | ✅ | ❌ |
| Google Sign-In | ✅ | ✅ |

---

## Roadmap por Fases

### ✅ Fase 0 — Infraestructura Base (Completado)
- Flutter Web + GitHub Actions + Vercel deploy
- Auth (email + recuperación contraseña)
- Pantallas: Login, Register, Reset Password, Profile básica

### 🎯 Fase 1 — MVP Web (En progreso)
- Navegación adaptativa (Sidebar web / Bottom nav mobile)
- Chat básico conectado a n8n
- Onboarding web
- Dominio custom en Vercel

### 📱 Fase 2 — MVP Android
- FCM + workflows proactivos n8n
- Mood tracker completo
- Llamadas de voz (Retell / Vapi)
- Google Sign-In nativo
- Build AAB → Play Console

### 💳 Fase 3 — Monetización
- Paddle (web) + Google Play Billing (Android)
- Plan Free vs Premium
- Webhooks n8n para sincronizar suscripción en Supabase

### 🛡️ Fase 4 — Ética y Cumplimiento
- Sistema de crisis completo
- Límites de uso configurables
- GDPR: exportar/eliminar datos
- Play Store review: Privacy Policy, Data Safety Form

### 🚀 Fase 5 — Post-MVP
- Memoria avanzada (vector embeddings)
- Challenges IRL
- Comunidad (TBD)
- iOS
