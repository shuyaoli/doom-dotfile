;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-
(setq user-full-name "Shuyao Li"
      user-mail-address "shuyao@connect.hku.hk"
      doom-font (font-spec :family "Menlo" :size 18)
      doom-variable-pitch-font (font-spec :family "sans serif" :size 18)
      display-line-numbers-type 'nil ; or nil or relative
      doom-theme 'doom-one
      general-override-mode 't ; essential to Doom)

;;; Setup doom default window setup
(pushnew! default-frame-alist '(width . 80) '(height . 40)) ; 80 * 40
(add-hook 'window-setup-hook #'toggle-frame-maximized)         ; maxized
;; (add-hook 'window-setup-hook #'toggle-frame-fullscreen)     ; fullscreen

;; Set org-directory must be set before org loads!
(setq org-directory "~/Documents/org/"
      org-roam-directory "~/Dropbox (MIT)/org-roam-notes/")

(if (daemonp)
    (setq use-package-always-demand t))

;; To get information about any functions/macros, move the cursor over the
;; highlighted symbol at press 'K' (non-evil users must press 'C-c c k'). This
;; will open documentation for it, including demos of how they are used.
;;
;; You can also try 'gd' (or 'C-c c d') to jump to their definition and see how
;; they are implemented.

(setq use-package-enable-imenu-support t)

;; (map! :map general-override-mode-map
      ;; :ei "s-SPC" #'doom/leader)

(when (featurep 'ns)
  (defun ns-raise-emacs ()
    "Raise Emacs."
    (ns-do-applescript "tell application \"Emacs\" to activate"))

  (defun ns-raise-emacs-with-frame (frame)
    "Raise Emacs and select the provided frame."
    (with-selected-frame frame
      (when (display-graphic-p)
        (ns-raise-emacs))))

  (add-hook 'after-make-frame-functions 'ns-raise-emacs-with-frame)

  (when (display-graphic-p)
    (ns-raise-emacs)))

(defun unfill-paragraph (&optional region)
  "Takes a multi-line paragraph and makes it into a single line of text."
  (interactive (progn (barf-if-buffer-read-only) '(t)))
  (let ((fill-column (point-max))
        ;; This would override `fill-column' if it's an integer.
        (emacs-lisp-docstring-fill-column t))
    (fill-paragraph nil region)))

(setq! visual-line-fringe-indicators '(nil right-curly-arrow)
       ns-alternate-modifier 'super
       ns-right-alternate-modifier 'super
       ns-command-modifier 'meta
       read-buffer-completion-ignore-case t
       apropos-sort-by-scores t
       ;; backup-directory-alist '(("" . "~/.emacs.d/emacs_backup")) TODO shoudln't use .emacs.d/
       global-visual-line-mode t
       doom-scratch-initial-major-mode 'org-mode
       initial-major-mode 'org-mode)

(map! ("M-i"  #'counsel-imenu)
      ("M-s-q"  #'unfill-paragraph))

(map! :map org-mode-map
      "C-c g" #'org-mark-ring-goto)



(use-package! python
  :custom
  (python-indent-offset 2)
  (python-shell-interpreter "python3"))

(use-package! ace-window
  :init
  (map! "M-o" #'ace-window))

;; (use-package! avy
;;   :init
;;   (map!
;;    ("M-g g" #'avy-goto-line)
;;    ("C-'" #'avy-goto-char-timer)
;;    ("M-g w" #'avy-goto-word-1)
;;    ("M-g e" #'avy-goto-word-0)))

;; TODO latex
(use-package! latex
  :config
  (setq!
   TeX-electric-math (cons "\\(" "")
   )
  (setq-default TeX-master nil)

  )

(use-package! org
  :init
  (custom-set-faces!
    '(org-level-1 :inherit outline-1 :weight extra-bold :height 1.3)
    '(org-level-2 :inherit outline-2 :weight semi-bold :height 1.2)
    '(org-level-3 :inherit outline-3 :height 1.1)
    '(org-level-4 :inherit outline-5)
    '(org-level-5 :inherit outline-7)
    '(org-level-6 :inherit outline-8)
    '(org-level-7 :foreground "pink")
    '(org-level-8 :foreground "orange"))
    ;; org-link ((t (:inherit link :foreground "RoyalBlue1"))))
  (setq!
   org-agenda-files
   '("~/Documents/org/inbox.org"
     "~/Documents/org/projects.org"
     "~/Documents/org/tickler.org"
     "~/Documents/org/calendar.org")
   ;; (org-hide-emphasis-markers t)
   ;; org-log-done t
   ;; (org-refile-targets
   ;;  '(("~/Documents/org/projects.org" :maxlevel . 3)
   ;;    ("~/Documents/org/tickler.org" :maxlevel . 2)
   ;;    ("~/Documents/org/calendar.org" :level . 1)))
   ;; (org-todo-keywords
   ;;  '((sequence "TODO(t)" "WAITING(w)" "|" "DONE(d)" "CANCELLED(c)")))
   )
  ; allow call from outside
  (defun org-capture-to-inbox ()
    (interactive)
    (org-capture nil '"i"))

  (defun org-capture-to-inbox-from-outside()
    (interactive)
    (org-capture-to-inbox)
    (delete-other-windows))

  ;; :hook (org-mode . turn-on-auto-fill)
  :config
  (global-auto-revert-mode t)
  (setq org-capture-templates
        `(("i" "Inbox" entry (file "~/Documents/org/inbox.org")
           ,(concat "* TODO %?\n"
                    "/Entered on/ %u"))
          ("t" "Tickler" entry
           (file+headline "~/Documents/org/tickler.org" "tickler")
           "* %? \n %U")
          ("c" "Calendar" entry
           (file+headline "~/Documents/org/calendar.org" "calendar")
           "* %? \n %U")))
  (setq! org-file-apps '((auto-mode . emacs)
     (directory . emacs)
     ("\\.mm\\'" . default)
     ("\\.x?html?\\'" . default)
     ("\\.pdf\\'" . system)
     ("\\.xlsx\\'" . system)))
  )

(after! org
  (with-eval-after-load 'flycheck
    (flycheck-add-mode 'proselint 'org-mode)) ; TODO what does it mean?

  (map! :map org-mode-map
        "M-n" #'outline-next-visible-heading
        "M-p" #'outline-previous-visible-heading)

  (setq org-src-window-setup 'current-window
        org-return-follows-link t
        org-babel-load-languages '((emacs-lisp . t)
                                   (python . t)
                                   (dot . t)
                                   (R . t))
        org-confirm-babel-evaluate nil
        org-use-speed-commands t
        org-catch-invisible-edits 'show
        org-preview-latex-image-directory "/tmp/ltximg/"
        org-structure-template-alist '(("a" . "export ascii")
                                       ("c" . "center")
                                       ("C" . "comment")
                                       ("e" . "example")
                                       ("E" . "export")
                                       ("h" . "export html")
                                       ("l" . "export latex")
                                       ("q" . "quote")
                                       ("s" . "src")
                                       ("v" . "verse")
                                       ("el" . "src emacs-lisp")
                                       ("d" . "definition")
                                       ("t" . "theorem"))))

(setq org-todo-keywords
      '((sequence "TODO(t)" "NEXT(n)" "|" "DONE(d)")
        (sequence "WAITING(w@/!)" "HOLD(h@/!)" "|" "CANCELLED(c@/!)")))

(setq org-log-done 'time
      org-log-into-drawer t
      org-log-state-notes-insert-after-drawers nil)

(setq org-tag-alist '(("@errand" . ?e)
                      ("@office" . ?o)
                      ("@home" . ?h)
                      (:newline)
                      ("CANCELLED" . ?c)))

(use-package! org-journal
  :after org
  :init
  (setq! org-journal-dir "~/Documents/journal/"))

(use-package! org-download
  :after org
  :commands
  org-download-dnd
  org-download-yank
  org-download-screenshot
  org-download-dnd-base64
  :init
  (global-unset-key (kbd "s-y"))
  (map! :map org-mode-map
        (("C-M-y" #'org-download-screenshot)
         ("s-y" #'org-download-yank)))
  ;; :hook (dired-mode org-download-enable)
  :custom
  (org-download-screenshot-method "screencapture -i %s"))

(use-package! org-roam
  :init
  (map! :leader
        :prefix "n"
        :desc "org-roam" "l" #'org-roam-buffer-toggle
        :desc "org-roam-node-insert" "i" #'org-roam-node-insert
        :desc "org-roam-node-find" "f" #'org-roam-node-find
        :desc "org-roam-ref-find" "r" #'org-roam-ref-find
        :desc "org-roam-show-graph" "g" #'org-roam-show-graph
        :desc "org-roam-capture" "c" #'org-roam-capture
        :desc "org-roam-dailies-capture-today" "j" #'org-roam-dailies-capture-today)

  (setq org-roam-v2-ack t)
  (add-to-list 'display-buffer-alist
               '(("\\*org-roam\\*"
                  (display-buffer-in-direction)
                  (direction . right)
                  (window-width . 0.33)
                  (window-height . fit-window-to-buffer))))

  :config
  (setq org-roam-capture-templates
        '(("d" "default" plain
           "%?"
           :if-new (file+head "${slug}.org"
                              "#+title: ${title}\n")
           :immediate-finish t
           :unnarrowed t)))
  (setq org-roam-capture-ref-templates
        '(("r" "ref" plain
           "%?"
           :if-new (file+head "${slug}.org"
                              "#+title: ${title}\n")
           :unnarrowed t)))
  (setq org-roam-dailies-directory "daily/")
  (setq org-roam-dailies-capture-templates
        '(("d" "default" entry
           "* %?"
           :if-new (file+head "%<%Y-%m-%d>.org"
                              "#+title: %<%Y-%m-%d>\n"))))
  (set-company-backend! 'org-mode '(company-capf))
  )

