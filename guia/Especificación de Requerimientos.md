# Especificación Técnica: Acompañante Virtual Proactivo

**Nombre de la App:** EchoSoul (provisional - puedes cambiarlo)  
**Nombre Alternativos:** AlmaVoice, AcompañoAI, Sereno  
**Autor:** Serquin (adaptado con Grok)  
**Versión:** 1.0 MVP  
**Fecha:** Mayo 2026

## 1. VISIÓN GENERAL DEL PROYECTO

### 1.1 Descripción
Aplicación móvil Android-first de **acompañante virtual proactivo** impulsada por IA que ayuda a combatir la soledad mediante interacciones empáticas, mensajes automáticos, llamadas de voz y check-ins emocionales personalizados. El usuario siente que tiene un compañero que se preocupa por él.

### 1.2 Objetivos
- Reducir la sensación de soledad mediante compañía virtual consistente y proactiva.
- Ofrecer soporte emocional accesible 24/7 de forma responsable.
- Crear una experiencia que se sienta humana y cálida.
- Mantener altos estándares éticos y de seguridad.
- Lograr buena retención y satisfacción del usuario.

### 1.3 Alcance MVP

**Incluido en MVP:**
- Autenticación (Email + **Google Sign-In**)
- Onboarding completo con configuración de preferencias
- Check-ins diarios proactivos (mensajes y voz)
- Chat conversacional con memoria
- Llamadas de voz proactivas cortas
- Mood tracker simple
- Buenos días / Buenas noches personalizados
- Automatizaciones con n8n
- Disclaimers éticos y manejo básico de crisis
- Cumplimiento completo para publicación en Play Store (Privacidad, Términos, etc.)
- Persistencia en Supabase

**Fuera del alcance inicial:**
- Comunidad entre usuarios
- Video llamadas
- Soporte multi-idioma (empezar solo español)
- Gestión avanzada de equipos o terapeutas

## 2. REQUERIMIENTOS FUNCIONALES

### 2.1 Autenticación y Gestión de Usuarios

**RF-001: Registro de Usuario**
- Opción principal: **Continuar con Google** (recomendado)
- Opción secundaria: Email + contraseña
- Extracción automática de nombre y foto desde Google
- Validaciones y creación de perfil en Supabase

**RF-002: Login de Usuario**
- Continuar con Google
- Email + contraseña
- Recuperación de contraseña

**RF-003: Logout y Eliminación de Cuenta**
- Opción de eliminar cuenta completa (con confirmación y borrado de datos)

**RF-004: Onboarding Inicial**
- Flujo después del primer login: nombre, edad, preferencias de tono (amigo, terapeuta, motivador, etc.), horarios seguros, nivel de proactividad, temas favoritos.

### 2.2 Core - Acompañamiento Proactivo

**RF-005: Interacciones Proactivas**
- Buenos días / Buenas noches automáticos
- Check-ins emocionales diarios (mensaje o llamada)
- Llamadas de voz proactivas (3-7 minutos)

**RF-006: Chat Conversacional**
- Memoria a largo plazo
- Soporte de voz (STT/TTS)
- Respuestas empáticas y contextuales

**RF-007: Mood Tracker**
- Registro rápido de estado emocional
- Sugerencias según humor detectado

**RF-008: Recordatorios Suaves**
- Hábitos sociales ("Hoy sería buen día para llamar a un amigo")

### 2.3 Automatizaciones (n8n)

- Workflows para triggers temporales, por estado de ánimo, etc.
- Integración con LLM, voz y mensajería
- Detección de crisis y escalada

### 2.4 Seguridad y Ética

- Disclaimers claros en múltiples puntos
- Manejo de crisis (suicidio, depresión grave) → redirección a líneas de ayuda reales
- Límites diarios de interacción para evitar dependencia
- Opción de pausar el compañero

### 2.5 Requerimientos Legales y Play Store

**RF-030: Cumplimiento Google Play**

- **Política de Privacidad** pública (URL)
- **Términos y Condiciones** públicos (URL)
- Pantalla "Legal" dentro de la app con enlaces
- Data Safety Form completado correctamente en Play Console
- Disclaimer ético visible y claro en toda la experiencia

## 3. REQUERIMIENTOS NO FUNCIONALES

- **Usabilidad:** Mobile-first, botones grandes, interfaz cálida y minimalista.
- **Rendimiento:** Respuestas rápidas, llamadas fluidas.
- **Privacidad:** Cumplir GDPR/CCPA. Datos sensibles protegidos.
- **Ética:** Transparencia total sobre el uso de IA.
- **Offline:** Chat básico con sincronización posterior.
- **Accesibilidad:** Soporte TalkBack / VoiceOver.

## 4. ARQUITECTURA TÉCNICA

**Frontend:** Flutter (Dart)  
**Backend / Automatizaciones:** n8n + Supabase  
**IA:** Gemini / Claude / Grok (con wrapper)  
**Voz:** Retell AI o Vapi.ai + ElevenLabs  
**Mensajería:** WhatsApp Business API + Twilio (fallback)  
**Autenticación:** Supabase Auth (Email + Google)  

**Estructura recomendada de carpetas:**
lib/
├── core/
├── features/
│   ├── auth/
│   ├── onboarding/
│   ├── companion/
│   ├── mood/
│   ├── profile/
│   └── legal/
├── data/
├── domain/
├── presentation/
├── services/           # n8n, voice, llm
└── shared/
text## 5. MODELO DE DATOS (Supabase)

- profiles
- user_preferences
- conversations
- mood_entries
- interactions_log
- crisis_events (anonimizado)

## 6. FLUJOS PRINCIPALES

1. Registro/Login → Onboarding → Configuración
2. Daily Morning Routine (n8n)
3. Usuario abre app → Dashboard del compañero
4. Triggers proactivos según reglas

## 7. MANEJO DE ERRORES Y LEGAL

- Todos los prompts del LLM deben incluir límites éticos fuertes.
- Logging seguro.
- Fácil reporte de problemas.

## 8. CRITERIOS DE ACEPTACIÓN DEL MVP

1. Usuario puede registrarse fácilmente con Google.
2. Recibe buenos días y check-ins proactivos.
3. Chat fluido con memoria.
4. Funcionan llamadas de voz.
5. Disclaimers y manejo básico de crisis implementados.
6. Política de Privacidad y Términos públicos.
7. App lista para revisión en Play Store.

## 9. ROADMAP POST-MVP

- Fase 2: Challenges IRL + integración calendario
- Fase 3: Mejora de voz y personalización avanzada
- Fase 4: Versión web (PWA) + posibles características comunitarias

---