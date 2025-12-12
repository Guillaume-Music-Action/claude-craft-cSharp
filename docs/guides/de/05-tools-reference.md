# Werkzeuge-Referenz

Anleitung zu den mit Claude-Craft enthaltenen Hilfswerkzeugen.

---

## MultiAccount-Manager

Verwaltet mehrere Claude Code-Profile.

### Installation
```bash
make install-multiaccount
```

### Interaktive Nutzung
```bash
./claude-accounts.sh
```

### CLI-Modus
```bash
./claude-accounts.sh list              # Profile auflisten
./claude-accounts.sh add <name>        # Profil hinzufügen
./claude-accounts.sh remove <name>     # Profil entfernen
./claude-accounts.sh auth <name>       # Profil authentifizieren
./claude-accounts.sh launch <name>     # Claude mit Profil starten
```

### Profil-Modi
- **shared**: Teilt Konfiguration mit `~/.claude`
- **isolated**: Unabhängige Konfiguration

### ccsp()-Funktion
```bash
ccsp           # Profile auflisten
ccsp arbeit    # Zu Profil "arbeit" wechseln
claude         # Mit aktuellem Profil starten
```

---

## StatusLine

Zeigt kontextuelle Informationen in der Claude Code-Statusleiste.

### Installation
```bash
make install-statusline
```

### Format
```
🔑 pro | 🧠 Opus | 🌿 main +2~1 | 📁 projekt | 📊 45% | ⏱️ 5h: 23% | 📅 Woche: 45% | 💰 $0.42 | 🕐 14:32
```

### Konfiguration (`~/.claude/statusline.conf`)
```bash
SESSION_COST_LIMIT=500.00    # Sitzungslimit (Max 20x)
WEEKLY_COST_LIMIT=3000.00    # Wochenlimit
USAGE_WARN_THRESHOLD=60      # Gelb bei 60%
USAGE_CRIT_THRESHOLD=80      # Rot bei 80%
```

### Abhängigkeiten
```bash
brew install jq   # Erforderlich
npm install -g ccusage  # Optional
```

---

## ProjectConfig-Manager

Verwaltet Claude-Craft-Projektkonfigurationen via YAML.

### Installation
```bash
make install-projectconfig
```

### CLI-Modus
```bash
./claude-projects.sh list                  # Projekte auflisten
./claude-projects.sh validate              # Konfiguration validieren
./claude-projects.sh install <name>        # Projekt installieren
./claude-projects.sh install-all           # Alle installieren
```

### Abhängigkeiten
```bash
brew install yq  # Erforderlich
```

---

## Alle Werkzeuge installieren

```bash
make install-tools
```

---

## Kurzreferenz

### MultiAccount-Befehle
| Befehl | Beschreibung |
|--------|--------------|
| `list` | Profile anzeigen |
| `add <name>` | Profil erstellen |
| `remove <name>` | Profil löschen |
| `launch <name>` | Claude starten |

### StatusLine-Elemente
| Emoji | Bedeutung |
|-------|-----------|
| 🔑 | Profil |
| 🧠/🎵/🍃 | Modell (Opus/Sonnet/Haiku) |
| 🌿 | Git-Branch |
| 📁 | Projekt |
| 📊 | Kontext % |
| ⏱️ | Sitzungsnutzung |
| 📅 | Wochennutzung |
| 💰 | Kosten |

---

[&larr; Fehlerbehebung](04-bug-fixing.md) | [Problemlösung &rarr;](06-troubleshooting.md)
