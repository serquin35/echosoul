import { defineConfig } from 'vite'

export default defineConfig({
  // La raíz del proyecto es la carpeta landing/
  root: '.',

  // Vite copia todo el contenido de `public/` al output sin procesarlo.
  // Esto garantiza que landing/public/app/ (build de Flutter copiado por CI)
  // quede incluido en .vercel/output/static/app/
  publicDir: 'public',

  build: {
    // Output a dist/ (Vercel lo detecta automáticamente)
    outDir: 'dist',
    emptyOutDir: true,
  },

  server: {
    port: 3000,
  },
})
