# Guide de Dépannage

Ce guide couvre les problèmes courants et leurs solutions lors de l'utilisation de Claude-Craft.

---

## Table des Matières

1. [Problèmes d'Installation](#problèmes-dinstallation)
2. [Problèmes d'Agents](#problèmes-dagents)
3. [Problèmes de Commandes](#problèmes-de-commandes)
4. [Problèmes de Configuration](#problèmes-de-configuration)
5. [Problèmes d'Outils](#problèmes-doutils)
6. [Problèmes de Performance](#problèmes-de-performance)
7. [Obtenir de l'Aide](#obtenir-de-laide)

---

## Problèmes d'Installation

### Commandes Non Reconnues Après Installation

**Symptômes :**
- Les commandes slash comme `/symfony:check-compliance` ne fonctionnent pas
- Claude ne reconnaît pas les commandes installées

**Solutions :**

1. **Redémarrer Claude Code**
   ```bash
   # Quitter complètement Claude Code
   exit

   # Redémarrer
   claude
   ```

2. **Vérifier l'installation**
   ```bash
   ls -la .claude/commands/
   # Devrait afficher les répertoires de commandes
   ```

3. **Vérifier le format des fichiers de commandes**
   ```bash
   head -5 .claude/commands/symfony/check-compliance.md
   # Devrait commencer par un en-tête markdown correct
   ```

### Fichiers Non Trouvés Pendant l'Installation

**Symptômes :**
- Erreurs "Fichier source non trouvé"
- Règles ou templates manquants

**Solutions :**

1. **Vérifier le chemin Claude-Craft**
   ```bash
   # Vérifier que vous êtes dans le répertoire claude-craft
   pwd
   ls -la Dev/scripts/
   ```

2. **Vérifier que les fichiers de langue existent**
   ```bash
   ls -la Dev/i18n/fr/Symfony/rules/
   ```

3. **Utiliser un chemin TARGET absolu**
   ```bash
   # Au lieu de
   make install-symfony TARGET=./backend

   # Utilisez
   make install-symfony TARGET=/chemin/complet/vers/backend
   ```

### Erreurs Permission Denied

**Symptômes :**
- Impossible d'exécuter les scripts d'installation
- Impossible d'écrire dans le répertoire cible

**Solutions :**

1. **Rendre les scripts exécutables**
   ```bash
   chmod +x Dev/scripts/*.sh
   chmod +x Project/*.sh
   chmod +x Infra/*.sh
   chmod +x Tools/*/*.sh
   ```

2. **Vérifier les permissions du répertoire cible**
   ```bash
   ls -la ~/mon-projet/
   # S'assurer d'avoir les permissions d'écriture
   ```

3. **Exécuter avec l'utilisateur approprié**
   ```bash
   # N'utilisez pas sudo sauf si nécessaire
   # Vérifier la propriété du répertoire
   ls -la ~/mon-projet
   ```

### L'Installation Crée un Répertoire Vide

**Symptômes :**
- Répertoire `.claude/` créé mais vide ou fichiers manquants

**Solutions :**

1. **Vérifier les erreurs dans la sortie**
   ```bash
   # Exécuter avec sortie verbeuse
   make install-symfony TARGET=./backend 2>&1 | tee install.log
   ```

2. **Vérifier que la source existe**
   ```bash
   ls -la Dev/i18n/fr/Symfony/
   ```

3. **Essayer l'exécution directe du script**
   ```bash
   ./Dev/scripts/install-symfony-rules.sh --lang=fr ./backend
   ```

---

## Problèmes d'Agents

### Agent Non Disponible

**Symptômes :**
- `@api-designer` ou autres agents ne répondent pas
- Erreurs de type "Agent inconnu"

**Solutions :**

1. **Vérifier que les fichiers agents existent**
   ```bash
   ls -la .claude/agents/
   # Devrait lister les fichiers .md des agents
   ```

2. **Vérifier le format du fichier agent**
   ```bash
   head -20 .claude/agents/api-designer.md
   # Devrait avoir un frontmatter correct avec name et description
   ```

3. **Réinstaller les agents**
   ```bash
   make install-common TARGET=. OPTIONS="--force"
   ```

### L'Agent Donne des Réponses Non Pertinentes

**Symptômes :**
- L'agent ne suit pas ses instructions spécialisées
- Réponses génériques au lieu de conseils experts

**Solutions :**

1. **Fournir plus de contexte**
   ```markdown
   @symfony-reviewer Revois mon implémentation de UserService

   Contexte :
   - Symfony 7 avec API Platform
   - Clean Architecture
   - Approche DDD

   Code à revoir :
   [coller le code ici]
   ```

2. **Être spécifique dans votre demande**
   ```markdown
   # Au lieu de
   @database-architect Aide-moi avec ma base de données

   # Utilisez
   @database-architect Conçois le schéma pour l'agrégat User avec :
   - Entité User (id, email, password_hash)
   - Entité Role (many-to-many avec User)
   - Entité Permission (many-to-many avec Role)
   - Piste d'audit pour les modifications utilisateur
   ```

3. **Vérifier le fichier de contexte projet**
   ```bash
   cat .claude/rules/00-project-context.md
   # S'assurer qu'il décrit votre projet avec précision
   ```

### Conflits entre Agent et Règles du Projet

**Symptômes :**
- Les suggestions de l'agent contredisent les conventions du projet
- Conseils incohérents

**Solutions :**

1. **Mettre à jour le contexte projet**
   - Ajouter les conventions spécifiques dans `00-project-context.md`
   - Inclure les préférences et contraintes de l'équipe

2. **Être explicite dans les demandes**
   ```markdown
   @api-designer Conçois l'endpoint en suivant nos conventions RESTful
   (voir 00-project-context.md pour nos standards API)
   ```

---

## Problèmes de Commandes

### Commande Non Trouvée

**Symptômes :**
- `/symfony:generate-crud` retourne "commande inconnue"
- Les suggestions de commandes n'apparaissent pas

**Solutions :**

1. **Vérifier le répertoire des commandes**
   ```bash
   ls .claude/commands/symfony/
   # Devrait inclure generate-crud.md
   ```

2. **Vérifier le namespace**
   ```bash
   # Les commandes sont au format : /{namespace}:{commande}
   # Namespaces disponibles :
   ls .claude/commands/
   # common/, symfony/, flutter/, python/, react/, reactnative/, docker/
   ```

3. **Lister les commandes disponibles**
   ```bash
   # Dans Claude Code, tapez :
   /help
   ```

### Erreurs d'Exécution de Commande

**Symptômes :**
- La commande démarre mais échoue
- Sortie ou erreurs inattendues

**Solutions :**

1. **Vérifier les prérequis**
   - Certaines commandes nécessitent des outils spécifiques
   - Vérifier que les dépendances requises sont installées

2. **Examiner le fichier de commande**
   ```bash
   cat .claude/commands/symfony/generate-crud.md
   # Comprendre ce que la commande attend
   ```

3. **Fournir les paramètres requis**
   ```bash
   # Au lieu de
   /symfony:generate-crud

   # Utilisez
   /symfony:generate-crud User --with-api --with-tests
   ```

### Sortie de Commande Incorrecte

**Symptômes :**
- Le code généré ne correspond pas au style du projet
- Mauvais patterns technologiques utilisés

**Solutions :**

1. **Mettre à jour le contexte projet**
   ```bash
   # Éditer .claude/rules/00-project-context.md
   # Ajouter les patterns et conventions spécifiques
   ```

2. **Personnaliser les templates**
   ```bash
   # Éditer les templates dans .claude/templates/
   # Ajuster pour correspondre au style de votre projet
   ```

---

## Problèmes de Configuration

### Configuration YAML Invalide

**Symptômes :**
- `make config-validate` échoue
- Erreurs de syntaxe dans la configuration

**Solutions :**

1. **Vérifier la syntaxe YAML**
   ```bash
   # Valider le YAML
   yq e '.' claude-projects.yaml
   ```

2. **Erreurs YAML courantes :**
   ```yaml
   # Incorrect : indentation incohérente
   projects:
     - name: "projet"
       path: "/chemin"  # 2 espaces
        technologies: ["symfony"]  # 3 espaces - ERREUR !

   # Correct : indentation cohérente
   projects:
     - name: "projet"
       path: "/chemin"
       technologies: ["symfony"]
   ```

3. **Valider avec l'outil**
   ```bash
   make config-validate CONFIG=claude-projects.yaml
   ```

### Projet Non Trouvé dans la Configuration

**Symptômes :**
- "Projet non trouvé" lors de l'installation
- Projet non listé

**Solutions :**

1. **Vérifier l'orthographe du nom du projet**
   ```bash
   # Lister les projets
   make config-list CONFIG=claude-projects.yaml

   # Les noms sont sensibles à la casse
   ```

2. **Vérifier le chemin du fichier de configuration**
   ```bash
   # Par défaut cherche claude-projects.yaml dans le répertoire courant
   # Spécifier explicitement :
   make config-install CONFIG=/chemin/vers/config.yaml PROJECT=monprojet
   ```

### Configuration Non Appliquée

**Symptômes :**
- Les changements de config ne prennent pas effet
- Anciens paramètres persistent

**Solutions :**

1. **Réinstaller avec force**
   ```bash
   make config-install CONFIG=claude-projects.yaml PROJECT=monprojet OPTIONS="--force"
   ```

2. **Vérifier les conflits**
   ```bash
   # Supprimer l'installation existante
   rm -rf /chemin/vers/projet/.claude

   # Réinstaller
   make config-install CONFIG=claude-projects.yaml PROJECT=monprojet
   ```

---

## Problèmes d'Outils

### StatusLine Ne S'Affiche Pas

**Symptômes :**
- Barre de statut vide ou par défaut
- Status line personnalisée ne s'affiche pas

**Solutions :**

1. **Vérifier que le script est installé**
   ```bash
   ls -la ~/.claude/statusline.sh
   # Devrait exister et être exécutable
   ```

2. **Vérifier settings.json**
   ```bash
   cat ~/.claude/settings.json | jq '.statusLine'
   # Devrait afficher :
   # {
   #   "enabled": true,
   #   "script": "~/.claude/statusline.sh"
   # }
   ```

3. **Tester le script manuellement**
   ```bash
   echo '{"model":{"display_name":"Test","id":"claude-opus"}}' | ~/.claude/statusline.sh
   # Devrait afficher une status line formatée
   ```

4. **Vérifier jq**
   ```bash
   which jq
   # Installer si manquant : brew install jq / apt install jq
   ```

### Problèmes de Profil MultiAccount

**Symptômes :**
- Impossible de changer de profil
- Profil non reconnu

**Solutions :**

1. **Lister les profils**
   ```bash
   ./claude-accounts.sh list
   ```

2. **Vérifier le répertoire des profils**
   ```bash
   ls -la ~/.claude-profiles/
   # Devrait contenir les répertoires de profils
   ```

3. **Vérifier le fichier de mode du profil**
   ```bash
   cat ~/.claude-profiles/monprofil/.mode
   # Devrait contenir "shared" ou "isolated"
   ```

4. **Recréer le profil problématique**
   ```bash
   ./claude-accounts.sh remove monprofil
   ./claude-accounts.sh add monprofil --mode=shared
   ```

### Erreurs yq pour ProjectConfig

**Symptômes :**
- "yq: command not found"
- Erreurs de parsing YAML

**Solutions :**

1. **Installer yq**
   ```bash
   # macOS
   brew install yq

   # Linux
   sudo snap install yq
   # ou
   sudo wget https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 -O /usr/local/bin/yq
   sudo chmod +x /usr/local/bin/yq
   ```

2. **Vérifier la version de yq**
   ```bash
   yq --version
   # Devrait être v4.x (mikefarah/yq, pas kislyuk/yq)
   ```

---

## Problèmes de Performance

### Exécution de Commande Lente

**Symptômes :**
- Les commandes mettent du temps à répondre
- StatusLine se met à jour lentement

**Solutions :**

1. **Vérifier les paramètres de cache**
   ```bash
   # Dans ~/.claude/statusline.conf
   SESSION_CACHE_TTL=60   # Réduire si trop lent
   WEEKLY_CACHE_TTL=300   # Réduire si trop lent
   ```

2. **Vider les caches**
   ```bash
   rm /tmp/.ccusage_*
   ```

3. **Vérifier le réseau**
   - Certaines fonctionnalités nécessitent le réseau (ccusage)
   - Réseau lent = mises à jour lentes

### Utilisation Élevée de la Fenêtre de Contexte

**Symptômes :**
- L'indicateur 📊 montre un pourcentage élevé rapidement
- Avertissements "Limite de contexte"

**Solutions :**

1. **Démarrer une nouvelle conversation**
   ```bash
   exit
   claude
   ```

2. **Être concis dans les demandes**
   - Éviter de coller de gros blocs de code
   - Référencer les fichiers au lieu de coller

3. **Utiliser les agents pour les tâches complexes**
   ```markdown
   # Au lieu de coller tout le codebase
   @research-assistant Trouve tous les fichiers liés à l'authentification dans src/
   ```

---

## Obtenir de l'Aide

### Consulter la Documentation

1. **Docs principales** : répertoire `docs/`
2. **Référence agents** : `docs/AGENTS.md`
3. **Référence commandes** : `docs/COMMANDS.md`
4. **Guide technologies** : `docs/TECHNOLOGIES.md`

### Obtenir les Infos de Version

```bash
# Scripts d'installation
./Dev/scripts/install-symfony-rules.sh --version

# Outils
./Tools/MultiAccount/claude-accounts.sh --version
./Tools/ProjectConfig/claude-projects.sh --version
```

### Signaler des Problèmes

Si vous rencontrez des bugs :

1. Collecter les informations :
   - Version Claude-Craft
   - Système d'exploitation
   - Étapes pour reproduire
   - Messages d'erreur

2. Vérifier les issues existantes sur GitHub

3. Créer une nouvelle issue avec les détails

### Demander de l'Aide

```markdown
@research-assistant J'ai un problème avec [décrire le problème]

Environnement :
- OS : [votre OS]
- Version Claude-Craft : [version]
- Technologie : [symfony/flutter/etc.]

Ce que j'ai essayé :
1. [étape 1]
2. [étape 2]

Message d'erreur :
[coller l'erreur]
```

---

## Checklist de Corrections Rapides

Quand quelque chose ne fonctionne pas :

- [ ] Redémarrer Claude Code
- [ ] Vérifier l'installation (`ls .claude/`)
- [ ] Vérifier les permissions des fichiers
- [ ] Valider la configuration
- [ ] Vider les caches
- [ ] Vérifier les dépendances (jq, yq)
- [ ] Essayer la réinstallation avec `--force`
- [ ] Consulter la documentation
- [ ] Demander de l'aide

---

[&larr; Référence des Outils](05-tools-reference.md) | [Retour à l'Index](../index.md)
