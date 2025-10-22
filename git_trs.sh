#!/bin/sh
set -eu

# --- CONFIG --------------------------------------------------------------
REPO_SSH="git@github.com:Mechard-Organization/Ft_transcendence.git"
DIR="Ft_transcendence"
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

echo "👤 Utilisateur détecté : $LOGIN"
echo "🌿 Branche associée : $BRANCH"

# --- DEMANDER NOM REPO ---
read -rp "📁 Nom du dossier à créer pour le clone (défaut : Ft_transcendence) : " DIR
DIR="${DIR:-ft_transcendence}"

echo "📦 Le dépôt sera cloné dans : $DIR"
echo

# --- CHECK SSH -----------------------------------------------------------
if ! ssh -o BatchMode=yes -T git@github.com 2>&1 | grep -q "success"; then
  echo "⚠️  SSH GitHub non prêt (pas de clé ou agent non chargé)."
  echo "   - Ajoute ta clé publique à GitHub : https://github.com/settings/keys"
  echo "   - Lance ssh-agent + ssh-add si besoin."
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
  echo "🔀 Passage sur la branche locale '$BRANCH'"
  git switch "$BRANCH"
elif git ls-remote --exit-code --heads origin "$BRANCH" >/dev/null 2>&1; then
  echo "🌐 Création de la branche locale depuis 'origin/$BRANCH'"
  git switch -c "$BRANCH" --track "origin/$BRANCH"
else
  echo "🆕 Création et publication de la branche '$BRANCH'"
  git switch -c "$BRANCH"
  git push -u origin "$BRANCH"
fi

echo "✅ Prêt sur la branche : $(git branch --show-current)"