# EchoSoul — Arquitectura Multi-Plataforma

> **Versión:** 2.1 | **Fecha:** Mayo 2026 | **Autor:** Serquin + Antigravity
> 📌 Estado de fases y hitos → ver `ECHOSOUL_MASTER_PLAN.md`

---

## Decisión Central: Dos Experiencias, Un Backend

EchoSoul opera con **una sola base de código Flutter** y **un único backend (Supabase + n8n)**,
pero presenta **dos experiencias diferenciadas** según el canal:

| Dimensión | Android (Play Store) | Web (Vercel) |
|---|---|---|
| Propósito | Compañía íntima diaria | Adquisición, onboarding, billing |
| Notificaciones | FCM Push nativas | Email fallback |
| Voz proactiva | ✅ Retell / Vapi | ❌ No disponible |
| Modo offline | ✅ Cache local (Hive) | ❌ No |
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
                           → flutter build aab → Google Play Console
```

---

## Detección de Plataforma en Código

```dart
// core/utils/es_platform.dart
EsPlatform.isWeb                  // true en navegador
EsPlatform.supportsVoiceCalls     // false en web
EsPlatform.useSidebarNavigation   // true en web (y tablets anchos ≥720dp)
```

> **Regla:** Nunca uses `kIsWeb` directamente en código de feature — usa siempre `EsPlatform`.

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
| Voz proactiva | ✅ (pendiente Retell/Vapi) | ❌ |
| Push notifications | ✅ FCM (pendiente test real) | ❌ (email fallback) |
| Mood tracker | ✅ | ✅ |
| Dashboard stats | ✅ | ✅ |
| Onboarding | ✅ | ✅ |
| Billing | Google Play Billing | Paddle |
| Offline | ✅ (pendiente Hive cache) | ❌ |
| Google Sign-In | ✅ (pendiente activar) | ✅ (pendiente activar) |

---

## Estructura de Carpetas Flutter

```
lib/
├── core/
│   ├── config/         # Constantes de entorno
│   ├── constants/      # Valores globales
│   ├── errors/         # Clases de error compartidas
│   ├── router/         # app_router.dart + route_names.dart
│   ├── services/       # Servicios base (Supabase, HTTP)
│   ├── theme/          # AppTheme, colores, tipografía
│   └── utils/          # EsPlatform, helpers
├── features/
│   ├── auth/           # Login, Reset Password
│   ├── companion/      # Home, Chat, Layout, Voice UI
│   ├── landing/        # Landing page web
│   ├── legal/          # Política + T&C
│   ├── mood/           # Mood Tracker
│   ├── onboarding/     # Flujo onboarding
│   └── profile/        # Perfil de usuario
└── shared/             # Widgets compartidos
```

Cada feature sigue Clean Architecture: `presentation/` → `domain/` → `data/`

---

## Principios de Diseño

1. **UI tonta** — Pantallas solo renderizan estado del provider
2. **Lógica ciega** — Providers/use cases sin conocimiento de UI
3. **`EsPlatform`** — Wrapper de plataforma, nunca `kIsWeb` en features
4. **Wrappers** — Repositorios entre UI y APIs externas (n8n, FCM, Voz)
5. **Mobile-first + Dark Mode** — Diseño base en Android, adaptado a web
