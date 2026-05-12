---
name: echosoul-landing-architect
description: Especialista en diseño y desarrollo de la Landing Page de EchoSoul. Inspirado en Replika, utiliza una estética premium con degradados azules, modo oscuro (dark theme), glassmorphism y animaciones sutiles. Úsalo cuando diseñes, implementes o modifiques la landing page o componentes web de marketing para EchoSoul.
---

# Habilidad: Arquitecto de Landing Page EchoSoul

## Propósito Principal
Construir y mantener una landing page cautivadora, moderna y empática para EchoSoul. El objetivo es transmitir la sensación de un compañero virtual de IA avanzado, seguro y compasivo (inspirado en referentes exitosos como Replika), logrando que el usuario experimente un efecto "WOW" desde el primer vistazo.

## Guías de Diseño y Estética (EchoSoul Design System)

1. **Paleta de Colores (Blue Harmony)**
   - **Fondo Principal**: Tonos oscuros y profundos (Dark Mode nativo). Ej: `#0F172A` (Slate 900) o un azul medianoche intenso.
   - **Acentos y Degradados**: Uso extensivo de degradados suaves y envolventes combinando azules vibrantes y cian. Ej: `linear-gradient(135deg, #3B82F6, #06B6D4)`.
   - **Emoción**: El azul debe transmitir calma, tecnología avanzada, confianza y profundidad emocional.

2. **Estilo Visual (Premium & Modern)**
   - **Glassmorphism**: Utiliza fondos translúcidos con desenfoque (`backdrop-filter: blur()`) para tarjetas, modales y barras de navegación. Aporta profundidad sin saturar.
   - **Bordes y Sombras**: Bordes redondeados suaves (ej. `border-radius: 16px` o superior) y sombras sutiles teñidas de azul para dar elevación a los elementos interactivos.

3. **Interacción y Animaciones (Dynamic Feel)**
   - Elementos interactivos que responden al hover de manera fluida (transiciones de `0.3s ease-in-out`).
   - Micro-animaciones: Elementos flotantes sutiles, fade-ins lentos al hacer scroll, resplandores (glow effects) pulsantes en botones de "Call to Action".
   - La página debe sentirse "viva" y responsiva.

4. **Tipografía**
   - Moderna, limpia y muy legible (ej. `Inter`, `Outfit` o `Roboto`). Uso de jerarquía clara (Headings grandes y estilizados, cuerpos de texto ligeros con buena altura de línea).

## Componentes Clave de la Landing Page

1. **Hero Section Impactante**: 
   - Título emotivo y directo (ej. "Tu compañero siempre a tu lado").
   - Call to Action (CTA) primario con efecto de resplandor.
   - Representación visual del companion (avatar, esfera luminosa, o interfaz simulada).
2. **Interactive Demo / Chat Preview**: 
   - Una ventana flotante estilo glassmorphism que simule una conversación real y empática con EchoSoul.
3. **Features Core**:
   - Memoria a largo plazo, Soporte proactivo (Check-ins), Comunicación multimodal (Voz/Chat), Privacidad extrema (RLS/Supabase).
4. **Social Proof & Footer**: Testimonios, links a políticas de privacidad (crucial para apps de salud mental) y redes sociales.

## Stack y Desarrollo

- **Core**: HTML5 semántico y Vanilla CSS para máxima flexibilidad, o React/Next.js/Vite si el usuario especifica una arquitectura web compleja.
- **Regla Estricta CSS**: NO uses TailwindCSS a menos que el usuario lo solicite explícitamente. Prefiere Vanilla CSS bien estructurado.
- **SEO Ready**: Etiquetas de título, meta descripciones, estructura de encabezados lógica y atributos alt.

## Proceso de Trabajo (Checklist)

- [ ] Analizar los requerimientos específicos de la sección a crear.
- [ ] Definir los tokens de diseño (colores HSL, variables CSS de degradados).
- [ ] Construir la estructura semántica HTML.
- [ ] Aplicar los estilos CSS priorizando la paleta azul, glassmorphism y responsive design (Mobile First).
- [ ] Añadir micro-animaciones e interactividad (JS ligero o transiciones CSS).
- [ ] Validar que la estética sea "Premium" y no se sienta como un MVP genérico.
