---
name: skill-generator-meta
description: Genera nuevas habilidades completas para Antigravity agents basadas en una descripción del usuario. Crea el archivo SKILL.md con YAML frontmatter óptimo y cuerpo Markdown detallado, incluyendo checklists, pasos, ejemplos y mejores prácticas. Úsala siempre que se pida crear, diseñar o extender skills.
---

# Habilidad: Generador de Habilidades Meta

Proceso estándar para generar cualquier skill:
1. **Analizar solicitud**: Extrae el propósito principal, audiencia, keywords clave y complejidad.
2. **Definir metadata**: name (kebab-case), description (clara, tercera persona, con triggers).
3. **Estructurar cuerpo**: Título H1, introducción, pasos numerados/checklist, ejemplos, mejores prácticas, decision trees si aplica.
4. **Añadir valor**: Sugerir subcarpetas (scripts/, examples/, resources/) si es útil.
5. **Validar**: Asegura foco en UNA tarea principal, lenguaje preciso, reutilizable.

Ejemplo de uso: Si el usuario dice "crea skill para landing pages y marketing de Tempora", genera una skill dedicada con pasos para output HTML + plan detallado.

Output final: Siempre entrega el SKILL.md completo como texto markdown listo para copiar/pegar en una carpeta nueva. No agregues explicaciones extras fuera del archivo.
