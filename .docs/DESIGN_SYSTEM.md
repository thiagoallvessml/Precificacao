# 🍦 Sistema de Design - Aplicativo de Gestão de Geladinhos

## 📊 Visão Geral do Projeto
Aplicativo web para gestão completa de produção e vendas de geladinhos gourmet, incluindo controle de insumos, receitas, produção, estoque, vendas e precificação por marketplace.

---

## 🎨 Paleta de Cores

### Cores Principais
```css
--primary: #13ecec;           /* Ciano vibrante - cor primária do app */
--background-light: #f6f8f8;  /* Fundo claro (modo light) */
--background-dark: #0F0F0F;   /* Fundo escuro (modo dark - PADRÃO) */
```

### Cores de Cards e Elementos
```css
--card-dark: #1a2f2f;         /* Fundo de cards no modo escuro (index.html) */
--card-dark-alt: #1c2727;     /* Fundo de cards alternativo (produtos, produção) */
--card-dark-alt2: #1c1c27;    /* Fundo de cards (configurar produto, marketplace) */
--card-border: #2d4444;       /* Borda de cards */
--input-dark: #2c2c2e;        /* Fundo de inputs */
```

### Cores de Texto
```css
--text-primary: #FFFFFF;      /* Texto principal (branco puro) */
--text-secondary: #d1d1d6;    /* Texto secundário (silver-text) */
--text-muted: #9db9b9;        /* Texto desbotado */
--text-placeholder: #6b7280;  /* Placeholders (gray-500) */
```

### Cores de Estado
```css
--emerald-400: #34d399;       /* Lucro positivo */
--red-500: #ef4444;           /* Alertas/exclusão */
--amber-500: #f59e0b;         /* Avisos */
--primary: #13ecec;           /* Margem/percentuais */
```

### Bordas e Divisores
```css
--border-light: #e2e8f0;      /* Borda modo light (slate-200) */
--border-dark: #1e293b;       /* Borda modo dark (slate-800) */
--border-card: #2d3d3d;       /* Borda específica de cards */
--border-input: #3b5454;      /* Borda de inputs */
--border-subtle: rgba(255, 255, 255, 0.1); /* 10% de opacidade branco */
```

---

## 🖼️ Backgrounds e Efeitos

### Background Principal
- **Modo Dark (padrão):** `#0F0F0F` (quase preto)
- **Modo Light:** `#f6f8f8` (branco acinzentado)

### Cards
```css
background-color: #1a2f2f; /* ou #1c2727 ou #1c1c27 dependendo da página */
border: 1px solid #2d4444; /* ou rgba(255,255,255,0.05) */
border-radius: 0.75rem; /* rounded-xl */
box-shadow: 0 0 15px rgba(19, 236, 236, 0.05); /* glow sutil */
```

### Headers (Navegação Superior)
```css
background-color: rgba(15, 15, 15, 0.8); /* 80% opaco */
backdrop-filter: blur(12px); /* desfoque glassmorphic */
border-bottom: 1px solid rgba(255, 255, 255, 0.1);
position: sticky;
top: 0;
z-index: 50;
```

### Inputs e Forms
```css
background-color: #1c1c27; /* charcoal-dark */
border: 1px solid #3b3b54;
border-radius: 0.75rem; /* rounded-xl */
height: 3.5rem; /* h-14 */
padding: 0 1rem;
color: #ffffff;
```

**Focus State:**
```css
border-color: #13ecec;
box-shadow: 0 0 0 1px #13ecec;
outline: none;
```

### Botões

**Primário:**
```css
background-color: #13ecec;
color: #0F0F0F; /* texto escuro sobre ciano */
font-weight: 700; /* bold */
padding: 0.875rem 2rem; /* py-3.5 px-8 */
border-radius: 1.5rem; /* rounded-2xl */
box-shadow: 0 10px 25px rgba(19, 236, 236, 0.2);
transition: transform 0.2s;
```

**Hover:** `background-color: #00d7d7` (ciano mais escuro)  
**Active:** `transform: scale(0.95)`

**Secundário/Outline:**
```css
background-color: transparent;
border: 1px solid rgba(255, 255, 255, 0.1);
color: #d1d1d6;
```

### FAB (Floating Action Button)
```css
position: fixed;
bottom: 2rem;
right: 1.5rem;
width: 3.5rem;
height: 3.5rem;
background-color: #13ecec;
color: #0F0F0F;
border-radius: 9999px; /* rounded-full */
box-shadow: 0 25px 50px rgba(19, 236, 236, 0.3);
```

---

## 📝 Tipografia

### Fonte
```css
font-family: 'Work Sans', sans-serif;
```

