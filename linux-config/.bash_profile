export PATH=/home/sonvhi/chenxiaosong/sw/go1.17.1.linux-amd64/bin:/home/sonvhi/chenxiaosong/sw/cscope/bin:$PATH

# 设置 terminal 标签名称， 用法： title tab name
function title() {
	if [[ -z "$ORIG" ]]; then
		ORIG=$PS1
	fi
	TITLE="\[\e]2;$*\a\]"
	PS1=${ORIG}${TITLE}
}

stty -ixon # 搜索历史命令，ctrl + s不锁屏
