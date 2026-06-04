# Walkthrough — Productos, Precios y Puesta a Punto en Lemon Squeezy

## Fase 1: Crear Producto y Variantes en Lemon Squeezy

### 1.1 Crear el Producto

1. Ve a **Lemon Squeezy Dashboard → Products**.
2. Haz clic en **"Create Product"**.
3. Configura:
   - **Name:** `EchoSoul Premium`
   - **Description:** `Desbloquea mensajes ilimitados, memoria a largo plazo, llamadas de voz e interacciones proactivas con tu companion IA.`
   - **Tax category:** `Software as a Service (SaaS)`
4. Haz clic en **"Save Product"**.

### 1.2 Crear las Variantes (Planes)

Dentro del producto recién creado, crea **dos variantes**:

#### Variante 1 — Mensual
- **Name:** `Mensual`
- **Pricing model:** `Recurring`
- **Interval:** `Monthly`
- **Price:** `€4.99 EUR`
- **Is subscription:** ✅ Yes

#### Variante 2 — Anual (destacado)
- **Name:** `Anual`
- **Pricing model:** `Recurring`
- **Interval:** `Yearly`
- **Price:** `€39.99 EUR`
- **Is subscription:** ✅ Yes

### 1.3 Obtener los IDs de Variante

Una vez creadas, cada variante tendrá una URL de checkout como:
```
https://echosoul.lemonsqueezy.com/checkout/buy/XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX
```
Guarda los IDs (`XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX`) de **cada variante**:
- **Variant ID Mensual:** `__________` (véase más adelante)
- **Variant ID Anual:** `__________` (véase más adelante)

### 1.4 Configurar el Webhook en Lemon Squeezy

1. **Lemon Squeezy Dashboard → Developer Settings → Webhooks**.
2. **"Create Webhook"**.
3. **URL:** `https://n8n.cheosdesign.info/webhook/lemonsqueezy`
4. **Eventos a suscribir:**
   - `subscription_created`
   - `subscription_updated`
   - `subscription_cancelled`
   - `subscription_expired`
5. **Signing secret:** Genera un secreto y **guárdalo** (lo necesitarás en n8n).

---

## Fase 2: Configurar las URLs de Checkout en el Código

> ⚠️ **Nota importante sobre Free:** No se crea un producto "Free" en Lemon Squeezy. Free es simplemente el estado por defecto del usuario cuando no tiene una suscripción activa. El sistema de n8n degrada a free automáticamente cuando una suscripción expira o se cancela.

### 2.1 upgrade.html

**Archivo:** `landing/public/upgrade.html`

En la sección de configuración del script (líneas 237-260), reemplaza los placeholders:

```js
// ANTES (placeholders):
const LS_MONTHLY_VARIANT_ID = 'VARIANT_ID_MENSUAL';
const LS_YEARLY_VARIANT_ID  = 'VARIANT_ID_ANUAL';
const LS_STORE_SLUG         = 'echosoul';

// DESPUÉS (con valores reales):
const LS_MONTHLY_VARIANT_ID = 'XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX'; // ID real
const LS_YEARLY_VARIANT_ID  = 'YYYYYYYY-YYYY-YYYY-YYYY-YYYYYYYYYYYY'; // ID real
const LS_STORE_SLUG         = 'echosoul';
```

> El `LS_STORE_SLUG` es el subdominio de tu tienda LS (ej: `echosoul.lemonsqueezy.com` → slug = `echosoul`).

### 2.2 paywall_screen.dart

**Archivo:** `echosoul/lib/features/billing/presentation/screens/paywall_screen.dart`

Si despliegas en web con Flutter Web, puedes pasar las URLs de checkout como variables de entorno de compilación:

```bash
# Compilación web
flutter build web \
  --dart-define=LS_CHECKOUT_MONTHLY_URL=https://echosoul.lemonsqueezy.com/checkout/buy/MENSUAL_ID \
  --dart-define=LS_CHECKOUT_YEARLY_URL=https://echosoul.lemonsqueezy.com/checkout/buy/ANUAL_ID
```

Sin estas variables, los defaults apuntan a `https://echosoul.one/upgrade?plan=...` que redirige al `upgrade.html`.

---

## Fase 3: Verificar Workflows de n8n

### 3.1 Webhook (lemonsqueezy-webhook)

1. En n8n, abre el workflow **"EchoSoul — billing: lemonsqueezy-webhook"**.
2. Nodo **"Verify signature"** — asegúrate de que la variable `secret` tenga el **Signing Secret** real de LS (no el placeholder `'LEMONSQUEEZY_WEBHOOK_SECRET'`).
3. Verifica que los nodos **"Upsert subscription"** y **"Update user plan"** tengan credenciales válidas de Supabase.
4. Guarda y activa el workflow.

### 3.2 Sync Diario (lemonsqueezy-sync)

1. En n8n, abre **"EchoSoul — billing: lemonsqueezy-sync"**.
2. Nodo **"Fetch Lemon Squeezy active subs"** — reemplaza `YOUR_LEMONSQUEEZY_API_KEY` por tu **API key real** de LS (Dashboard → Settings → API → Generate API key).
3. Asegúrate de que los nodos de Supabase tengan credenciales válidas.
4. Guarda y activa el workflow.

### 3.3 daily_limit unificado

Todos los workflows ahora usan `daily_limit: 9999` para premium (en lugar de los valores inconsistentes anteriores: 999, 99999). Free se mantiene en `20`. Esto ya está actualizado en los archivos JSON locales; si ya importaste los workflows en n8n, haz los mismos cambios manualmente en los nodos de código:

| Workflow | Nodo | Valor anterior | Nuevo valor |
|---|---|---|---|
| lemonsqueezy-webhook | Parse event | 99999 | 9999 |
| lemonsqueezy-sync | Find discrepancies | 99999 | 9999 |
| paddle-webhook | Parse event | 999 | 9999 |
| subscription-sync | Find discrepancies | 999 | 9999 |

---

## Fase 4: Resumen de Cambios en el Código

| Archivo | Cambio |
|---|---|
| `paywall_screen.dart` | Convertido a `ConsumerStatefulWidget` con toggle Mensual/Anual, precios €4.99/€39.99, voz como primer feature |
| `upgrade.html` | Dos tarjetas de precio con LS checkout directo, sin Paddle SDK, voz primero |
| `app_localizations_es.dart` | paywallVoiceCalls → "Llamadas de Voz" (sin "Próximamente") |
| `app_localizations_en.dart` | paywallVoiceCalls → "Voice Calls" (sin "Coming Soon") |
| `lemonsqueezy-webhook.json` | daily_limit: 99999 → 9999 |
| `lemonsqueezy-sync.json` | daily_limit: 99999 → 9999 |
| `paddle-webhook.json` | daily_limit: 999 → 9999 |
| `subscription-sync.json` | daily_limit: 999 → 9999 |

---

## Fase 5: Orden de Puesta en Marcha

1. Crear producto y variantes en LS (Fase 1)
2. Configurar webhook en LS (Fase 1.4)
3. Importar workflows a n8n (si no lo están ya)
4. Poner credenciales reales en n8n (API key de LS, Supabase, signing secret)
5. Actualizar upgrade.html con IDs de variante reales (Fase 2.1)
6. Compilar Flutter Web con --dart-define (Fase 2.2)
7. Activar ambos workflows en n8n
8. Probar: abrir paywall en la app, hacer clic en "Iniciar Suscripción", completar pago en LS, verificar que n8n actualiza Supabase