**Importação:**
```html
<link href="https://fonts.googleapis.com/css2?family=Work+Sans:wght@300;400;500;600;700&display=swap" rel="stylesheet" />
```

### Hierarquia de Texto

| Elemento | Tamanho | Peso | Line Height |
|----------|---------|------|-------------|
| H1 (Título Principal) | 2xl (24px) | 700 (bold) | tight |
| H2 (Subtítulo) | lg-xl (18-20px) | 700 (bold) | tight |
| H3 (Seção) | xs (12px) | 700 (bold) | normal |
| Body Regular | base (16px) | 400 (normal) | normal |
| Body Small | sm (14px) | 400-500 | normal |
| Caption/Label | xs (12px) | 500-600 | normal |
| Micro Text | [10px] | 700 (bold) | normal |

### Labels de Formulário
```css
font-size: 0.875rem; /* text-sm */
font-weight: 700; /* font-bold */
color: #ffffff;
text-transform: none;
margin-bottom: 0.5rem;
```

### Headers de Seção
```css
font-size: 0.75rem; /* text-xs */
font-weight: 700; /* font-bold */
color: #9ca3af; /* text-gray-400 */
text-transform: uppercase;
letter-spacing: 0.1em; /* tracking-widest */
```

---

## 📐 Espaçamento e Layout

### Container Principal
```css
max-width: 112rem; /* max-w-7xl = 1280px para desktop */
margin: 0 auto;
padding: 0 1rem; /* px-4 */
```

### Grid Responsivo
```css
/* Mobile (padrão) */
grid-template-columns: repeat(1, minmax(0, 1fr));

/* Tablet (md: 768px) */
@media (min-width: 768px) {
  grid-template-columns: repeat(2, minmax(0, 1fr));
}

/* Desktop (lg: 1024px) */
@media (min-width: 1024px) {
  grid-template-columns: repeat(3, minmax(0, 1fr));
}

gap: 1rem; /* gap-4 = 16px */
```

### Cards (Padding Interno)
- **Header do card:** `padding: 1rem` (p-4)
- **Conteúdo:** `padding: 1rem` (p-4)
- **Margem entre elementos:** `gap: 1rem` (gap-4)

### Border Radius
```css
--rounded-DEFAULT: 0.25rem;  /* 4px */
--rounded-lg: 0.5rem;        /* 8px */
--rounded-xl: 0.75rem;       /* 12px */
--rounded-2xl: 1rem;         /* 16px */
--rounded-3xl: 1.5rem;       /* 24px */
--rounded-full: 9999px;      /* Circular completo */
```

---

## 🧩 Componentes Principais

### 1. Card de Produto
```html
<div class="flex flex-col rounded-xl bg-card-dark border border-card-border shadow-sm overflow-hidden">
  <!-- Header com imagem e info -->
  <div class="flex p-4 gap-4">
    <div class="size-20 rounded-lg bg-cover"></div>
    <div class="flex flex-col justify-between flex-1">
      <p class="text-white text-base font-bold">Nome do Produto</p>
      <p class="text-primary font-bold">R$ 6,00</p>
      <p class="text-slate-400 text-xs">Receita: Base</p>
    </div>
  </div>
  
  <!-- Footer com ações -->
  <div class="flex border-t border-slate-800 bg-black/10">
    <button class="flex-1 py-2.5 text-slate-400 hover:text-primary">Editar</button>
    <button class="flex-1 py-2.5 text-slate-400 hover:text-red-500">Excluir</button>
  </div>
</div>
```

### 2. Filter Chips (Categorias)
```html
<!-- Ativo -->
<div class="flex h-9 rounded-full bg-primary px-5 text-background-dark font-semibold shadow-md">
  <p class="text-sm">Todos</p>
</div>

<!-- Inativo -->
<div class="flex h-9 rounded-full bg-slate-200 dark:bg-[#283939] px-5 text-slate-200 font-medium hover:bg-[#344a4a]">
  <p class="text-sm">Cremoso</p>
</div>
```

### 3. Toggle Switch (iOS Style)
```html
<label class="relative inline-flex items-center cursor-pointer">
  <input type="checkbox" class="sr-only peer" checked />
  <div class="w-11 h-6 bg-[#3b3b54] rounded-full peer peer-checked:bg-primary peer-checked:after:translate-x-full after:content-[''] after:absolute after:top-[2px] after:start-[2px] after:bg-white after:rounded-full after:h-5 after:w-5 after:transition-all"></div>
</label>
```

### 4. Input de Preço
```html
<div class="flex w-full items-stretch rounded-xl overflow-hidden border border-white/10">
  <span class="flex items-center pl-4 bg-input-dark text-gray-400 font-medium">R$</span>
  <input 
    type="number" 
    step="0.01"
    class="form-input w-full border-none bg-input-dark text-white focus:ring-0 h-12 text-base font-bold" 
    value="12.90" 
  />
</div>
```

