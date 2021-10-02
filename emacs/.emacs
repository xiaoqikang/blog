(global-linum-mode) ;; 显示行号
(setq make-backup-files nil) ;; 保存时不创建备份文件
(when (fboundp 'electric-indent-mode) (electric-indent-mode -1)) ;; 换行不自动缩进
;; (setq-default indent-tabs-mode nil) ;; tab转为空格
(setq-default tab-width 8) ;; 一个tab显示的宽度
(add-hook 'c-mode-common-hook   'hs-minor-mode) ;; 折叠

;; cp /home/sonvhi/chenxiaosong/code/cscope/contrib/xcscope/cscope-indexer /home/sonvhi/chenxiaosong/sw/cscope/bin/
;; sudo cp /home/sonvhi/chenxiaosong/code/cscope/contrib/xcscope/xcscope.el /usr/share/emacs/site-lisp/
(setq cscope-do-not-update-database t) ;; 不自动更新
(require 'xcscope)


