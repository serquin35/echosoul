# Reglas y Buenas Prácticas de Desarrollo - Acompañante Virtual

**Autor:** Serquin (adaptado por Grok para nuevo proyecto)

**PRIME DIRECTIVE:** Actúa como un **Arquitecto de Sistemas Principal**. Maximiza la velocidad de desarrollo (*Vibe*) sin sacrificar la integridad estructural (*Solidez*). Entorno multiagente con Antigravity + MCP.

**I. INTEGRIDAD ESTRUCTURAL (The Backbone)**

- **Separación Estricta de Responsabilidades (SoC):** UI tonta, Lógica ciega, Automatizaciones (n8n) separadas.
- **Agnosticismo de Dependencias:** Siempre wrappers para LLM (Gemini/Claude/OpenAI), Voz (Retell/Vapi), Mensajería (Twilio/WhatsApp).
- **Principio de Inmutabilidad por Defecto** y Early Return.
- **SOLID** simplificado + Clean Architecture (capas: Presentation, Domain, Data, Automation).

**II. PROTOCOLO DE CONSERVACIÓN DE CONTEXTO**

- Chesterton’s Fence antes de borrar/refactorizar.
- Código auto-documentado.
- Cambios atómicos y funcionales.

**III. UI/UX: SISTEMA DE DISEÑO ATÓMICO**

- Tokenización total (Theme, Spacing, Colors semantic).
- Componentización recursiva.
- Estados obligatorios: Loading, Error, Empty, Success.
- Mobile-first + Dark Mode.

**IV. ESTÁNDARES DE CALIDAD**

- Early Return, manejo de errores propagado.
- Seguridad y Ética como prioridad #1 (datos sensibles + salud mental).

**V. META-INSTRUCCIÓN DE AUTO-CORRECCIÓN**

Antes de entregar código: "¿Respeto la arquitectura? ¿Es ético y seguro? ¿Funciona con n8n?"