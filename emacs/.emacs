(add-to-list 'load-path "~/.emacs.d/lisp/")
(add-to-list 'load-path "~/.emacs.d/lisp/evil")
;; (add-to-list 'load-path "~/.emacs.d/lisp/vimish-fold")
;; (add-to-list 'load-path "~/.emacs.d/lisp/evil-vimish-fold")
;; (add-to-list 'load-path "~/.emacs.d/lisp/origami")
(add-to-list 'load-path (expand-file-name "~/.emacs.d/lisp/origami"))
(global-linum-mode) ;; 显示行号
(setq make-backup-files nil) ;; 保存时不创建备份文件
(when (fboundp 'electric-indent-mode) (electric-indent-mode -1)) ;; 换行不自动缩进
;; (setq-default indent-tabs-mode nil) ;; tab转为空格
(setq-default tab-width 2) ;; 一个tab显示的宽度

;; cp /home/sonvhi/chenxiaosong/code/cscope/contrib/xcscope/cscope-indexer /home/sonvhi/chenxiaosong/sw/cscope/bin/
;; sudo cp /home/sonvhi/chenxiaosong/code/cscope/contrib/xcscope/xcscope.el /home/sonvhi/.emacs.d/lisp
(setq cscope-do-not-update-database t) ;; 不自动更新
(require 'xcscope)

;; Enable Evil
(require 'evil)
;; (require 'vimish-fold)
;; (require 'evil-vimish-fold)
;; (outline-mode)
;; (outline-minor-mode)
;; (add-hook 'c-mode-common-hook   'hs-minor-mode) ;; 折叠
(require 'origami)
;; (origami-mode)
