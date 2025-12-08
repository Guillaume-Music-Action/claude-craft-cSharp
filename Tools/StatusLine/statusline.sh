#!/bin/bash
# =============================================================================
# Claude Code Status Line - Version complète avec emojis
#
# Affiche: Profil | Modèle | Git (branch ±staged/unstaged) | Projet | Contexte% | Coût | Heure
# =============================================================================

set -o pipefail

# -----------------------------------------------------------------------------
# Configuration par défaut
# -----------------------------------------------------------------------------
CONTEXT_WARN_THRESHOLD=60
CONTEXT_CRIT_THRESHOLD=80

# Limites d'utilisation (peuvent être surchargées par statusline.conf)
# Valeurs par défaut pour Max 20x ($200/mois)
SESSION_COST_LIMIT=500.00
WEEKLY_COST_LIMIT=3000.00
USAGE_WARN_THRESHOLD=60
USAGE_CRIT_THRESHOLD=80
SESSION_CACHE_TTL=60
WEEKLY_CACHE_TTL=300
SHOW_SESSION_LIMIT=true
SHOW_WEEKLY_LIMIT=true
SESSION_LABEL="⏱️ 5h"
WEEKLY_LABEL="📅 Sem"

# Charger la configuration utilisateur si elle existe
STATUSLINE_CONF="${CLAUDE_CONFIG_DIR:-$HOME/.claude}/statusline.conf"
[[ -f "$STATUSLINE_CONF" ]] && source "$STATUSLINE_CONF"

# Couleurs ANSI
C_RESET='\033[00m'
C_BOLD='\033[01m'
C_RED='\033[01;31m'
C_GREEN='\033[01;32m'
C_YELLOW='\033[01;33m'
C_BLUE='\033[01;34m'
C_MAGENTA='\033[01;35m'
C_CYAN='\033[01;36m'
C_WHITE='\033[01;37m'
C_DIM='\033[02;37m'

# -----------------------------------------------------------------------------
# Lecture du JSON en entrée (fourni par Claude Code)
# -----------------------------------------------------------------------------
INPUT=$(cat)

# -----------------------------------------------------------------------------
# Extraction des données depuis le JSON
# -----------------------------------------------------------------------------
MODEL_DISPLAY=$(echo "$INPUT" | jq -r '.model.display_name // "Unknown"')
MODEL_ID=$(echo "$INPUT" | jq -r '.model.id // ""')
CWD=$(echo "$INPUT" | jq -r '.workspace.current_dir // .cwd // ""')
PROJECT_DIR=$(echo "$INPUT" | jq -r '.workspace.project_dir // ""')
TRANSCRIPT_PATH=$(echo "$INPUT" | jq -r '.transcript_path // ""')
SESSION_COST=$(echo "$INPUT" | jq -r '.cost.total_cost_usd // 0')
VERSION=$(echo "$INPUT" | jq -r '.version // ""')

# -----------------------------------------------------------------------------
# 1. PROFIL ACTIF
# -----------------------------------------------------------------------------
get_profile() {
    if [[ -n "$CLAUDE_CONFIG_DIR" ]]; then
        local profile_name="${CLAUDE_CONFIG_DIR##*/}"
        # Retire le préfixe .claude- ou claude- si présent
        profile_name="${profile_name#.claude-}"
        profile_name="${profile_name#claude-}"
        echo "$profile_name"
    else
        echo "default"
    fi
}

PROFILE=$(get_profile)

# -----------------------------------------------------------------------------
# 2. MODÈLE (avec emoji selon le type)
# -----------------------------------------------------------------------------
get_model_emoji() {
    case "$MODEL_ID" in
        *opus*)   echo "🧠" ;;
        *sonnet*) echo "🎵" ;;
        *haiku*)  echo "🍃" ;;
        *)        echo "🤖" ;;
    esac
}

MODEL_EMOJI=$(get_model_emoji)

# -----------------------------------------------------------------------------
# 3. GIT - Branche + Status (staged/unstaged/untracked)
# -----------------------------------------------------------------------------
get_git_info() {
    local dir="${1:-$CWD}"
    [[ -z "$dir" ]] && return

    # Vérifie si c'est un repo git
    if ! git -C "$dir" rev-parse --git-dir &>/dev/null 2>&1; then
        return
    fi

    local branch=$(git -C "$dir" branch --show-current 2>/dev/null)
    [[ -z "$branch" ]] && branch=$(git -C "$dir" rev-parse --short HEAD 2>/dev/null)
    [[ -z "$branch" ]] && return

    # Compte les fichiers
    local staged=$(git -C "$dir" diff --cached --numstat 2>/dev/null | wc -l | tr -d ' ')
    local unstaged=$(git -C "$dir" diff --numstat 2>/dev/null | wc -l | tr -d ' ')
    local untracked=$(git -C "$dir" ls-files --others --exclude-standard 2>/dev/null | wc -l | tr -d ' ')

    # Construction du status
    local status=""
    [[ "$staged" -gt 0 ]] && status+="+${staged}"
    [[ "$unstaged" -gt 0 ]] && status+="~${unstaged}"
    [[ "$untracked" -gt 0 ]] && status+="?${untracked}"

    if [[ -n "$status" ]]; then
        echo "${branch} ${status}"
    else
        echo "$branch"
    fi
}

