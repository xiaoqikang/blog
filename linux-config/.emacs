(require 'package)
;; M-x package-refresh-contents
(add-to-list 'package-archives
             '("melpa" . "http://mirrors.tuna.tsinghua.edu.cn/elpa/melpa/") t)
;; Added by Package.el.  This must come before configurations of
;; installed packages.  Don't delete this line.  If you don't want it,
;; just comment it out by adding a semicolon to the start of the line.
;; You may delete these explanatory comments.
(package-initialize)

(global-linum-mode) ;; 显示行号
(setq make-backup-files nil) ;; 保存时不创建备份文件
(when (fboundp 'electric-indent-mode) (electric-indent-mode -1)) ;; 换行不自动缩进
;; (setq-default indent-tabs-mode nil) ;; tab转为空格
(setq-default tab-width 8) ;; 一个tab显示的宽度
(load-theme 'manoj-dark) ;; colorscheme
(add-hook 'c-mode-common-hook   'outline-minor-mode) ;; 按indent折叠
;; (add-hook 'c-mode-common-hook   'hs-minor-mode) ;; 按语法折叠
(global-set-key (kbd "TAB") 'self-insert-command) ;; 插入 tab
(global-set-key [?\C-h] 'delete-backward-char) ;; backspace
(global-set-key [?\C-x ?h] 'help-command) ;; overrides mark-whole-buffer


;; cp /home/sonvhi/chenxiaosong/code/cscope/contrib/xcscope/cscope-indexer /home/sonvhi/chenxiaosong/sw/cscope/bin/
(add-to-list 'load-path "/home/sonvhi/chenxiaosong/code/cscope/contrib/xcscope")
(setq cscope-do-not-update-database t) ;; 不自动更新
(require 'xcscope)

;; 打开空白文件时，找不到 cscope 快捷键
(global-set-key (kbd "C-c s =") 'cscope-find-assignments-to-this-symbol) ;; vim: cs find a
(global-set-key (kbd "C-c s c") 'cscope-find-functions-calling-this-function) ;; vim: cs find c
(global-set-key (kbd "C-c s C") 'cscope-find-called-functions) ;; vim: cs find d
(global-set-key (kbd "C-c s e") 'cscope-find-egrep-pattern) ;; vim: cs find e
(global-set-key (kbd "C-c s f") 'cscope-find-this-file) ;; vim: cs find f
(global-set-key (kbd "C-c s g") 'cscope-find-global-definition) ;; vim: cs find g
(global-set-key (kbd "C-c s i") 'cscope-find-files-including-file) ;; vim: cs find i
(global-set-key (kbd "C-c s s") 'cscope-find-this-symbol);; vim: cs find s
(global-set-key (kbd "C-c s t") 'cscope-find-this-text-string) ;; vim: cs find t
(global-set-key (kbd "C-c s u") 'cscope-pop-mark)

(global-set-key (kbd "C-c e t") 'evil-mode) ;; toggle
(global-set-key (kbd "C-c e z c") 'evil-close-fold)
(global-set-key (kbd "C-c e z m") 'evil-close-folds)
(global-set-key (kbd "C-c e z o") 'evil-open-fold)
(global-set-key (kbd "C-c e z O") 'evil-open-fold-rec)
(global-set-key (kbd "C-c e z r") 'evil-open-folds)
(global-set-key (kbd "C-c e z a") 'evil-toggle-fold)
(global-set-key (kbd "C-c e C-o") 'evil-jump-backward)
(global-set-key (kbd "C-c e C-i") 'evil-jump-forward)

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(evil-shift-width 8)
 '(package-selected-packages (quote (evil)))
 '(standard-indent 8))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
