;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!


;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets.
(setq user-full-name "Ivan Erakhtin"
      user-mail-address "ivan.erakhtin@gmail.com")

;; Doom exposes five (optional) variables for controlling fonts in Doom. Here
;; are the three important ones:
;;
;; + `doom-font'
;; + `doom-variable-pitch-font'
;; + `doom-big-font' -- used for `doom-big-font-mode'; use this for
;;   presentations or streaming.
;;
;; They all accept either a font-spec, font string ("Input Mono-12"), or xlfd
;; font string. You generally only need these two:
;; (setq doom-font (font-spec :family "monospace" :size 12 :weight 'semi-light)
;;       doom-variable-pitch-font (font-spec :family "sans" :size 13))

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:
(setq doom-theme 'doom-one)

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(setq org-directory "~/org/")

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type t)


;; Here are some additional functions/macros that could help you configure Doom:
;;
;; - `load!' for loading external *.el files relative to this one
;; - `use-package!' for configuring packages
;; - `after!' for running code after a package has loaded
;; - `add-load-path!' for adding directories to the `load-path', relative to
;;   this file. Emacs searches the `load-path' when you load packages with
;;   `require' or `use-package'.
;; - `map!' for binding new keys
;;
;; To get information about any of these functions/macros, move the cursor over
;; the highlighted symbol at press 'K' (non-evil users must press 'C-c c k').
;; This will open documentation for it, including demos of how they are used.
;;
;; You can also try 'gd' (or 'C-c c d') to jump to their definition and see how
;; they are implemented.

;; Maxiimize Emacs frame on startup
(add-to-list 'default-frame-alist '(fullscreen . maximized))

;; HS
(map! (:localleader
       (:map (clojure-mode-map clojurescript-mode-map)
        "=" #'cider-format-defun
        "+" #'clojure-align
        (:prefix ("e" . "eval")
         "f" #'cider-eval-defun-at-point
         "F" #'cider-insert-defun-in-repl
         ";" #'cider-pprint-eval-last-sexp)
        (:prefix ("i")
         "p" #'cider-inspector-pop))
       (:map (sql-mode-map)
        "e" #'run-sql))
      (:leader
       (:map (clojure-mode-map clojurescript-mode-map emacs-lisp-mode-map)
        (:prefix ("k" . "lisp")
         "t" #'sp-transpose-sexp
         "j" #'paredit-join-sexps
         "s" #'paredit-split-sexp
         "d" #'sp-kill-sexp
         "D" #'paredit-kill
         "<" #'paredit-backward-barf-sexp
         ">" #'paredit-backward-slurp-sexp
         "." #'paredit-forward-slurp-sexp
         "," #'paredit-forward-barf-sexp
         "r" #'paredit-raise-sexp
         "w" #'paredit-wrap-sexp
         "(" #'paredit-wrap-round
         "[" #'paredit-wrap-square
         "'" #'paredit-meta-doublequote
         "{" #'paredit-wrap-curly
         "y" #'sp-copy-sexp)))
      (:after ivy
       :map ivy-minibuffer-map
       "C-d" #'ivy-switch-buffer-kill))

;; Show Cider in the right side of screen
(after! cider
  (set-popup-rules!
   '(("^\\*cider-repl"
      :side right
      :width 100
      :quit nil
      :ttl nil))))

;; Toggle between unit test and implementation
(map! :leader
      (:prefix-map ("t" . "toggle")
       :desc "implementation <-> test"
       "a" #'projectile-toggle-between-implementation-and-test))

;; Specify Iosevka typeface
(setq doom-font (font-spec :family "Iosevka" :size 18 :weight 'semi-light))

;; Inserts function for handy RDD process
(defun clj-insert-persist-scope-macro ()
  (interactive)
  (insert
   "(defmacro persist-scope
      \"Takes local scope vars and defines them in the global scope.
        Could be useful for RDD.\"
      []
      `(do ~@(map
              (fn [v] `(def ~v ~v))
              (keys (cond-> &env (contains? &env :locals) :locals))))) "))

;; Evaluate persist scope
(defun persist-scope ()
  (interactive)
  (let ((beg (point)))
    (clj-insert-persist-scope-macro)
    (cider-eval-region beg (point))
    (delete-region beg (point))
    (insert "(persist-scope)")
    (cider-eval-defun-at-point)
    (delete-region beg (point))))

;; Toggle Persist-scope
(map! :leader
      (:prefix-map ("t" . "toggle")
       :desc "Persist scope"
       "p" #'persist-scope))

;; https://emacsredux.com/blog/2013/06/13/using-emacs-as-a-database-client/
(setq sql-postgres-login-params
      '((user :default "postgres")
        (database :defaut "postgres")
        (server :default "localhost")
        (port :default 5432)))