GIT_INFO=$(get_git_info "$CWD")

# -----------------------------------------------------------------------------
# 4. NOM DU PROJET
# -----------------------------------------------------------------------------
if [[ -n "$PROJECT_DIR" ]]; then
    PROJECT_NAME="${PROJECT_DIR##*/}"
elif [[ -n "$CWD" ]]; then
    PROJECT_NAME="${CWD##*/}"
else
    PROJECT_NAME="?"
fi

# -----------------------------------------------------------------------------
# 5. CONTEXTE UTILISÉ (%) - Estimation via taille du transcript
# -----------------------------------------------------------------------------
get_context_percent() {
    local transcript="$1"
    [[ ! -f "$transcript" ]] && echo "" && return

    # Taille du fichier transcript
    local size=$(wc -c < "$transcript" 2>/dev/null || echo 0)

    # Estimation: ~200K tokens ≈ 4MB de JSON
    # Ajuster selon le modèle si nécessaire
    local max_size=4000000
    local percent=$((size * 100 / max_size))
    [[ $percent -gt 100 ]] && percent=100

    echo "$percent"
}

CONTEXT_PCT=$(get_context_percent "$TRANSCRIPT_PATH")

# Couleur selon le seuil
get_context_color() {
    local pct="$1"
    [[ -z "$pct" ]] && echo "$C_DIM" && return

    if [[ "$pct" -ge "$CONTEXT_CRIT_THRESHOLD" ]]; then
        echo "$C_RED"
    elif [[ "$pct" -ge "$CONTEXT_WARN_THRESHOLD" ]]; then
        echo "$C_YELLOW"
    else
        echo "$C_GREEN"
    fi
}

CONTEXT_COLOR=$(get_context_color "$CONTEXT_PCT")

# -----------------------------------------------------------------------------
# 6. COÛT SESSION ($) - Utilise ccusage si disponible, sinon JSON
# -----------------------------------------------------------------------------
get_session_cost() {
    # Priorité 1: Coût depuis le JSON (fourni par Claude Code)
    if [[ -n "$SESSION_COST" ]] && [[ "$SESSION_COST" != "0" ]] && [[ "$SESSION_COST" != "null" ]]; then
        printf "%.2f" "$SESSION_COST"
        return
    fi

    # Priorité 2: ccusage si installé (session courante)
    if command -v npx &>/dev/null; then
        # Essaie d'obtenir le coût via ccusage statusline (mode rapide)
        local ccusage_cost=$(timeout 2 npx --yes ccusage@latest statusline --json 2>/dev/null | jq -r '.cost // empty' 2>/dev/null)
        if [[ -n "$ccusage_cost" ]]; then
            printf "%.2f" "$ccusage_cost"
            return
        fi
    fi

    echo "0.00"
}

COST=$(get_session_cost)

# -----------------------------------------------------------------------------
# 7. USAGE SESSION (% de la limite 5h) via ccusage
# -----------------------------------------------------------------------------
get_usage_color() {
    local pct="$1"
    [[ -z "$pct" ]] && echo "$C_DIM" && return

    if [[ "$pct" -ge "$USAGE_CRIT_THRESHOLD" ]]; then
        echo "$C_RED"
    elif [[ "$pct" -ge "$USAGE_WARN_THRESHOLD" ]]; then
        echo "$C_YELLOW"
    else
        echo "$C_GREEN"
    fi
}

get_session_usage_pct() {
    [[ "$SHOW_SESSION_LIMIT" != "true" ]] && return

    # Cache pour éviter appels répétés (ccusage est lent)
    local cache_file="/tmp/.ccusage_session_cache"
    local now=$(date +%s)

    if [[ -f "$cache_file" ]]; then
        local cache_time=$(stat -c %Y "$cache_file" 2>/dev/null || echo 0)
        if [[ $((now - cache_time)) -lt $SESSION_CACHE_TTL ]]; then
            cat "$cache_file"
            return
        fi
    fi

    # Vérifier que npx est disponible
    if ! command -v npx &>/dev/null; then
        return
    fi

    local today=$(date +%Y%m%d)
    local cost=$(timeout 5 npx --yes ccusage@latest daily --since "$today" --json 2>/dev/null | jq -r '.summary.totalCost // 0' 2>/dev/null)

    if [[ -z "$cost" ]] || [[ "$cost" == "null" ]]; then
        return
    fi

    # Calcul du pourcentage
    local pct=$(echo "$cost $SESSION_COST_LIMIT" | awk '{if($2>0) printf "%d", ($1/$2)*100; else print 0}')
    [[ "$pct" -gt 100 ]] && pct=100

    echo "$pct" > "$cache_file"
    echo "$pct"
}

