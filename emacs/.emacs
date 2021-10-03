
;; Added by Package.el.  This must come before configurations of
;; installed packages.  Don't delete this line.  If you don't want it,
;; just comment it out by adding a semicolon to the start of the line.
;; You may delete these explanatory comments.
(package-initialize)

(add-to-list 'load-path "~/.emacs.d/lisp/")
(global-linum-mode) ;; 显示行号
(setq make-backup-files nil) ;; 保存时不创建备份文件
(when (fboundp 'electric-indent-mode) (electric-indent-mode -1)) ;; 换行不自动缩进
;; (setq-default indent-tabs-mode nil) ;; tab转为空格
(setq-default tab-width 8) ;; 一个tab显示的宽度
(load-theme 'manoj-dark) ;; colorscheme
(add-hook 'c-mode-common-hook   'hs-minor-mode)

;; cp /home/sonvhi/chenxiaosong/code/cscope/contrib/xcscope/cscope-indexer /home/sonvhi/chenxiaosong/sw/cscope/bin/
;; sudo cp /home/sonvhi/chenxiaosong/code/cscope/contrib/xcscope/xcscope.el /home/sonvhi/.emacs.d/lisp
(setq cscope-do-not-update-database t) ;; 不自动更新
(require 'xcscope)

;; Evil
;; (add-to-list 'load-path "~/.emacs.d/lisp/evil")
;; (require 'evil)
;; (evil-mode 1)
;; (add-hook 'c-mode-common-hook   'outline-minor-mode)

;; (require 'folding)

;; (add-to-list 'load-path "~/.emacs.d/lisp/yafolding.el")
;; (require 'yafolding)
