case "$1" in
	"")
		echo "Usage: bash $0 { url }"
		exit 2
	;;
esac

git remote set-url origin "$1"

for branch in `git branch -a | grep remotes | grep -v HEAD`; do
	git branch --track ${branch##*/} $branch
done

git push origin --mirror
