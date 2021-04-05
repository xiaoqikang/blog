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

# 修改git的默认编辑器为vim

`git config --global core.editor vim`

# fedora33无法ssh到低版本系统（如centos4.8）

在Fedora33系统下`vim ~/.ssh/config` 添加以下内容

```
Host *
KexAlgorithms +diffie-hellman-group1-sha1
```

然后再更改权限：`sudo chmod 600 config`

或者使用命令: `ssh -oHostKeyAlgorithms=+ssh-dss -oKexAlgorithms=+diffie-hellman-group1-sha1  root@192.168.122.40`

# shell ctrl+s锁死解决办法

shell搜索历史命令，ctrl+r搜索更早的历史命令，但ctrl + s搜索更新的历史命令会锁死，可输入**`stty -ixon`**解决。