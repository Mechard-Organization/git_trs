#!/usr/bin/env bash
set -euo pipefail

REPO_SSH="git@github.com:Mechard-Organization/Ft_transcendence.git"
DIR="Ft_transcendence"
LOGIN="$(whoami)"

echo "👤 Utilisateur : $LOGIN"

# 1) Vérif rapide que la clé SSH est bien chargée (optionnel mais pratique)
if ! ssh -o BatchMode=yes -T git@github.com 2>&1 | grep -q "success"; then
  echo "⚠️  SSH GitHub non prêt (pas de clé, ou agent non chargé)."
  echo "   - Ajoute ta clé publique à GitHub : https://github.com/settings/keys"
  echo "   - Lance ssh-agent + ssh-add si besoin."
  # on continue quand même : Git affichera une erreur claire au clone si c’est bloqué
fi

# 2) Cloner si nécessaire, sinon se mettre à jour
if [ -d "$DIR/.git" ]; then
  echo "📁 Répertoire déjà présent : $DIR"
  cd "$DIR"
  git remote -v | grep -q "$REPO_SSH" || {
    echo "❌ $DIR n'est pas un clone de $REPO_SSH"; exit 1;
  }
  echo "🔄 git fetch --all --prune"
  git fetch --all --prune
else
  echo "⬇️  Clonage du dépôt…"
  git clone "$REPO_SSH" "$DIR"
  cd "$DIR"
fi

# 3) Basculer sur la branche correspondant au login
#    - si la branche locale existe → switch
#    - sinon si elle existe sur origin → créer branche locale suivie de origin/LOGIN
#    - sinon créer la branche et la publier
if git show-ref --verify --quiet "refs/heads/$LOGIN"; then
  echo "🔀 Passage sur la branche locale '$LOGIN'"
  git switch "$LOGIN"
elif git ls-remote --exit-code --heads origin "$LOGIN" >/dev/null 2>&1; then
  echo "🌐 Suivi de la branche distante 'origin/$LOGIN'"
  git switch -c "$LOGIN" --track "origin/$LOGIN"
else
  echo "🆕 Création de la branche '$LOGIN' et publication"
  git switch -c "$LOGIN"
  git push -u origin "$LOGIN"
fi

echo "✅ Prêt sur la branche : $(git branch --show-current)"
