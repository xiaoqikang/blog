# 修改git的默认编辑器为vim

git config --global core.editor vim

# git仓库迁移

git远程仓库迁移时，当有多个分支时，需要一个一个分支上传，不仅耗时又容易出错。

可以使用脚本批量操作，执行命令 `bash git_push_all_branch.sh 远程仓库路径`，脚本`git_push_all_branch.sh`如下：

```shell
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
```



