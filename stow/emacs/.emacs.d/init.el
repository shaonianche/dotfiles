;; ~/.emacs.d/init.el
;; --- Basic Setup ---
(menu-bar-mode -1)
(setq inhibit-startup-message t)
(setq inhibit-startup-screen t)
(setq visible-bell t)
(setq-default cursor-type 'bar)

(set-language-environment "UTF-8")
(set-default-coding-systems 'utf-8)
(set-terminal-coding-system 'utf-8)
(set-keyboard-coding-system 'utf-8)
(prefer-coding-system 'utf-8)

;; --- UI Enhancements ---
(global-display-line-numbers-mode 1)
(column-number-mode 1)
(global-hl-line-mode 1)
(setq display-line-numbers-type 'relative)
(setq scroll-step 1
      scroll-conservatively 101
      auto-window-vscroll nil)

;; --- Editing Behavior ---
(setq-default indent-tabs-mode nil)
(setq-default tab-width 4)
(setq-default require-final-newline t)
(delete-selection-mode 1)

;; -- Search ---
(setq search-highlight t)
(setq query-replace-highlight t)
(setq case-fold-search t)

;; -- Backup ---
(setq make-backup-files nil)
(setq auto-save-default nil)
(setq create-lockfiles nil)