(use-package! org-roam-protocol
  :after org-protocol)

;;TODO el-patch
;;
(use-package! deft
  :after org
  :custom
  (deft-recursive t)
  (deft-use-filter-string-for-filename t)
  (deft-default-extension "org")
  (deft-directory "~/Dropbox (MIT)/org-roam-notes/"))
;;   :config/el-patch
;;   (defun deft-parse-title (file contents)
;;     "Parse the given FILE and CONTENTS and determine the title.
;; If `deft-use-filename-as-title' is nil, the title is taken to
;; be the first non-empty line of the FILE.  Else the base name of the FILE is
;; used as title."
;;     (el-patch-swap (if deft-use-filename-as-title
;;                        (deft-base-filename file)
;;                      (let ((begin (string-match "^.+$" contents)))
;;                        (if begin
;;                            (funcall deft-parse-title-function
;;                                     (substring contents begin (match-end 0))))))
;;                    (org-roam-db--get-title file))

(use-package! mathpix
  :commands (mathpix-screenshot)
  :init
  (global-unset-key (kbd "C-x m"))
  (map! "C-x m"  #'mathpix-screenshot)
  :custom
  (mathpix-app-id 'shuyao_li_wisc_edu_05d10e_4c2d16)
  (mathpix-app-key '90f5dfb6b9534923f018)
  (mathpix-screenshot-method "screencapture -i %s"))

;; (use-package! org-noter-pdftools
;;   :after org-noter
;;   :config
;;   ;; Add a function to ensure precise note is inserted
;;   (defun org-noter-pdftools-insert-precise-note (&optional toggle-no-questions)
;;     (interactive "P")
;;     (org-noter--with-valid-session
;;      (let ((org-noter-insert-note-no-questions (if toggle-no-questions
;;                                                    (not org-noter-insert-note-no-questions)
;;                                                  org-noter-insert-note-no-questions))
;;            (org-pdftools-use-isearch-link t)
;;            (org-pdftools-use-freestyle-annot t))
;;        (org-noter-insert-note (org-noter--get-precise-info)))))

;;   ;; fix https://github.com/weirdNox/org-noter/pull/93/commits/f8349ae7575e599f375de1be6be2d0d5de4e6cbf
;;   (defun org-noter-set-start-location (&optional arg)
;;     "When opening a session with this document, go to the current location.
;; With a prefix ARG, remove start location."
;;     (interactive "P")
;;     (org-noter--with-valid-session
;;      (let ((inhibit-read-only t)
;;            (ast (org-noter--parse-root))
;;            (location (org-noter--doc-approx-location (when (called-interactively-p 'any) 'interactive))))
;;        (with-current-buffer (org-noter--session-notes-buffer session)
;;          (org-with-wide-buffer
;;           (goto-char (org-element-property :begin ast))
;;           (if arg
;;               (org-entry-delete nil org-noter-property-note-location)
;;             (org-entry-put nil org-noter-property-note-location
;;                            (org-noter--pretty-print-location location))))))))
;;   (with-eval-after-load 'pdf-annot
;;     (add-hook 'pdf-annot-activate-handler-functions #'org-noter-pdftools-jump-to-note)))

;; (after! evil
;;   (map! :map evil-insert-state-map
;;         ("C-t" #'transpose-chars)))
