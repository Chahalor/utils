#!/usr/bin/env bash

set -uo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)" || exit 1

usage() {
	printf 'Usage: %s {pull|push|status|switch branch|merge [message de commit]}\n' "$0"
	printf 'merge : add -A, commit, pull --rebase puis push de la branche courante.\n'
}

action="${1:-}"
case "$action" in
	pull|push|status)
		if (( $# != 1 )); then
			usage >&2
			exit 2
		fi
		;;
	switch)
		if (( $# != 2 )) || [[ -z "$2" ]]; then
			usage >&2
			exit 2
		fi
		;;
	merge)
		;;
	-h|--help)
		usage
		exit 0
		;;
	*)
		usage >&2
		exit 2
		;;
esac
shift
target_branch="${1:-}"
commit_message="${*:-Auto commit}"

run_action() {
	local branch
	if [[ "$action" == status ]]; then
		git status
		return
	fi
	if [[ "$action" == switch ]]; then
		git switch -- "$target_branch"
		return
	fi

	branch="$(git symbolic-ref --quiet --short HEAD)" || {
		printf 'Erreur : aucune branche courante (HEAD détachée).\n' >&2
		return 1
	}
	git remote get-url origin >/dev/null || return 1

	case "$action" in
		pull)
			git pull origin "$branch"
			;;
		push)
			if [[ "$branch" == main ]]; then
				git push origin refs/heads/main:refs/heads/main
			else
				git push origin "refs/heads/$branch:refs/heads/$branch" refs/heads/main:refs/heads/main
			fi
			;;
		merge)
			git add -A || return 1
			git diff --cached --quiet
			case $? in
				0) printf 'Aucun changement à commiter.\n' ;;
				1) git commit -m "$commit_message" || return 1 ;;
				*) return 1 ;;
			esac
			git pull --rebase origin "$branch" || return 1
			git push origin "refs/heads/$branch:refs/heads/$branch"
			;;
	esac
}

result=0
repository_count=0
for repository in "$script_dir"/*/; do
	# Only the sibling checkouts: do not process their nested submodules again.
	[[ -e "$repository.git" ]] || continue
	repository_count=$((repository_count + 1))
	printf '\n========== %s ==========\n' "$(basename -- "$repository")"
	if ! (cd -- "$repository" && run_action); then
		printf 'Échec de %s dans %s ; poursuite sur les autres dépôts.\n' "$action" "$repository" >&2
		result=1
	fi
done

if (( repository_count == 0 )); then
	printf 'Aucun dépôt Git trouvé dans %s.\n' "$script_dir" >&2
	exit 1
fi
exit "$result"
