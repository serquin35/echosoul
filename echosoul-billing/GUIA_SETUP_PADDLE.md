# Guía de Configuración de Paddle para EchoSoul

## 1. Crear cuenta en Paddle Sandbox

Ve a **https://sandbox-vendors.paddle.com/** y regístrate o inicia sesión.

> ⚠️ Usa el entorno **Sandbox** para todas las pruebas. Después pones los valores reales en producción.

---

## 2. Crear el Producto

**Menú:** Catalog → Products → Create Product

| Campo | Valor |
|-------|-------|
| Name | **EchoSoul Premium** |
| Description | "Desbloquea mensajes ilimitados, memoria a largo plazo y notificaciones proactivas con tu companion IA." |
| Image | (opcional) Logo de EchoSoul |
| Tax Category | **Software as a Service (SaaS)** |

Guarda el producto. Se te asignará un `PRODUCT_ID`.

---

## 3. Crear el Precio / Plan de Suscripción

Estando dentro del producto, ve a **Prices → Add Price**:

| Campo | Valor |
|-------|-------|
| Name | **Premium Mensual** |
| Billing Cycle | **Monthly** (cada mes) |
| Price | **$9.99 USD** (o el que decidas) |
| Currency | USD |

Al guardar, se te asignará un **Price ID** con formato `pri_01xxxxxxxxxxxxx`.

**⟹ COPIA ESTE PRICE ID** y ponlo en `upgrade.html` → `PADDLE_PRICE_ID`

---

## 4. Configurar el Webhook en Paddle

**Menú:** Developer Tools → Notifications → Create Notification

| Campo | Valor |
|-------|-------|
| URL | `https://n8n.cheosdesign.info/webhook/paddle` |
| Events | Marca estos: |
| | ✅ `subscription.created` |
| | ✅ `subscription.updated` |
| | ✅ `subscription.canceled` |
| | ✅ `transaction.completed` |
| | ✅ `transaction.payment_failed` |

Al guardar, Paddle te mostrará un **Secret Key**. 

**⟹ COPIA ESTE SECRET KEY** — lo necesitas para:
1. Ponerlo en el workflow de n8n (`PADDLE_WEBHOOK_SECRET`)
2. O si lo configuras después, en el dashboard de n8n como variable de entorno

---

## 5. Obtener el Client Token

**Menú:** Developer Tools → Authentication

Aquí verás tu **Client-Side Token** (empieza con `sp_clt_...`).

**⟹ COPIA ESTE TOKEN** y ponlo en `upgrade.html` → `PADDLE_CLIENT_TOKEN`

---

## 6. Resumen: Valores que necesitas copiar

| Variable | Dónde se usa | Dónde obtenerla |
|----------|-------------|-----------------|
| `PADDLE_CLIENT_TOKEN` | `upgrade.html` (línea 240) | Paddle Dashboard → Developer Tools → Authentication |
| `PADDLE_PRICE_ID` | `upgrade.html` (línea 241) | Catalog → Product → Prices → ID del precio |
| `PADDLE_WEBHOOK_SECRET` | n8n workflow (paddle-webhook) | Developer Tools → Notifications → tu webhook → Secret key |
| `YOUR_PADDLE_API_KEY` | n8n workflow (subscription-sync) | Developer Tools → Authentication → API Key (Server-side) |

---

## 7. Probar en Sandbox

1. En Paddle Sandbox, hay tarjetas de prueba disponibles:
   - **Paypal:** `paypal-test@example.com`
   - **Tarjeta visa:** `4242 4242 4242 4242` con fecha futura y CVC cualquiera
2. Abre `https://echosoul.one/upgrade?user_id=UN_USER_ID_REAL`
3. Pulsa "Iniciar Suscripción"
4. Completa el pago con tarjeta de prueba
5. Verifica que el webhook llega a n8n y actualiza Supabase en tiempo real
6. Abre la app Flutter y verifica que el plan cambia a Premium

---

## 8. Pasar a Producción

Cuando todo funcione en Sandbox:

1. Ve a **https://vendors.paddle.com/** (producción)
2. Crea el mismo producto y precio en producción
3. Configura el mismo webhook en producción
4. Reemplaza en `upgrade.html`:
   - `PADDLE_SANDBOX = false`
   - `PADDLE_CLIENT_TOKEN` → el de producción
   - `PADDLE_PRICE_ID` → el de producción
5. Actualiza `PADDLE_WEBHOOK_SECRET` en n8n con el de producción
