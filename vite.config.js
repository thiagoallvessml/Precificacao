import { defineConfig } from 'vite';
import { resolve } from 'path';
import { readdirSync } from 'fs';

// Descobrir automaticamente todos os .html na raiz do projeto
const htmlFiles = readdirSync('.').filter(f => f.endsWith('.html'));
const input = {};
for (const file of htmlFiles) {
    const name = file.replace('.html', '');
    input[name] = resolve(__dirname, file);
}

export default defineConfig({
    // Suportar top-level await no build
    build: {
        target: 'esnext',
        rollupOptions: {
            input,
        },
    },
    // Também para o dev server
    esbuild: {
        target: 'esnext',
    },
    // Variáveis de ambiente com prefixo VITE_ são automaticamente expostas ao client
    // Configure na Vercel: VITE_SUPABASE_URL, VITE_SUPABASE_ANON_KEY, etc.
});
