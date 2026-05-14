# Refactorización de Infraestructura n8n — EchoSoul

Se ha completado la estandarización y endurecimiento de los flujos de n8n que gestionan el ciclo de vida del usuario.

## 🚀 Cambios Realizados

### 1. Centralización de Configuración (Seguridad)
*   **Supabase:** Se eliminaron todas las URLs (`https://pleeiqlldiwipaxqoumu.supabase.co`) y claves `service_role` de los nodos. Ahora todos los flujos usan `$env.SUPABASE_URL` y `$env.SUPABASE_SERVICE_KEY`.
*   **App URL:** Se configuró una variable `$env.APP_URL` con fallback automático a la URL de Vercel (`https://echosoul-one.vercel.app`).

### 2. Pipeline de Onboarding
*   **Workflow: `NewUser-welcome` [ACTIVO 🟢]**
    *   Asignación de credenciales Gmail (`XI4mlfkFZGAD9dyL`).
    *   Lógica de creación de perfil, plan y registro de onboarding en Supabase.
    *   Manejo de errores modernizado (`onError: continueRegularOutput`).
*   **Workflow: `drip sequence` [ACTIVO 🟢]**
    *   **Migración FCM v1:** Actualizado del sistema Legacy al endpoint moderno de Google.
    *   **Credenciales de Firebase:** Se creó la credencial `0o4FmPorago01fiu` (Google Cloud Service Account) usando el JSON de administración de Firebase. Esto elimina la necesidad de tokens manuales.

### 3. Mantenimiento y Estabilidad
*   Actualización de `typeVersion` en nodos HTTP, Webhook y Gmail para usar las últimas capacidades de n8n.
*   Implementación de `resolution=merge-duplicates` en las peticiones a Supabase para evitar errores si el usuario ya existe.

---

## 🛠️ Requisitos en Dokploy (Variables de Entorno)
Para que los flujos operen correctamente en producción, asegúrate de que n8n tenga acceso a:
*   `SUPABASE_URL`
*   `SUPABASE_SERVICE_KEY`
*   `FCM_PROJECT_ID` (`echosoul-f2b89`)
*   `APP_URL` (`https://echosoul-one.vercel.app`)

---

## 🧪 Cómo verificar que funciona
Puedes probar el flujo de registro enviando este comando desde tu terminal (PowerShell):

```powershell
Invoke-RestMethod -Uri "https://n8n.cheosdesign.info/webhook/new-user" `
  -Method Post `
  -ContentType "application/json" `
  -Body '{"user_id": "00000000-0000-0000-0000-000000000000", "email": "tu-email@ejemplo.com", "display_name": "Tester", "platform": "web"}'
```

Si todo es correcto:
1.  Recibirás un JSON con `{"status":"ok"}`.
2.  Aparecerá un nuevo registro en tu tabla `user_profiles` de Supabase.
3.  Te llegará un email de bienvenida.

---

## 📌 Pendientes
*   [ ] **Android:** Colocar `google-services.json` en `android/app/` antes de compilar.
*   [ ] **FCM Testing:** Una vez compilada la app, enviar un token real para probar las notificaciones push.