# -----------------------------------------------------------------------------
# 8. USAGE HEBDOMADAIRE (% de la limite semaine) via ccusage
# -----------------------------------------------------------------------------
get_weekly_usage_pct() {
    [[ "$SHOW_WEEKLY_LIMIT" != "true" ]] && return

    # Cache pour éviter appels répétés
    local cache_file="/tmp/.ccusage_weekly_cache"
    local now=$(date +%s)

    if [[ -f "$cache_file" ]]; then
        local cache_time=$(stat -c %Y "$cache_file" 2>/dev/null || echo 0)
        if [[ $((now - cache_time)) -lt $WEEKLY_CACHE_TTL ]]; then
            cat "$cache_file"
            return
        fi
    fi

    # Vérifier que npx est disponible
    if ! command -v npx &>/dev/null; then
        return
    fi

    local week_ago=$(date -d "7 days ago" +%Y%m%d 2>/dev/null || date -v-7d +%Y%m%d 2>/dev/null)
    [[ -z "$week_ago" ]] && return

    local cost=$(timeout 8 npx --yes ccusage@latest daily --since "$week_ago" --json 2>/dev/null | jq -r '.summary.totalCost // 0' 2>/dev/null)

    if [[ -z "$cost" ]] || [[ "$cost" == "null" ]]; then
        return
    fi

    # Calcul du pourcentage
    local pct=$(echo "$cost $WEEKLY_COST_LIMIT" | awk '{if($2>0) printf "%d", ($1/$2)*100; else print 0}')
    [[ "$pct" -gt 100 ]] && pct=100

    echo "$pct" > "$cache_file"
    echo "$pct"
}

SESSION_USAGE_PCT=$(get_session_usage_pct)
WEEKLY_USAGE_PCT=$(get_weekly_usage_pct)

# -----------------------------------------------------------------------------
# 9. HEURE
# -----------------------------------------------------------------------------
CURRENT_TIME=$(date +"%H:%M")

# -----------------------------------------------------------------------------
# CONSTRUCTION DE LA STATUS LINE
# -----------------------------------------------------------------------------
output=""

# Profil (magenta)
output+="${C_MAGENTA}🔑 ${PROFILE}${C_RESET}"

# Modèle (cyan)
output+=" ${C_DIM}|${C_RESET} ${C_CYAN}${MODEL_EMOJI} ${MODEL_DISPLAY}${C_RESET}"

# Git (vert/jaune selon status)
if [[ -n "$GIT_INFO" ]]; then
    if [[ "$GIT_INFO" == *"+"* ]] || [[ "$GIT_INFO" == *"~"* ]] || [[ "$GIT_INFO" == *"?"* ]]; then
        output+=" ${C_DIM}|${C_RESET} ${C_YELLOW}🌿 ${GIT_INFO}${C_RESET}"
    else
        output+=" ${C_DIM}|${C_RESET} ${C_GREEN}🌿 ${GIT_INFO}${C_RESET}"
    fi
fi

# Projet (bleu)
output+=" ${C_DIM}|${C_RESET} ${C_BLUE}📁 ${PROJECT_NAME}${C_RESET}"

# Contexte (couleur selon seuil)
if [[ -n "$CONTEXT_PCT" ]]; then
    output+=" ${C_DIM}|${C_RESET} ${CONTEXT_COLOR}📊 ${CONTEXT_PCT}%${C_RESET}"
fi

# Usage session (couleur selon seuil)
if [[ -n "$SESSION_USAGE_PCT" ]] && [[ "$SESSION_USAGE_PCT" != "0" ]]; then
    SESSION_COLOR=$(get_usage_color "$SESSION_USAGE_PCT")
    output+=" ${C_DIM}|${C_RESET} ${SESSION_COLOR}${SESSION_LABEL}: ${SESSION_USAGE_PCT}%${C_RESET}"
fi

# Usage hebdomadaire (couleur selon seuil)
if [[ -n "$WEEKLY_USAGE_PCT" ]] && [[ "$WEEKLY_USAGE_PCT" != "0" ]]; then
    WEEKLY_COLOR=$(get_usage_color "$WEEKLY_USAGE_PCT")
    output+=" ${C_DIM}|${C_RESET} ${WEEKLY_COLOR}${WEEKLY_LABEL}: ${WEEKLY_USAGE_PCT}%${C_RESET}"
fi

# Coût (blanc)
output+=" ${C_DIM}|${C_RESET} ${C_WHITE}💰 \$${COST}${C_RESET}"

# Heure (dim)
output+=" ${C_DIM}|${C_RESET} ${C_DIM}🕐 ${CURRENT_TIME}${C_RESET}"

# Output final
printf '%b' "$output"