### 5. Métricas de Lucro
```html
<div class="flex justify-between items-center pt-4 border-t border-white/5">
  <div class="flex flex-col">
    <span class="text-[10px] font-bold text-gray-500 uppercase">Lucro Líquido</span>
    <span class="text-lg font-bold text-emerald-400">R$ 6,80</span>
  </div>
  <div class="h-8 w-px bg-white/10"></div>
  <div class="flex flex-col items-end">
    <span class="text-[10px] font-bold text-gray-500 uppercase">Margem Real</span>
    <span class="text-lg font-bold text-primary">52.7%</span>
  </div>
</div>
```

---

## 🔧 Configuração Tailwind

```javascript
tailwind.config = {
  darkMode: "class",
  theme: {
    extend: {
      colors: {
        "primary": "#13ecec",
        "background-light": "#f6f8f8",
        "background-dark": "#0F0F0F",
        "card-dark": "#1a2f2f",
        "card-border": "#2d4444"
      },
      fontFamily: {
        "display": ["Work Sans", "sans-serif"]
      },
      borderRadius: {
        "DEFAULT": "0.25rem",
        "lg": "0.5rem",
        "xl": "0.75rem",
        "full": "9999px"
      },
    },
  },
}
```

---

## 📱 Páginas do Sistema

### Estrutura de Páginas Criadas
1. **index.html** - Dashboard principal com grid de ícones
2. **gestao-produtos.html** - Lista de produtos (grid responsivo)
3. **configurar-produto.html** - Formulário de cadastro/edição de produto
4. **precos-marketplace.html** - Gestão de preços por canal de venda
5. **producao.html** - Controle de lotes de produção
6. **receitas.html** - Gestão de receitas
7. **gestao-insumos.html** - Controle de insumos
8. **gerenciar-insumos.html** - Cadastro de insumos
9. **categorias.html** - Gestão de categorias
10. **configuracoes.html** - Configurações de custos
11. **equipamentos.html** - Gestão de equipamentos
12. **adicionar-producao.html** - Adicionar nova produção

---

## ⚙️ CSS Global

```css
body {
  font-family: 'Work Sans', sans-serif;
  -webkit-tap-highlight-color: transparent;
  min-height: max(884px, 100dvh);
}

.card-glow {
  box-shadow: 0 0 15px rgba(19, 236, 236, 0.05);
}

.card-active:hover {
  background-color: #1f3434;
  box-shadow: 0 0 20px rgba(19, 236, 236, 0.15);
}

.card-active:active {
  transform: scale(0.95);
  background-color: #233838;
}

.custom-scrollbar::-webkit-scrollbar {
  display: none;
}

.custom-scrollbar {
  -ms-overflow-style: none;
  scrollbar-width: none;
}
```

---

## 🎯 Ícones Material Symbols

**Importação:**
```html
<link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&display=swap" rel="stylesheet" />
```

**Ícones Principais Utilizados:**
- `icecream` - Produtos
- `kitchen` - Insumos
- `menu_book` - Receitas
- `precision_manufacturing` - Produção
- `inventory_2` - Estoque
- `shopping_cart` - Vendas
- `payments` - Financeiro
- `settings` - Configurações
- `add` - Adicionar
- `edit` - Editar
- `delete` - Excluir
- `arrow_back_ios_new` - Voltar
- `search` - Pesquisar

---

## 📦 Scripts Importantes

### Forçar Dark Mode
```javascript
document.documentElement.classList.add('dark');
```

### Navegação
```javascript
// Voltar
onclick="window.history.back()"

// Ir para página
onclick="window.location.href='pagina.html'"
```

---

## 💡 Padrões de Design

### Mobile First
- Todos os layouts começam com 1 coluna
- Breakpoints: `md:` (768px) e `lg:` (1024px)
- Grid responsivo: 1 → 2 → 3 colunas

### Dark Mode Obrigatório
- Todas as páginas forçam `dark` class no HTML
- Cores otimizadas para fundo escuro `#0F0F0F`

### Glassmorphism
- Headers com `backdrop-blur-md`
- Transparência `bg-background-dark/80`

### Estados Visuais
- **Hover:** Mudança de cor + sombra
- **Active:** `scale(0.95)` em botões
- **Focus:** Ring de `#13ecec` em inputs
- **Disabled:** Opacity 50% + grayscale

---

Este documento contém todos os detalhes necessários para recriar o design system do aplicativo. Use como referência para manter a consistência visual em todas as páginas.
