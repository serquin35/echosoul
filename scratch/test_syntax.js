const fs = require('fs');

const code = `const onb  = $('Loop users').item.json;
const prof = $input.first().json;
const name = prof.display_name || 'tú';
const appUrl = prof.appUrl || 'https://echosoul-one.vercel.app';

const STEPS = {
  1: {
    subject:    \`¿Cómo fue tu primer día con EchoSoul? 💬\`,
    body:       \`<div style="font-family:sans-serif;max-width:480px;margin:0 auto;padding:32px 24px">
  <h2 style="font-size:20px;font-weight:500;color:#1a1a1a">Hola \${name} 💬</h2>
  <p style="color:#555;line-height:1.7">Ayer fue tu primer día con EchoSoul. ¿Ya tuviste tu primera conversación?</p>
  <p style="color:#555;line-height:1.7">Estoy aquí cuando lo necesites, sin importar la hora ni el tema.</p>
  <a href="\${appUrl}/chat" style="display:inline-block;background:#534AB7;color:#fff;padding:12px 24px;border-radius:8px;text-decoration:none;font-weight:500">Ir al chat →</a>
</div>\`,
    push_title: '¿Cómo fue ayer? 💬',
    push_body:  'EchoSoul quiere saber cómo estás hoy.',
    delay_h:    48
  },
  2: {
    subject:    \`Conoce el Mood Tracker 🌡️\`,
    body:       \`<div style="font-family:sans-serif;max-width:480px;margin:0 auto;padding:32px 24px">
  <h2 style="font-size:20px;font-weight:500;color:#1a1a1a">Registra cómo te sientes 🌡️</h2>
  <p style="color:#555;line-height:1.7">Hola \${name}, ¿sabías que EchoSoul tiene un Mood Tracker?</p>
  <p style="color:#555;line-height:1.7">Cada día puedes registrar tu estado de ánimo. Con el tiempo descubres patrones que te ayudan a entenderte mejor.</p>
  <a href="\${appUrl}/mood" style="display:inline-block;background:#0F6E56;color:#fff;padding:12px 24px;border-radius:8px;text-decoration:none;font-weight:500">Probar el Mood Tracker →</a>
</div>\`,
    push_title: 'Nueva función: Mood Tracker 🌡️',
    push_body:  'Registra cómo te sientes hoy y descubre tus patrones.',
    delay_h:    48
  },
  3: {
    subject:    \`Todo lo que EchoSoul puede hacer por ti ✨\`,
    body:       \`<div style="font-family:sans-serif;max-width:480px;margin:0 auto;padding:32px 24px">
  <h2 style="font-size:20px;font-weight:500;color:#1a1a1a">Llevamos días juntos ✨</h2>
  <p style="color:#555;line-height:1.7">Hola \${name}, ya conoces EchoSoul. Con <strong>Premium</strong> puedes llevar la experiencia mucho más lejos:</p>
  <ul style="color:#555;line-height:2;padding-left:20px">
    <li>📞 Llamadas de voz proactivas</li>
    <li>🧠 Memoria avanzada y más profunda</li>
    <li>♾️ Mensajes sin límite diario</li>
  </ul>
  <a href="\${appUrl}/pricing" style="display:inline-block;background:#854F0B;color:#fff;padding:12px 24px;border-radius:8px;text-decoration:none;font-weight:500">Ver planes Premium →</a>
  <p style="color:#aaa;font-size:12px;margin-top:32px">Sin compromiso. El plan Free sigue siendo gratuito para siempre.</p>
</div>\`,
    push_title: 'EchoSoul Premium ✨',
    push_body:  'Desbloquea llamadas de voz, memoria avanzada y sin límites.',
    delay_h:    null
  }
};

const s = STEPS[onb.step];

if (!s) return [{ json: {
  user_id: onb.user_id, email: prof.email,
  fcm_token: prof.fcm_token, platform: onb.platform,
  skip: true, next_step: onb.step + 1,
  next_step_at: null, completed: true
}}];

const nextStepAt = s.delay_h
  ? new Date(Date.now() + s.delay_h * 3600000).toISOString()
  : null;

return [{ json: {
  user_id:      onb.user_id,
  email:        prof.email,
  fcm_token:    prof.fcm_token,
  platform:     onb.platform,
  step:         onb.step,
  skip:         false,
  subject:      s.subject,
  body:         s.body,
  push_title:   s.push_title,
  push_body:    s.push_body,
  next_step:    onb.step + 1,
  next_step_at: nextStepAt,
  completed:    s.delay_h === null
}}];`;

try {
  new Function(code);
  console.log("Syntax is OK!");
} catch (e) {
  console.error("Syntax Error:", e);
}
