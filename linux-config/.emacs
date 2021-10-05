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

;; cp /home/sonvhi/chenxiaosong/code/cscope/contrib/xcscope/cscope-indexer /home/sonvhi/chenxiaosong/sw/cscope/bin/
(add-to-list 'load-path "/home/sonvhi/chenxiaosong/code/cscope/contrib/xcscope")
(setq cscope-do-not-update-database t) ;; 不自动更新
(require 'xcscope)
(global-set-key (kbd "C-c s g") 'cscope-find-global-definition) ;; 打开空白文件时，找不到 cscope 快捷键

(global-set-key (kbd "C-c e t") 'evil-mode) ;; toggle
(global-set-key (kbd "C-c e z c") 'evil-close-fold)
(global-set-key (kbd "C-c e z m") 'evil-close-folds)
(global-set-key (kbd "C-c e z o") 'evil-open-fold)
(global-set-key (kbd "C-c e z O") 'evil-open-fold-rec)
(global-set-key (kbd "C-c e z r") 'evil-open-folds)
(global-set-key (kbd "C-c e z a") 'evil-toggle-fold)

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages (quote (evil))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
