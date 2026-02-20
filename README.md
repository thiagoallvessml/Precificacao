# 🧊 Geladinhos - App de Cálculo de Custos

Aplicativo para gestão e precificação de receitas de geladinhos (picolés/ice pops).

## 🎨 Design System

### Regra de Ouro
**SEMPRE MANTENHA O BACKGROUND EM CINZA**

### Paleta de Cores
- **Primary**: `#13ecec` (Cyan/Turquesa)
- **Background Light**: `#f6f8f8` (Cinza claro)
- **Background Dark**: `#102222` (Cinza escuro - SEMPRE USAR)
- **Fonte**: Work Sans

### Status de Estoque
- 🔴 **Crítico** (0-30%): `text-red-500`
- 🟡 **Atenção** (31-60%): `text-amber-500`
- 🟢 **Saudável** (61-100%): `text-primary`

## 📱 Estrutura de Páginas

### ✅ Menu Principal (`index.html`)
- **Grid de navegação** com 12 cards interativos
- Links para todas as seções do sistema
- Dashboard rápido com estatísticas
- Design responsivo (2-6 colunas baseado em tela)
- Toggle dark/light mode

### ✅ Gestão de Insumos (`gestao-insumos.html`)
- Lista de ingredientes com fotos
- Status visual de estoque (barras de progresso)
- Busca por ingredientes
- Filtros por categoria (Tudo, Líquidos, Sabores, Embalagens)
- FAB para adicionar novo insumo → navega para `gerenciar-insumos.html`
- Bottom Navigation

### ✅ Gerenciar Insumos (`gerenciar-insumos.html`)
- **Modo Mobile**: Segmented control alternando entre tabs
- **Modo Desktop**: Duas colunas lado a lado
- **Tab 1 - Cadastrar Insumo**:
  - Nome, Categoria, Unidade de Medida, Estoque Mínimo
  - Card informativo sobre alertas
- **Tab 2 - Entrada de Estoque**:
  - Seleção de ingrediente (dropdown estilizado)
  - Toggle Custo Unitário/Custo do Pacote
  - Cálculo automático
  - Preview de estoque pós-entrada
- **Navegação**: Botão voltar → `index.html`

## 🗺️ Roadmap

### Próximas Páginas
- [ ] **Categorias** - Organização de tipos de insumos
- [ ] **Produção** - Registro de lotes produzidos
- [ ] **Estoque** - Controle avançado de inventário
- [ ] **Vendas** - Registro e análise de vendas
- [ ] **Financeiro** - Fluxo de caixa e relatórios
- [ ] **Clientes** - Gestão de cadastro
- [ ] **Estatísticas** - Dashboards e gráficos
- [ ] **Fornecedores** - Gestão de parceiros
- [ ] **Ajuda** - Documentação e suporte
- [ ] **Ajustes** - Configurações do sistema

## 🚀 Como Usar

### Desenvolvimento
```bash
npm run dev
```
Acessa: `http://localhost:5173/`

### Build de Produção
```bash
npm run build
```

### Preview da Build
```bash
npm run preview
```

## 🛠️ Stack Tecnológica

- **HTML5**
- **TailwindCSS** (via CDN)
- **Google Fonts** (Work Sans)
- **Material Icons Round**
- **Vite** (servidor de desenvolvimento)
- **JavaScript** (vanilla)

## 📋 Funcionalidades Implementadas

✅ Menu principal com navegação intuitiva  
✅ Cadastro e edição de insumos  
✅ Entrada de estoque com cálculo automático  
✅ Layout responsivo (mobile + desktop)  
✅ Select dropdown customizado e minimalista  
✅ Background cinza em todos os modos  
✅ Transições e animações suaves  

## 🎯 Fluxo de Navegação

```
index.html (Menu Principal)
    ↓
    ├─→ gestao-insumos.html (Lista de Insumos)
    │       ↓
    │       └─→ gerenciar-insumos.html (Cadastro/Entrada)
    │               ↓
    │               └─→ volta para index.html
    │
    ├─→ [outras páginas futuras]
    └─→ [ajustes, ajuda, etc]
```

## 🌐 Servidor de Desenvolvimento

O Vite oferece:
- ⚡ Hot Module Replacement (HMR)
- 🚀 Início rápido (< 1s)
- 🔄 Recarregamento automático
- 📦 Build otimizado para produção
