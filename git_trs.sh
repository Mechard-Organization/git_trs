#!/bin/sh
set -eu

# --- Couleurs (ANSI) ---
BLUE="\033[1;34m"
GREEN="\033[1;32m"
YELLOW="\033[1;33m"
RED="\033[1;31m"
RESET="\033[0m"

# --- CONFIG ---

REPO_SSH="git@github.com:Mechard-Organization/Ft_transcendence.git"
LOGIN="$(whoami)"

# --- MAPPAGE LOGIN → BRANCHE ---
case "$LOGIN" in
  mechard)  BRANCH="maxime" ;;
  jealefev) BRANCH="jeanne" ;;
  abutet)   BRANCH="lylou" ;;
  mel-yand) BRANCH="medhi" ;;
  ajamshid) BRANCH="abdul" ;;
  *)        BRANCH="$LOGIN" ;;
esac

printf '%b\n' "👤 Utilisateur détecté : ${BLUE}${LOGIN}${RESET}"
printf '%b\n' "🌿 Branche associée : ${GREEN}${BRANCH}${RESET}"
printf '\n'

# --- DEMANDER NOM REPO ---
printf '%b' "📁 Nom du dossier à créer pour le clone (${YELLOW}défaut: ft_transcendence${RESET}) : "
IFS= read -r DIR || true
: "${DIR:=ft_transcendence}"

printf '%b\n' "📦 Le dépôt sera cloné dans : ${BLUE}${DIR}${RESET}"
printf '\n'

# --- CHECK SSH ---
if ! ssh -o BatchMode=yes -T git@github.com 2>&1 | grep -q "success"; then
  printf '%b\n' "⚠️  ${RED}SSH GitHub non prêt (pas de clé ou agent non chargé).${RESET}"
  printf '%b\n' "   - Ajoute ta clé publique à GitHub : ${YELLOW}https://github.com/settings/keys${RESET}"
  printf '%b\n' "   - Lance ${BLUE}ssh-agent${RESET} + ${BLUE}ssh-add${RESET} si besoin."
  printf '\n'
fi

# --- CLONE OU MÀJ ---
if [ -d "$DIR/.git" ]; then
  printf '%s\n' "📁 Répertoire déjà présent : $DIR"
  cd "$DIR"
  if ! /bin/git remote -v | grep -q "$REPO_SSH"; then
    printf '%b\n' "❌ ${RED}$DIR n'est pas un clone de $REPO_SSH${RESET}"
    exit 1
  fi
  printf '%s\n' "🔄 Mise à jour du dépôt (fetch --all --prune)"
  /bin/git fetch --all --prune > /dev/null 2>&1
else
  printf '%s\n' "⬇️  Cloning into '${BLUE} ${DIR} ${RESET}'... "
  /bin/git clone "$REPO_SSH" "$DIR" > /dev/null 2>&1
  cd "$DIR"
fi

# --- SWITCH BRANCHE ---
if /bin/git show-ref --verify --quiet "refs/heads/$BRANCH"; then
  printf '%b\n' "🔀 Passage sur la branche locale ${GREEN}'${BRANCH}'${RESET}"
  /bin/git switch "$BRANCH" > /dev/null 2>&1
elif /bin/git ls-remote --exit-code --heads origin "$BRANCH" >/dev/null 2>&1; then
  printf '%b\n' "🌐 Création de la branche locale depuis ${GREEN}'origin/$BRANCH'${RESET}"
  /bin/git switch -c "$BRANCH" --track "origin/$BRANCH" > /dev/null 2>&1
else
  printf '%b\n' "🆕 Création et publication de la branche ${GREEN}'${BRANCH}'${RESET}"
  /bin/git switch -c "$BRANCH" > /dev/null 2>&1
  /bin/git push -u origin "$BRANCH" > /dev/null 2>&1
fi

printf '%s\n' "✅ Prêt sur la branche : $(git branch --show-current)"
