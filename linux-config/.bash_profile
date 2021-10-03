export PATH=/home/sonvhi/chenxiaosong/sw/go1.17.1.linux-amd64/bin:/home/sonvhi/chenxiaosong/sw/cscope/bin:$PATH

function title() {
	if [[ -z "$ORIG" ]]; then
		ORIG=$PS1
	fi
	TITLE="\[\e]2;$*\a\]"
	PS1=${ORIG}${TITLE}
}
