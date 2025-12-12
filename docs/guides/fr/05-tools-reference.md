# Guide de Référence des Outils

Ce guide couvre les outils utilitaires inclus avec Claude-Craft pour gérer les profils, l'affichage du statut et la configuration des projets.

---

## Table des Matières

1. [Gestionnaire MultiAccount](#gestionnaire-multiaccount)
2. [StatusLine](#statusline)
3. [Gestionnaire ProjectConfig](#gestionnaire-projectconfig)
4. [Installation](#installation)

---

## Gestionnaire MultiAccount

Gérez plusieurs profils Claude Code pour différents comptes ou contextes.

### Objectif

- Basculer entre comptes Claude (personnel, travail, client)
- Gérer les limites de taux en changeant de profil
- Garder les contextes de projet isolés
- Partager ou isoler les configurations

### Installation

```bash
# Via Makefile
make install-multiaccount

# Ou manuellement
cp Tools/MultiAccount/claude-accounts.sh ~/.local/bin/
chmod +x ~/.local/bin/claude-accounts.sh
```

### Utilisation

#### Mode Interactif

```bash
# Lancer le menu interactif
./claude-accounts.sh
# Ou si installé globalement
claude-accounts.sh
```

Options du menu :
```
1. Lister les profils
2. Ajouter un profil
3. Supprimer un profil
4. Authentifier un profil
5. Lancer Claude Code
6. Installer la fonction ccsp()
7. Migrer un profil legacy
8. Aide
9. Quitter
```

#### Mode CLI

```bash
# Lister tous les profils
./claude-accounts.sh list

# Ajouter un nouveau profil
./claude-accounts.sh add <nom-profil>

# Supprimer un profil
./claude-accounts.sh remove <nom-profil>

# Authentifier un profil
./claude-accounts.sh auth <nom-profil>

# Lancer Claude Code avec un profil
./claude-accounts.sh launch <nom-profil>

# Afficher l'aide
./claude-accounts.sh --help
```

### Modes de Profil

#### Mode Partagé (Par défaut)

Le profil partage la configuration avec le `~/.claude` principal :

```bash
./claude-accounts.sh add travail --mode=shared
```

- Paramètres liés par lien symbolique à `~/.claude`
- Idéal pour : basculer entre comptes en gardant les paramètres
- Cas d'usage : Gestion des limites de taux

#### Mode Isolé

Le profil a une configuration complètement indépendante :

```bash
./claude-accounts.sh add client-a --mode=isolated
```

- Copie indépendante des paramètres
- Idéal pour : travail client avec règles séparées
- Cas d'usage : Configurations de projet différentes

### Changement Rapide de Profil

Installez la fonction shell `ccsp()` :

```bash
# Ajouter au profil via l'option 6 du menu
# Ou ajouter manuellement à ~/.bashrc ou ~/.zshrc :

ccsp() {
    if [ -z "$1" ]; then
        claude-accounts.sh list
    else
        export CLAUDE_CONFIG_DIR="$HOME/.claude-profiles/$1"
        echo "Basculé vers le profil : $1"
    fi
}
```

Utilisation :
```bash
# Lister les profils
ccsp

# Basculer vers un profil
ccsp travail

# Lancer Claude Code (utilise le profil actuel)
claude
```

### Structure des Profils

```
~/.claude-profiles/
├── travail/
│   ├── .mode              # "shared" ou "isolated"
│   ├── config/            # Configuration Claude
│   └── settings.json      # Paramètres du profil
├── client-a/
│   └── ...
└── personnel/
    └── ...
```

### Support Multilingue

```bash
# Utiliser dans une langue spécifique
./claude-accounts.sh --lang=fr list
./claude-accounts.sh --lang=es add trabajo
./claude-accounts.sh --lang=de --help
```

---

## StatusLine

Affiche des informations contextuelles dans la barre de statut de Claude Code.

### Objectif

- Afficher le profil actuel
- Afficher le modèle utilisé
- Montrer la branche et le statut git
- Suivre le pourcentage d'utilisation du contexte
- Surveiller les coûts de session et hebdomadaires
- Afficher les limites d'utilisation

### Installation

```bash
# Via Makefile
make install-statusline

# Ou manuellement
cp Tools/StatusLine/statusline.sh ~/.claude/statusline.sh
cp Tools/StatusLine/statusline.conf.example ~/.claude/statusline.conf
chmod +x ~/.claude/statusline.sh
```

### Configurer Claude Code

Ajouter à `~/.claude/settings.json` :

```json
{
  "statusLine": {
    "enabled": true,
    "script": "~/.claude/statusline.sh"
  }
}
```

### Format de la Status Line

```
🔑 pro | 🧠 Opus | 🌿 main +2~1 | 📁 mon-projet | 📊 45% | ⏱️ 5h: 23% | 📅 Sem: 45% | 💰 $0.42 | 🕐 14:32
```

| Élément | Description |
|---------|-------------|
| 🔑 pro | Nom du profil actif |
| 🧠 Opus | Modèle actuel (🧠 Opus, 🎵 Sonnet, 🍃 Haiku) |
| 🌿 main +2~1 | Branche git + statut (+staged ~modified ?untracked) |
| 📁 mon-projet | Nom du répertoire projet |
| 📊 45% | Utilisation de la fenêtre de contexte |
| ⏱️ 5h: 23% | Pourcentage d'utilisation de session (5h) |
| 📅 Sem: 45% | Pourcentage d'utilisation hebdomadaire |
| 💰 $0.42 | Coût de la session |
| 🕐 14:32 | Heure actuelle |

### Codage Couleur

Les indicateurs d'utilisation changent de couleur selon les seuils :

| Couleur | Signification | Seuil |
|---------|---------------|-------|
| Vert | Utilisation faible | < 60% |
| Jaune | Utilisation modérée | 60-80% |
| Rouge | Utilisation élevée | > 80% |

### Configuration

Éditez `~/.claude/statusline.conf` :

```bash
# =============================================================================
# LIMITES D'UTILISATION
# =============================================================================
# Valeurs recommandées par plan :
#   - Pro (20$/mois)      : SESSION=25,   WEEKLY=150
#   - Max 5x (100$/mois)  : SESSION=125,  WEEKLY=750
#   - Max 20x (200$/mois) : SESSION=500,  WEEKLY=3000

SESSION_COST_LIMIT=500.00
WEEKLY_COST_LIMIT=3000.00

# =============================================================================
# SEUILS D'ALERTE (pourcentage)
# =============================================================================
USAGE_WARN_THRESHOLD=60    # Jaune à 60%
USAGE_CRIT_THRESHOLD=80    # Rouge à 80%

# =============================================================================
# CACHE (performance)
# =============================================================================
SESSION_CACHE_TTL=60       # Rafraîchissement session toutes les 60s
WEEKLY_CACHE_TTL=300       # Rafraîchissement hebdo toutes les 5min

# =============================================================================
# OPTIONS D'AFFICHAGE
# =============================================================================
SHOW_SESSION_LIMIT=true
SHOW_WEEKLY_LIMIT=true

# Labels personnalisés
SESSION_LABEL="⏱️ 5h"
WEEKLY_LABEL="📅 Sem"
```

### Dépendances

```bash
# Requis : jq (processeur JSON)
# macOS
brew install jq

# Linux
sudo apt install jq

# Optionnel : ccusage (suivi des coûts)
npm install -g ccusage
```

### Dépannage

**Status line ne s'affiche pas :**
```bash
# Vérifier que le script est exécutable
ls -la ~/.claude/statusline.sh

# Tester manuellement
echo '{"model":{"display_name":"Test"}}' | ~/.claude/statusline.sh
```

**Coût affiche $0.00 :**
```bash
# Vérifier que ccusage fonctionne
npx ccusage daily --json
```

**Pourcentages d'utilisation ne s'affichent pas :**
```bash
# Vérifier les fichiers de cache
ls -la /tmp/.ccusage_*

# Vider le cache pour rafraîchir
rm /tmp/.ccusage_*
```

---

## Gestionnaire ProjectConfig

Gérez les configurations de projet Claude-Craft via YAML.

### Objectif

- Définir les paramètres de projet en YAML
- Gérer plusieurs projets
- Gérer les configurations monorepo
- Valider les configurations
- Installer les règles depuis la config

### Installation

```bash
# Via Makefile
make install-projectconfig

# Ou manuellement
cp Tools/ProjectConfig/claude-projects.sh ~/.local/bin/
chmod +x ~/.local/bin/claude-projects.sh
```

### Dépendances

```bash
# Requis : yq (processeur YAML)
# macOS
brew install yq

# Linux (snap)
sudo snap install yq

# Linux (binaire)
sudo wget https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 -O /usr/local/bin/yq
sudo chmod +x /usr/local/bin/yq
```

### Utilisation

#### Mode Interactif

```bash
./claude-projects.sh
```

Options du menu :
```
1. Lister les projets
2. Ajouter un projet
3. Éditer un projet
4. Ajouter un module
5. Supprimer un projet
6. Valider la configuration
7. Installer un projet
8. Aide
9. Quitter
```

#### Mode CLI

```bash
# Lister les projets configurés
./claude-projects.sh list

# Valider le fichier de configuration
./claude-projects.sh validate [fichier-config]

# Installer un projet spécifique
./claude-projects.sh install <nom-projet>

# Installer tous les projets
./claude-projects.sh install-all

# Afficher les détails d'un projet
./claude-projects.sh show <nom-projet>

# Ajouter un nouveau projet
./claude-projects.sh add <nom-projet> <chemin>

# Supprimer un projet
./claude-projects.sh remove <nom-projet>
```

### Fichier de Configuration

Emplacement par défaut : `./claude-projects.yaml`

```yaml
settings:
  default_lang: "fr"

projects:
  - name: "mon-saas"
    description: "Plateforme SaaS"
    path: "~/Projets/mon-saas"
    modules:
      - name: "api"
        path: "backend"
        technologies: ["symfony"]
      - name: "web"
        path: "frontend"
        technologies: ["react"]
      - name: "mobile"
        path: "app"
        technologies: ["flutter"]

  - name: "outil-interne"
    path: "~/Projets/interne"
    technologies: ["python"]
    lang: "en"
```

### Validation

```bash
# Valider la configuration
./claude-projects.sh validate

# Ou via Makefile
make config-validate CONFIG=claude-projects.yaml
```

Vérifications de validation :
- Syntaxe YAML valide
- Champs requis présents
- Chemins existants
- Technologies valides
- Langues valides

### Installation depuis la Config

```bash
# Installer un projet unique
./claude-projects.sh install mon-saas

# Ou via Makefile
make config-install CONFIG=claude-projects.yaml PROJECT=mon-saas

# Installer tous les projets
make config-install-all CONFIG=claude-projects.yaml

# Dry run
make config-install CONFIG=claude-projects.yaml PROJECT=mon-saas OPTIONS="--dry-run"
```

### Support Multilingue

```bash
# Utiliser dans une langue spécifique
./claude-projects.sh --lang=fr list
./claude-projects.sh --lang=de validate
```

---

## Installation

### Installer Tous les Outils

```bash
make install-tools
```

Ceci installe :
- Gestionnaire MultiAccount
- StatusLine
- Gestionnaire ProjectConfig

### Installer des Outils Individuels

```bash
# MultiAccount uniquement
make install-multiaccount

# StatusLine uniquement
make install-statusline

# ProjectConfig uniquement
make install-projectconfig
```

### Vérifier l'Installation

```bash
# Vérifier MultiAccount
which claude-accounts.sh
claude-accounts.sh --version

# Vérifier StatusLine
ls ~/.claude/statusline.sh
cat ~/.claude/settings.json | jq '.statusLine'

# Vérifier ProjectConfig
which claude-projects.sh
claude-projects.sh --version
```

---

## Référence Rapide

### Commandes MultiAccount

| Commande | Description |
|----------|-------------|
| `list` | Afficher tous les profils |
| `add <nom>` | Créer un nouveau profil |
| `remove <nom>` | Supprimer un profil |
| `auth <nom>` | Authentifier un profil |
| `launch <nom>` | Démarrer Claude avec un profil |
| `migrate` | Convertir un profil legacy |

### Éléments StatusLine

| Emoji | Signification |
|-------|---------------|
| 🔑 | Profil |
| 🧠 | Modèle Opus |
| 🎵 | Modèle Sonnet |
| 🍃 | Modèle Haiku |
| 🌿 | Branche Git |
| 📁 | Projet |
| 📊 | Contexte % |
| ⏱️ | Usage session |
| 📅 | Usage hebdo |
| 💰 | Coût |
| 🕐 | Heure |

### Commandes ProjectConfig

| Commande | Description |
|----------|-------------|
| `list` | Afficher tous les projets |
| `validate` | Vérifier la validité de la config |
| `install <nom>` | Installer les règles du projet |
| `install-all` | Installer tous les projets |
| `show <nom>` | Afficher les détails du projet |
| `add <nom> <chemin>` | Ajouter un nouveau projet |
| `remove <nom>` | Supprimer un projet |

---

[&larr; Correction de Bugs](04-bug-fixing.md) | [Dépannage &rarr;](06-troubleshooting.md)
