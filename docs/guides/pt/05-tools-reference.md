# Referência de Ferramentas

Guia das ferramentas utilitárias incluídas com Claude-Craft.

---

## Gestor MultiAccount

Gerencia múltiplos perfis de Claude Code.

### Instalação
```bash
make install-multiaccount
```

### Uso Interativo
```bash
./claude-accounts.sh
```

### Modo CLI
```bash
./claude-accounts.sh list              # Listar perfis
./claude-accounts.sh add <nome>        # Adicionar perfil
./claude-accounts.sh remove <nome>     # Remover perfil
./claude-accounts.sh auth <nome>       # Autenticar perfil
./claude-accounts.sh launch <nome>     # Lançar Claude com perfil
```

### Modos de Perfil
- **shared**: Compartilha configuração com `~/.claude`
- **isolated**: Configuração independente

### Função ccsp()
```bash
ccsp           # Listar perfis
ccsp trabalho  # Mudar para perfil "trabalho"
claude         # Lançar com perfil atual
```

---

## StatusLine

Exibe informações contextuais na barra de status do Claude Code.

### Instalação
```bash
make install-statusline
```

### Formato
```
🔑 pro | 🧠 Opus | 🌿 main +2~1 | 📁 projeto | 📊 45% | ⏱️ 5h: 23% | 📅 Sem: 45% | 💰 $0.42 | 🕐 14:32
```

### Configuração (`~/.claude/statusline.conf`)
```bash
SESSION_COST_LIMIT=500.00    # Limite sessão (Max 20x)
WEEKLY_COST_LIMIT=3000.00    # Limite semanal
USAGE_WARN_THRESHOLD=60      # Amarelo a 60%
USAGE_CRIT_THRESHOLD=80      # Vermelho a 80%
```

### Dependências
```bash
brew install jq   # Obrigatório
npm install -g ccusage  # Opcional
```

---

## Gestor ProjectConfig

Gerencia configurações de projeto Claude-Craft via YAML.

### Instalação
```bash
make install-projectconfig
```

### Modo CLI
```bash
./claude-projects.sh list                  # Listar projetos
./claude-projects.sh validate              # Validar config
./claude-projects.sh install <nome>        # Instalar projeto
./claude-projects.sh install-all           # Instalar todos
```

### Dependências
```bash
brew install yq  # Obrigatório
```

---

## Instalar Todas as Ferramentas

```bash
make install-tools
```

---

## Referência Rápida

### Comandos MultiAccount
| Comando | Descrição |
|---------|-----------|
| `list` | Mostrar perfis |
| `add <nome>` | Criar perfil |
| `remove <nome>` | Excluir perfil |
| `launch <nome>` | Iniciar Claude |

### Elementos StatusLine
| Emoji | Significado |
|-------|-------------|
| 🔑 | Perfil |
| 🧠/🎵/🍃 | Modelo (Opus/Sonnet/Haiku) |
| 🌿 | Branch Git |
| 📁 | Projeto |
| 📊 | Contexto % |
| ⏱️ | Uso sessão |
| 📅 | Uso semanal |
| 💰 | Custo |

---

[&larr; Correção de Bugs](04-bug-fixing.md) | [Resolução de Problemas &rarr;](06-troubleshooting.md)
