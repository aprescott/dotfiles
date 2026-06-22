(setq backup-directory-alist `(("." . "~/.emacs.d/backups")))

(setq inhibit-startup-screen t)
(setq comment-empty-lines t)
(menu-bar-mode -1)

(require 'package)
(add-to-list 'package-archives
             '("melpa" . "http://melpa.org/packages/") t)

(use-package kkp
  :ensure t
  :hook (tty-setup . global-kkp-mode)
  :config
  ;; (setq kkp-alt-modifier 'alt) ;; use this if you want to map the Alt keyboard modifier to Alt in Emacs (and not to Meta)
  )

;; bind cmd+backspace to delete backward to the start of the line (kill-line 0),
;; unless the line is empty, in which case just backspace.
(global-set-key (kbd "s-<backspace>") (lambda ()
  (interactive)
  (if (string-empty-p (buffer-substring-no-properties (line-beginning-position) (point)))
      (delete-backward-char 1)
    (kill-line 0))))

;; bind cmd-shift-enter to insert a blank line above the current line and move the cursor to it.
(global-set-key (kbd "s-S-<return>") (lambda ()
  (interactive)
  (save-excursion
    (beginning-of-line)
    (newline))))

;; cmd-/ to toggle comments for the current line or selected region, including
;; removing comments if the line or region is already commented.
;;
;; If the line is blank, act as if it's commented but with a single space.
;;
;; If the line is just a comment marker, then make the line empty.
;;
;; Syntax-aware, so it will use the correct comment marker for the current major
;; mode.
(defun my/toggle-comment-line-or-region ()
  "Toggle comment on current line or region with special blank-line handling."
  (interactive)
  (if (use-region-p)
      (comment-or-uncomment-region (region-beginning) (region-end))
    (let ((line (buffer-substring-no-properties (line-beginning-position) (line-end-position))))
      (cond
        ((string-match-p "^\\s-*$" line)
         ;; Blank line: insert full-line comment. For Lisp-like modes, use double comment markers.
         (let ((full-line-marker
                (if (derived-mode-p 'lisp-mode 'emacs-lisp-mode 'scheme-mode)
                    (concat comment-start comment-start)
                  comment-start)))
           (delete-region (line-beginning-position) (line-end-position))
           (insert (concat (make-string (current-column) ?\s) full-line-marker " "))))
        ((string-match-p (concat "^\\s-*" (regexp-quote comment-start) "\\s-*$") line)
         ;; Only comment marker: make empty
         (delete-region (line-beginning-position) (line-end-position)))
        (t
         ;; Normal toggle
         (save-excursion
           (comment-line 1)))))))

(global-set-key (kbd "s-/") 'my/toggle-comment-line-or-region)

;; cmd-x to cut the entire current line (not just the current position to the
;; end of the line) if no region is active, otherwise cut the region.
;;
;; Places the contents into the system clipboard.
(global-set-key (kbd "s-x")
                (lambda ()
                  (interactive)
                  (let ((text (if (use-region-p)
                                  (buffer-substring (region-beginning) (region-end))
                                (buffer-substring (line-beginning-position) (line-end-position)))))
                    (if (use-region-p)
                        (kill-region (region-beginning) (region-end))
                      (kill-whole-line))
                    (kill-new text))))

;; cmd-v to paste from system clipboard
(global-set-key (kbd "s-v")
                (lambda ()
                  (interactive)
                  (yank)))

;; cmd-z to undo
(global-set-key (kbd "s-z")
                (lambda ()
                  (interactive)
                  (undo)))

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages nil))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
