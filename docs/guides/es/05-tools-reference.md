# Referencia de Herramientas

Guía de las herramientas utilitarias incluidas con Claude-Craft.

---

## Gestor MultiAccount

Gestiona múltiples perfiles de Claude Code.

### Instalación
```bash
make install-multiaccount
```

### Uso Interactivo
```bash
./claude-accounts.sh
```

### Modo CLI
```bash
./claude-accounts.sh list              # Listar perfiles
./claude-accounts.sh add <nombre>      # Añadir perfil
./claude-accounts.sh remove <nombre>   # Eliminar perfil
./claude-accounts.sh auth <nombre>     # Autenticar perfil
./claude-accounts.sh launch <nombre>   # Lanzar Claude con perfil
```

### Modos de Perfil
- **shared**: Comparte configuración con `~/.claude`
- **isolated**: Configuración independiente

### Función ccsp()
```bash
ccsp           # Listar perfiles
ccsp trabajo   # Cambiar a perfil "trabajo"
claude         # Lanzar con perfil actual
```

---

## StatusLine

Muestra información contextual en la barra de estado de Claude Code.

### Instalación
```bash
make install-statusline
```

### Formato
```
🔑 pro | 🧠 Opus | 🌿 main +2~1 | 📁 proyecto | 📊 45% | ⏱️ 5h: 23% | 📅 Sem: 45% | 💰 $0.42 | 🕐 14:32
```

### Configuración (`~/.claude/statusline.conf`)
```bash
SESSION_COST_LIMIT=500.00    # Límite sesión (Max 20x)
WEEKLY_COST_LIMIT=3000.00    # Límite semanal
USAGE_WARN_THRESHOLD=60      # Amarillo a 60%
USAGE_CRIT_THRESHOLD=80      # Rojo a 80%
```

### Dependencias
```bash
brew install jq   # Requerido
npm install -g ccusage  # Opcional
```

---

## Gestor ProjectConfig

Gestiona configuraciones de proyecto Claude-Craft via YAML.

### Instalación
```bash
make install-projectconfig
```

### Modo CLI
```bash
./claude-projects.sh list                  # Listar proyectos
./claude-projects.sh validate              # Validar config
./claude-projects.sh install <nombre>      # Instalar proyecto
./claude-projects.sh install-all           # Instalar todos
```

### Dependencias
```bash
brew install yq  # Requerido
```

---

## Instalar Todas las Herramientas

```bash
make install-tools
```

---

## Referencia Rápida

### Comandos MultiAccount
| Comando | Descripción |
|---------|-------------|
| `list` | Mostrar perfiles |
| `add <nombre>` | Crear perfil |
| `remove <nombre>` | Eliminar perfil |
| `launch <nombre>` | Iniciar Claude |

### Elementos StatusLine
| Emoji | Significado |
|-------|-------------|
| 🔑 | Perfil |
| 🧠/🎵/🍃 | Modelo (Opus/Sonnet/Haiku) |
| 🌿 | Rama Git |
| 📁 | Proyecto |
| 📊 | Contexto % |
| ⏱️ | Uso sesión |
| 📅 | Uso semanal |
| 💰 | Coste |

---

[&larr; Corrección de Bugs](04-bug-fixing.md) | [Solución de Problemas &rarr;](06-troubleshooting.md)
