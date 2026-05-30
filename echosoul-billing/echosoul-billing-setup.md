# EchoSoul — Guía Billing Workflows

## Orden de importación
```
1. echosoul-billing-paddle-webhook.json
2. echosoul-billing-google-play-rtdn.json
3. echosoul-billing-subscription-sync.json
```

## SQL previo — crear tabla subscriptions

```sql
CREATE TABLE subscriptions (
  id              UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id         UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  provider        TEXT NOT NULL CHECK (provider IN ('paddle', 'google_play')),
  provider_sub_id TEXT,
  status          TEXT NOT NULL DEFAULT 'active',
  plan_id         TEXT,
  expires_at      TIMESTAMPTZ,
  raw_event       JSONB,
  created_at      TIMESTAMPTZ DEFAULT NOW(),
  updated_at      TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, provider)
);

CREATE INDEX ON subscriptions (user_id, provider);
CREATE INDEX ON subscriptions (provider_sub_id) WHERE provider_sub_id IS NOT NULL;
```

## Placeholders a reemplazar en los JSON

| Placeholder | Donde | Valor |
|---|---|---|
| `PADDLE_WEBHOOK_SECRET` | paddle-webhook → Verify signature | Paddle Dashboard → Developer Tools → Notifications → tu webhook → Secret key |
| `YOUR_PADDLE_API_KEY` | subscription-sync → Fetch Paddle active subs | Paddle Dashboard → Developer Tools → Authentication → API key |
| `YOUR_SUPABASE_SERVICE_KEY` | Todos los nodos Supabase | Tu service_role key |

## Configurar Paddle Dashboard (v2)

1. **Developer Tools → Notifications → New Notification**
2. URL: `https://n8n.cheosdesign.info/webhook/paddle`
3. Eventos a activar:
   - `subscription.created`
   - `subscription.updated`
   - `subscription.canceled`
   - `transaction.completed`
   - `transaction.payment_failed`
4. Copia el **Secret key** generado → ponlo en `PADDLE_WEBHOOK_SECRET`

## custom_data en Flutter — crítico para paddle-webhook

El webhook necesita saber qué usuario de EchoSoul hizo la compra.
Paddle lo permite via `custom_data` en el checkout:

```dart
// Al abrir el checkout de Paddle desde Flutter Web
final checkoutUrl = 'https://buy.paddle.com/product/YOUR_PRICE_ID'
    '?custom_data[user_id]=${supabase.auth.currentUser!.id}';
// O usando el SDK de Paddle JS con customData
```

Sin `custom_data.user_id`, el webhook no puede vincular el pago al usuario.

## Google Play RTDN — solo cuando el AAB esté publicado

1. Google Cloud Console → Pub/Sub → Crear topic
2. Crear suscripción PUSH apuntando a `https://n8n.cheosdesign.info/webhook/google-play`
3. Play Console → Monetización → Configuración → vincular el topic
4. Activar el workflow `google-play-rtdn` en n8n

## Cómo funciona el lookup de usuario en Google Play

La app Flutter debe guardar el `purchaseToken` en Supabase cuando inicia una compra,
ANTES de que Google Play confirme. Así cuando llega el RTDN, n8n puede encontrar
el user_id buscando ese token:

```dart
// Guardar purchase_token al iniciar la compra
await supabase.from('subscriptions').upsert({
  'user_id':         supabase.auth.currentUser!.id,
  'provider':        'google_play',
  'provider_sub_id': purchaseDetails.purchaseID,  // el purchaseToken
  'status':          'pending',
});
```

## Verificación de firma Paddle — activar en producción

En el nodo **Verify signature**, la verificación está lista pero desactivada mientras
`secret === 'PADDLE_WEBHOOK_SECRET'` (literal). Una vez que reemplaces con tu secret
real, la verificación se activa automáticamente.
