;;--------------------------------------------------------------------------
;; Set the load path for the add-on packages

(setq load-path (append load-path (list "/usr/local/share/emacs/site-lisp")))

;;--------------------------------------------------------------------------
;; add automatic untabify when saving files

(defun untabify-file (&optional arg)
  "Untabify file, helps when editing in vi"
  (untabify (point-min) (point-max)))

;;(add-hook 'write-file-hooks 'cn-untabify-file)


;;--------------------------------------------------------------------------
;; Time stamp stuff, for templates

(load "time-stamp")

(defun time-stamp-mm-dd-yy ()
  "Return the current date as a string in \"MM.DD.YY\" form."
  (let ((date (current-time-string)))
    (format "%02d.%02d.%s"
        (cdr (assoc (substring date 4 7) time-stamp-month-numbers))
        (string-to-int (substring date 8 10))
        (substring date -2)
        )))

(defun time-stamp-yyyy ()
  "Return the current date as a string in \"YYYY\" form."
  (let ((date (current-time-string)))
    (format "%s"
        (substring date -4)
        )))




;;; Unset some c-mode indentation stuff, prep for cc-mode
;; (fmakunbound 'c-mode)
;; (makunbound 'c-mode-map)
;; (fmakunbound 'c++-mode)
;; (makunbound 'c++-mode-map)
;; (makunbound 'c-style-alist)

;;--------------------------------------------------------------------------
;; Automatic mode determination

;; Perl mode stuff
(autoload 'cperl-mode "cperl-mode" "alternate mode for editing Perl programs" t)

;;; add new cc-mode, which works better than the GNU supplied version
(require 'cc-mode)
(setq auto-mode-alist
      (append
       '(("\\.C$"  . c++-mode)
         ("\\.H$"  . c-mode)
         ("\\.cc$" . c++-mode)
         ("\\.hh$" . c++-mode)
         ("\\.cxx$" . c++-mode)
         ("\\.hxx$" . c++-mode)
         ("\\.c$"  . c-mode)
         ("\\.h$"  . c++-mode)
         ("\\.m$"  . objc-mode)
         ("\\.[Pp][Llm]$"  . cperl-mode)
         ) auto-mode-alist))

;;--------------------------------------------------------------------------
;; Indentation & Style

(setq-default c-basic-offset 4)
(setq-default c-tab-always-indent nil)
(setq-default tab-width 4)

(defconst std-c-style
  '((c-hanging-braces-alist        . ((substatement-open after)
                                      (brace-list-open)))
    (c-hanging-colons-alist        . ((member-init-intro before)
                                      (inher-intro)
                                      (case-label after)
                                      (label after)
                                      (access-label after)))
    (c-cleanup-list                . (scope-operator
                                      empty-defun-braces
                                      defun-close-semi))
    (c-offsets-alist               . ((arglist-close     . c-lineup-arglist)
                                      (substatement-open . 0)
                                      (case-label        . 0)
                                      (block-open        . 0)
                                      (knr-argdecl-intro . 0)))
    (c-tab-always-indent nil)
    )
  "STD")

;; Customizations for all of c-mode, c++-mode, and objc-mode
(defun my-c-mode-common-hook ()
  ;; add my personal style and set it for the current buffer
  (c-add-style "STD" std-c-style t)
  ;; other customizations
  (setq indent-tabs-mode nil)
  ;; we like auto-newline and hungry-delete
  ;; (c-toggle-auto-hungry-state 1)
  ;; keybindings for C, C++, and Objective-C.  We can put these in
  ;; c-mode-map because c++-mode-map and objc-mode-map inherit it
  ;;  (define-key c-mode-map "\C-m" 'newline-and-indent)
  (define-key c-mode-map "\C-chC" 'tempo-template-harvey-cxxfile)
  (define-key c-mode-map "\C-chH" 'tempo-template-harvey-hxxfile)
  (define-key c-mode-map "\C-chb" 'tempo-template-harvey-comment)
  (define-key c-mode-map "\C-chf" 'tempo-template-harvey-memfunc)
  (define-key c-mode-map "\C-chr" 'tempo-template-harvey-routine)
  (define-key c-mode-map "\C-chc" 'tempo-template-harvey-class)
  (define-key c-mode-map "\C-cht" 'tempo-template-harvey-try-catch)
  (c-set-style "STD"))

;; the following only works in Emacs 19
;; Emacs 18ers can use (setq c-mode-common-hook 'my-c-mode-common-hook)
(add-hook 'c-mode-common-hook 'my-c-mode-common-hook)
;(add-hook 'c-mode-common-hook 'untabify-file)


;;; Here's my .emacs file.  If you have questions, ask.  Not all things
;;; included here actually work.  Should be commented.
;;; Overload some of the mail functions so they work the way
;;; I want them to
;; (load "~/.emacs.19-overload")
;;(setq debug-on-error 1)

;; disable stupid novice confirmation features
;(fset 'yes-or-no-p 'y-or-n-p)

;;; Define a variable to indicate whether we're running XEmacs/Lucid Emacs.
;;; (You do not have to defvar a global variable before using it --
;;; you can just call `setq' directly like we do for `emacs-major-version'
;;; below.  It's clearer this way, though.)

(defvar running-xemacs (string-match "XEmacs\\|Lucid" emacs-version))

(setq interpreter-mode-alist (append interpreter-mode-alist
									 '(("miniperl" . cperl-mode))))

;;; Force the compile buffer to automatically scroll
(eval-after-load "compile"
'(defadvice compile-internal (after my-scroll act comp)
  "Forces compile buffer to scroll. See around line 363 in compile.el"
  (let* ((ob (current-buffer))
         )
    (save-excursion
      (select-window (get-buffer-window ad-return-value))
      (goto-char (point-max))
      (select-window (get-buffer-window ob))
      ))))

(cond ((not running-xemacs)
	  (scroll-bar-mode -1)))


(setq compile-command "make all")
(setq default-case-fold-search nil)
(setq case-fold-search nil)

(cond (running-xemacs
	   (keyboard-translate 'delete 'deletechar)
	   (keyboard-translate 'backspace 'delete)
	   ))

;;;; rearrange keys to be more vi-like
(global-unset-key "\C-z")
(define-key global-map "\C-v" 'kill-line)
(define-key global-map "\C-y" 'kill-ring-save)
(define-key global-map "\C-p" 'yank)

(define-key global-map "\C-k" 'previous-line)
(define-key global-map "\C-j" 'next-line)
(define-key global-map "\C-h" 'backward-char)
(define-key global-map "\C-l" 'forward-char)
(define-key global-map "\C-f" 'scroll-up)
(define-key global-map "\C-b" 'scroll-down)
(define-key global-map "\C-zv"	'describe-variable)
(define-key global-map "\C-zw"	'where-is)
(define-key global-map "\C-zt"	'help-with-tutorial)
(define-key global-map "\C-zs"	'describe-syntax)
(define-key global-map "\C-zn"	'view-emacs-news)
(define-key global-map "\C-z\C-n" 'view-emacs-news)
(define-key global-map "\C-zm"	'describe-mode)
(define-key global-map "\C-zl"	'view-lossage)
(define-key global-map "\C-zi"	'info)
(define-key global-map "\C-zf"	'describe-function)
(define-key global-map "\C-zd"	'describe-function)
(define-key global-map "\C-zk"	'describe-key)
(define-key global-map "\C-zc"	'describe-key-briefly)
(define-key global-map "\C-zb"	'describe-bindings)
(define-key global-map "\C-za"	'command-apropos)
(define-key global-map "\C-z\C-w" 'describe-no-warranty)
(define-key global-map "\C-z\C-d" 'describe-distribution)
(define-key global-map "\C-z\C-c" 'describe-copying)
(define-key global-map "\C-z\?"	'help-for-help)
(define-key global-map "\C-z\C-h" 'help-for-help)

(cond (running-xemacs
	   (global-set-key [ (control \,) ] 'backward-word)
	   (global-set-key [ (control \.) ] 'forward-word)
	   (global-set-key [ (control delete) ] 'backward-kill-word)
	   (global-set-key [ (control backspace) ] 'backward-kill-word)
	   (global-set-key [ (backspace) ] 'backward-char)
	   (setq delete-key-deletes-forward 'nil)
	   )
	  (t
	   (global-set-key [ (control backspace) ] 'backward-kill-word)
	   (global-set-key [?\C-,] 'backward-word)
	   (global-set-key [?\C-.] 'forward-word)))

(add-hook 'cperl-mode-hook
		  '(lambda ()
			 (define-key cperl-mode-map "\C-j" 'next-line)
			 (define-key cperl-mode-map "\C-h" 'backward-char)
			 (define-key cperl-mode-map "\C-zv" 'cperl-get-help)
			 (define-key cperl-mode-map "\C-zf" 'cperl-info-on-command)))

;;; macro to insert ifdef debug/endif pairs, and put endif line into yank buffer
(fset 'cn-insert-ifdef-debug
   [?\C-a ?# ?i ?f ?d ?e ?f ?  ?D ?E ?B ?U ?G return ?# ?e ?n ?d ?i ?f ?  ?/ ?* ?  ?D ?E ?B ?U ?G ?  ?* ?/ return ?\C-k 67108896 ?\C-j ?\C-w])

;(define-key c-mode-map "\C-ci" 'cn-insert-ifdef-debug)
;(define-key c-mode-map "\C-c\C-i" 'tempo-template-cstmt)

;;; functions to switch point to matching paren, like vi
(defun match-paren (arg)
  "Go to the matching parenthesis if on parenthesis otherwise insert %."
  (interactive "p")
  (cond ((looking-at "\\s\(") (forward-sexp 1) (backward-char 1))
		((looking-at "\\s\)") (forward-char 1) (backward-sexp 1))
		((looking-at "\\s\{") (forward-sexp 1) (backward-char 1))
		((looking-at "\\s\}") (forward-char 1) (backward-sexp 1))
		((looking-at "\\s\[") (forward-sexp 1) (backward-char 1))
		((looking-at "\\s\]") (forward-char 1) (backward-sexp 1))
		(t (self-insert-command (or arg 1)))))

;(define-key c-mode-map "%" 'match-paren)

(cond (window-system
       (add-hook 'emacs-lisp-mode-hook 'turn-on-font-lock)
;;;       ;; start font lock after a file is read
;;;       (add-hook 'find-file-hooks 'turn-on-font-lock)
;;;       ;; with rmail, fontify buffer as soon as a new message is
;;;       ;; displayed, and let font-lock be turned on.
;;;       (add-hook 'rmail-show-message-hook 'turn-on-font-lock)
;;;       ;; with dired, fontify buffer as soon as directory is loaded
;;;       (add-hook 'dired-after-readin-hook 'turn-on-font-lock)
;;;       ;; decorate everything ...
       (setq font-lock-maximum-decoration t)
;;;       ;; ... no matter how large the file is
       (setq font-lock-maximum-size nil)
;;;       ;; ... don't display messages
       (setq font-lock-verbose nil)
;;;       ;; ... use font lock with dired (Mosur K. Mohan)
       (add-hook 'c-mode-hook 'turn-on-font-lock)
       (add-hook 'c++-mode-hook 'turn-on-font-lock)
       (add-hook 'cperl-mode-hook 'turn-on-font-lock)
       (setq dired-font-lock-keywords
             '(
               ;; Directory headers are defun's
               ("^  \\(/.+\\)" 1 font-lock-function-name-face)
               ;; Symlinks are references
               ("\\([^ ]+\\) -> [^ ]+$" . font-lock-reference-face)
               ;; Marks are keywords
               ("^[^ ]" . font-lock-keyword-face)
               ;; Subdirectories are defun's
               ("^..d.* \\([^ ]+\\)$" 1 font-lock-function-name-face)
               ))
       ))

(defun my-font-lock-setup ()
; (set-face-foreground font-lock-comment-face "Aquamarine")
; (set-face-foreground font-lock-reference-face "Aquamarine")
; (set-face-foreground font-lock-function-name-face "Green")
; (set-face-foreground font-lock-type-face "Coral")
; (set-face-foreground font-lock-string-face "Wheat")
; (set-face-foreground font-lock-keyword-face "White")
; (set-face-foreground font-lock-variable-name-face "LightGoldenrod")

 (cond (running-xemacs
		(set-face-foreground font-lock-comment-face "ForestGreen")
		(set-face-foreground font-lock-reference-face "DimGrey")
		(set-face-foreground font-lock-function-name-face "MidnightBlue")
		(set-face-foreground font-lock-type-face "Firebrick")
		(set-face-foreground font-lock-string-face "DarkOliveGreen")
		(set-face-foreground font-lock-keyword-face "SlateBlue")
		(set-face-foreground font-lock-variable-name-face "DarkOrchid"))
	   (t
		(set-face-foreground font-lock-comment-face "ForestGreen")
		(set-face-foreground font-lock-reference-face "DimGrey")
		(set-face-foreground font-lock-function-name-face "MidnightBlue")
		(set-face-foreground font-lock-type-face "Firebrick")
		(set-face-foreground font-lock-string-face "DarkOliveGreen")
		(set-face-foreground font-lock-keyword-face "SlateBlue")
		(set-face-foreground font-lock-variable-name-face "DarkOrchid"))
;		(set-face-foreground font-lock-comment-face "PaleGreen")
;		(set-face-foreground font-lock-reference-face "PaleGoldenrod")
;		(set-face-foreground font-lock-function-name-face "LightCyan")
;		(set-face-foreground font-lock-type-face "Coral")
;		(set-face-foreground font-lock-string-face "Moccasin")
;j		(set-face-foreground font-lock-keyword-face "LightBlue")
;		(set-face-foreground font-lock-variable-name-face "LightGoldenrod")))
	   )

;;; (set-face-foreground font-lock-other-emphasized-face "PaleVioletRed")
;;; (set-face-foreground font-lock-emphasized-face "SandyBrown")
 (remove-hook 'font-lock-mode-hook 'my-font-lock-setup))

(add-hook 'font-lock-mode-hook 'my-font-lock-setup)
(defun turn-on-auto-fill ()
  (auto-fill-mode))

;; Maybe load the mail settings
;;(cond ((not running-xemacs)
;;	   (load "~/.emacs-mail")))

;;; Miscellaneous hooks
(add-hook 'text-mode-hook 'turn-on-auto-fill)
(add-hook 'fundamental-mode-hook 'turn-on-auto-fill)

;;; TAGS table init
(setq tags-table-list '("./TAGS" "/harvey_distrib/TAGS"))

;;; Set the highlight colors more readable, for isearch and RMAIL
(set-face-foreground 'highlight "Gold")
(set-face-background 'highlight "DarkSlateGray")

;;; set isearch to highlight the match (default is region face)
(setq search-highlight t)
(if (x-display-color-p)
	(copy-face 'highlight 'isearch))

;;;set the mode line number formats
;;(let ((entry (member '(line-number-mode "L%l--") mode-line-format)))
;;  (setcar entry (cons '(line-number-mode "L%l/%c--") (cdr entry)))
;;  (line-number-mode 1))

;; Options Menu Settings
;; =====================
(cond
 ((and (string-match "XEmacs" emacs-version)
       (boundp 'emacs-major-version)
       (or (and
            (= emacs-major-version 19)
            (>= emacs-minor-version 14))
           (= emacs-major-version 20))
       (fboundp 'load-options-file))
  (load-options-file "/home/carl/.xemacs-options")))
;; ============================
;; End of Options Menu Settings
(custom-set-variables
  ;; custom-set-variables was added by Custom -- don't edit or cut/paste it!
  ;; Your init file should contain only one such instance.
 '(add-log-full-name "Carl Nygard" t)
 '(add-log-mailing-address "carl@3sinc.com" t)
 '(auto-compression-mode t nil (jka-compr))
 '(cperl-break-one-line-blocks-when-indent nil)
 '(cperl-continued-statement-offset 4)
 '(cperl-font-lock t)
 '(cperl-indent-level 4)
 '(cperl-indent-region-fix-constructs nil)
 '(cperl-under-as-char t)
 '(current-language-environment "UTF-8")
 '(cvs-allow-dir-commit t)
 '(cvs-dired-use-hook (quote always) t)
 '(default-input-method "rfc1345")
 '(face-font-family-alternatives (quote (("monospace" "regular") ("courier" "fixed") ("helv" "helvetica" "arial" "fixed"))))
 '(indent-tabs-mode nil)
 '(kept-new-versions 3)
 '(kept-old-versions 3)
 '(load-home-init-file t t)
 '(perl-indent-level 2)
 '(query-user-mail-address nil)
 '(tab-width 4)
 '(text-mode-hook (quote (turn-on-auto-fill text-mode-hook-identify)))
 '(user-mail-address "carl@czech.3sinc.com")
 '(version-control t)
 '(visible-bell t)
 '(zmacs-regions nil))
(custom-set-faces
  ;; custom-set-faces was added by Custom -- don't edit or cut/paste it!
  ;; Your init file should contain only one such instance.
 '(default ((t (:stipple nil :background "#ffffff" :foreground "#000000" :inverse-video nil :box nil :strike-through nil :overline nil :underline nil :slant normal :weight normal :height 116 :width normal :family "adobe-courier"))))
 '(cperl-array-face ((t (:foreground "Blue" :weight bold))))
 '(cperl-hash-face ((t (:foreground "Red" :slant italic :weight bold)))))

(setq minibuffer-max-depth nil)
