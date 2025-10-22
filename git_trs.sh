#!/bin/sh
set -eu

# --- Couleurs ---
BLUE="\033[1;34m"
GREEN="\033[1;32m"
YELLOW="\033[1;33m"
RED="\033[1;31m"
RESET="\033[0m"

# --- CONFIG --------------------------------------------------------------
REPO_SSH="git@github.com:Mechard-Organization/Ft_transcendence.git"
LOGIN="$(whoami)"

# --- MAPPAGE LOGIN → BRANCHE --------------------------------------------
case "$LOGIN" in
  mechard)  BRANCH="maxime" ;;
  jealefev) BRANCH="jeanne" ;;
  abutet)   BRANCH="lylou" ;;
  mel-yand) BRANCH="medhi" ;;
  ajamshid) BRANCH="abdul" ;;
  *)        BRANCH="$LOGIN" ;; # fallback: branche du même nom que le login
esac

echo -e "👤 Utilisateur détecté : ${BLUE}${LOGIN}${RESET}"
echo -e "🌿 Branche associée : ${GREEN}${BRANCH}${RESET}"

# --- DEMANDER NOM REPO ---
read -rp "📁 Nom du dossier à créer pour le clone (${YELLOW}défaut : Ft_transcendence${RESET}) : " DIR
DIR="${DIR:-ft_transcendence}"

echo -e "📦 Le dépôt sera cloné dans : ${BLUE}${DIR}${RESET}"
echo

# --- CHECK SSH -----------------------------------------------------------
if ! ssh -o BatchMode=yes -T git@github.com 2>&1 | grep -q "success"; then
  echo -e "⚠️  ${RED}SSH GitHub non prêt (pas de clé ou agent non chargé).${RESET}"
  echo -e "   - Ajoute ta clé publique à GitHub : ${YELLOW}https://github.com/settings/keys${RESET}"
  echo -e "   - Lance ${BLUE}ssh-agent${RESET} + ${BLUE}ssh-add${RESET} si besoin."
  echo
fi

# --- CLONE OU MÀJ -------------------------------------------------------
if [ -d "$DIR/.git" ]; then
  echo "📁 Répertoire déjà présent : $DIR"
  cd "$DIR"
  git remote -v | grep -q "$REPO_SSH" || {
    echo "❌ $DIR n'est pas un clone de $REPO_SSH"; exit 1;
  }
  echo "🔄 Mise à jour du dépôt (fetch --all --prune)"
  git fetch --all --prune
else
  echo "⬇️  Clonage du dépôt..."
  git clone "$REPO_SSH" "$DIR"
  cd "$DIR"
fi

# --- SWITCH BRANCHE -----------------------------------------------------
if git show-ref --verify --quiet "refs/heads/$BRANCH"; then
  echo "🔀 Passage sur la branche locale ${GREEN}'${BRANCH}'${RESET}"
  git switch "$BRANCH"
elif git ls-remote --exit-code --heads origin "$BRANCH" >/dev/null 2>&1; then
  echo "🌐 Création de la branche locale depuis ${GREEN}'origin/$BRANCH'${RESET}"
  git switch -c "$BRANCH" --track "origin/$BRANCH"
else
  echo "🆕 Création et publication de la branche ${GREEN}'${BRANCH}'${RESET}"
  git switch -c "$BRANCH"
  git push -u origin "$BRANCH"
fi

echo "✅ Prêt sur la branche : $(git branch --show-current)"