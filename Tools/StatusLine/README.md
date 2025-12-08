# Claude Code Status Line

Affiche une status line personnalisée dans Claude Code avec des informations contextuelles.

## Aperçu

```
🔑 pro | 🧠 Opus | 🌿 main +2~1 | 📁 mon-projet | 📊 45% | ⏱️ 5h: 23% | 📅 Sem: 45% | 💰 $0.42 | 🕐 14:32
```

### Éléments affichés

| Emoji | Info | Description |
|-------|------|-------------|
| 🔑 | Profil | Compte Claude actif (via `CLAUDE_CONFIG_DIR`) |
| 🧠/🎵/🍃 | Modèle | Opus/Sonnet/Haiku |
| 🌿 | Git | Branche + status (+staged ~modified ?untracked) |
| 📁 | Projet | Nom du répertoire projet |
| 📊 | Contexte | % utilisé (vert < 60%, jaune < 80%, rouge ≥ 80%) |
| ⏱️ | Session | % limite session 5h utilisée (via ccusage) |
| 📅 | Hebdo | % limite hebdomadaire utilisée (via ccusage) |
| 💰 | Coût | Coût session en USD |
| 🕐 | Heure | Heure actuelle |

## Installation

### 1. Copier le script

```bash
mkdir -p ~/.claude
cp statusline.sh ~/.claude/statusline.sh
chmod +x ~/.claude/statusline.sh
```

### 2. Configurer Claude Code

Fusionne avec ton `~/.claude/settings.json` existant :

```json
{
  "statusLine": {
    "enabled": true,
    "script": "~/.claude/statusline.sh"
  }
}
```

### 3. Installer les dépendances

```bash
# jq est requis pour parser le JSON
# macOS
brew install jq

# Linux (Debian/Ubuntu)
sudo apt install jq

# ccusage (optionnel, pour tracking avancé des coûts)
npm install -g ccusage
```

### 4. Configurer les profils multiples (optionnel)

Voir `Tools/MultiAccount/` pour gérer plusieurs comptes Claude Code.

## Personnalisation

### Configurer les limites d'utilisation

Copie le fichier de configuration exemple et ajuste les valeurs selon ton abonnement :

```bash
cp statusline.conf.example ~/.claude/statusline.conf
```

Édite `~/.claude/statusline.conf` :

```bash
# Limites de session (approximation 5h)
SESSION_COST_LIMIT=25.00     # En dollars

# Limites hebdomadaires
WEEKLY_COST_LIMIT=150.00     # En dollars

# Seuils d'alerte
USAGE_WARN_THRESHOLD=60      # Jaune à partir de 60%
USAGE_CRIT_THRESHOLD=80      # Rouge à partir de 80%

# Cache (évite les appels répétés à ccusage)
SESSION_CACHE_TTL=60         # Rafraîchissement toutes les 60s
WEEKLY_CACHE_TTL=300         # Rafraîchissement toutes les 5min

# Affichage (true/false)
SHOW_SESSION_LIMIT=true
SHOW_WEEKLY_LIMIT=true

# Labels personnalisés
SESSION_LABEL="⏱️ 5h"
WEEKLY_LABEL="📅 Sem"
```

### Modifier les seuils de contexte

Édite `~/.claude/statusline.sh` :

```bash
CONTEXT_WARN_THRESHOLD=60   # Jaune à partir de 60%
CONTEXT_CRIT_THRESHOLD=80   # Rouge à partir de 80%
```

### Ajouter/retirer des éléments

Commente ou décommente les sections dans la partie "CONSTRUCTION DE LA STATUS LINE" du script.

### Changer les emojis

Modifie la fonction `get_model_emoji()` ou les lignes d'output.

## Troubleshooting

### La status line ne s'affiche pas

1. Vérifie que le script est exécutable : `ls -la ~/.claude/statusline.sh`
2. Teste manuellement : `echo '{"model":{"display_name":"Test"}}' | ~/.claude/statusline.sh`
3. Vérifie les logs Claude Code

### Le coût affiche toujours $0.00

- Installe ccusage : `npm install -g ccusage`
- Le coût peut mettre quelques secondes à se mettre à jour

### Les limites 5h/Hebdo ne s'affichent pas

- ccusage doit être installé : `npm install -g ccusage`
- Vérifie que npx fonctionne : `npx ccusage daily --json`
- Les données apparaissent seulement s'il y a de l'usage (> 0%)
- Le cache peut retarder l'affichage (60s pour session, 5min pour hebdo)

### Les pourcentages semblent incorrects

Les limites sont des estimations que tu définis dans `statusline.conf`.
Ajuste `SESSION_COST_LIMIT` et `WEEKLY_COST_LIMIT` selon ton expérience d'utilisation.

### Le contexte % semble incorrect

L'estimation est basée sur la taille du fichier transcript (~4MB = 100%).
Ajuste `max_size` dans la fonction `get_context_percent()` si nécessaire.

## Commandes utiles

```bash
# Voir l'usage du jour avec ccusage
npx ccusage daily

# Monitoring live
npx ccusage blocks --live

# Usage par projet
npx ccusage daily --instances
```
