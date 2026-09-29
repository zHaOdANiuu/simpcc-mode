;;; simpc++-mode.el --- Simple C++ mode -*- lexical-binding: t; -*-

;; Copyright (C) 2026 zhaodaniu

;; Author: zhaodaniu <zhaodaniu1@gmail.com>
;; Homepage: https://github.com/zHaOdANiuu/simpcpp-mode
;; Version: 1.0.0
;; Package-Requires: ((emacs "28.1"))
;; Keywords: simpc++-mode, simple, fast

;; This file is not part of GNU Emacs.

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.
;;
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <https://www.gnu.org/licenses/>.

;;; Commentary:

;; Simplae C++ mode.
;;
;; Enable with:
;;
;;   (use-package simpc++-mode
;;      :mode "\\.\\(c\\|h\\|cpp\\|hpp\\|cppm\\|ixx\\)\\'")
;;
;; Customize with `M-x customize-group RET simpc++-mode RET'.

;;; Code:

(defgroup simpc++-mode nil
  "Simplae C++ mode group."
  :prefix "simpc++-mode")

(defcustom simpc++-indent-width 2
  "Simpc++ indent width."
  :type 'number
  :group 'simpc++-mode)

(defcustom simpc++-mode-syntax-table
  (let ((table (make-syntax-table)))
    (modify-syntax-entry ?/ ". 124b" table)
    (modify-syntax-entry ?* ". 23" table)
    (modify-syntax-entry ?\n "> b" table)
    (modify-syntax-entry ?# "." table)
    (modify-syntax-entry ?' "\"" table)
    (modify-syntax-entry ?< "." table)
    (modify-syntax-entry ?> "." table)
    (modify-syntax-entry ?& "." table)
    (modify-syntax-entry ?% "." table)
    (modify-syntax-entry ?+ "." table)
    (modify-syntax-entry ?- "." table)
    (modify-syntax-entry ?= "." table)
    table)
  "Simplae c++ syntax table."
  :group 'simpc++-mode)

(defcustom simpc++-types
  '("char" "int" "long" "short" "void" "bool" "float" "double" "signed" "unsigned"
    "va_list")
  "Simple C++ base type list."
  :group 'simpc++-mode)

(defcustom simpc++-keywords
  '("module" "export" "import"
    "class" "struct" "union" "enum" "typedef" "using"
    "decltype" "sizeof" "alignas" "alignof" "typeid"
    "auto" "const" "constexpr" "consteval" "constinit" "volatile"
    "extern" "static" "thread_local" "register"
    "operator" "inline" "explicit" "virtual" "override" "noexcept"
    "public" "protected" "private" "final" "friend" "mutable"
    "new" "delete" "this"
    "template" "typename" "requires" "concept"
    "static_cast" "dynamic_cast" "const_cast" "reinterpret_cast"
    "if" "else" "switch" "case" "default"
    "while" "do" "for" "break" "continue"
    "goto" "return"
    "try" "catch" "throw"
    "co_await" "co_return" "co_yield"
    "and" "and_eq" "or" "or_eq" "not" "not_eq" "xor" "xor_eq"
    "bitand" "bitor" "compl"
    "namespace" "asm" "static_assert" "reflexpr" "synchronized" "atomic_cancel"
    "atomic_commit" "atomic_noexcept")
  "Simple C++ keywords."
  :group 'simpc++-mode)

(defcustom simpc++-font-lock-keywords
  `(;; initilation
    ("^[ \t]*#[ \t]*\\(warn\\|error\\)" 0 font-lock-warning-face)
    ("^[ \t]*#[ \t]*\\(?:[a-zA-Z0-9_]+\\)" 0 font-lock-preprocessor-face)
    ("^[ \t]*#[ \t]*include\\(?:_next\\)?\\s-+\\(\\(<\\|\"\\).*\\(>\\|\"\\)\\)" 1 font-lock-string-face)
    ("\\_<\\(defined\\)\\_>" 1 font-lock-preprocessor-face)
    ("\\(?:@\\|\\\\\\)\\(?:param\\|tparam\\|brief\\|return\\|returns\\|retval\\|note\\|warning\\|see\\|sa\\|author\\|date\\|todo\\|throw\\|throws\\|exception\\|deprecated\\|since\\|file\\|class\\|struct\\|fn\\|var\\|def\\|namespace\\|enum\\|property\\|ingroup\\|addtogroup\\)\\_>"
     0 font-lock-keyword-face)
    (,(regexp-opt simpc++-keywords 'symbols) 0 font-lock-keyword-face)
    (,(regexp-opt simpc++-types 'symbols) 0 font-lock-type-face)
    ("\\_<\\([A-Za-z_][A-Za-z0-9_]*_t\\)\\_>" 1 font-lock-type-face)

    ;; define
    ("\\<\\(?:enum\\|using\\|struct\\|class\\)[ \t]\\([a-zA-Z0-9_]+\\)"
     1 font-lock-type-face)
    ("\\<typedef\\b[ \t][a-zA-Z_][a-zA-Z0-9_]*[ \t]\\([a-zA-Z_][a-zA-Z0-9_]*\\)[ \t];"
     1 font-lock-type-face)
    ("\\<typedef\\b[^}]*}[ \t]\\([a-zA-Z_][a-zA-Z0-9_]*\\)"
     1 font-lock-type-face)

    ;; std::xxx
    ("\\_<\\([a-zA-Z_][a-zA-Z0-9_]*\\)::" 1 font-lock-constant-face)

    ;; vector<T> / Map<K,V>
    ("\\_<\\([A-Za-z_][A-Za-z0-9_]*\\)<"
     (1 font-lock-type-face)
     ("\\(?:,[A-Za-z_][A-Za-z0-9_]*\\)?\\([A-Za-z_][A-Za-z0-9_]*\\)\\s-*\\(?:,\\|>\\|<\\|$\\)"
      nil nil (1 font-lock-type-face)))

    ;; int a / int& b / type_t c
    ("^[ \t]+\\([A-Za-z_][A-Za-z0-9_:]*\\(?:[ \t]*<[^;{}()]*>\\)?\\)[ \t*&]+[*&]*[ \t]*\\([A-Za-z_][A-Za-z0-9_]*\\)[ \t]*[*&]*[ \t]*\\(?:[;=,{\\[]\\)"
     (1 font-lock-type-face))

    ;; 0 / 123
    ("\\_<\\(?:0[xX][0-9a-fA-F']+\\|0[bB][01']+\\|0[0-7']+\\|[0-9][0-9']*\\(?:\\.[0-9']*\\)?\\(?:[eE][+-]?[0-9']+\\)?[uUlLfFzZ]*\\)\\_>"
     0 font-lock-constant-face)

    ;; function return type: type func()
    ("^[ \t]*\\([A-Za-z_][A-Za-z0-9_:]*\\(?:[ \t]*<[^;{}()]*>\\)?\\)[ \t*&]*" (1 font-lock-type-face))

    ;; function name: funcname ()
    ("\\_<\\([a-zA-Z_][a-zA-Z0-9_]*\\)[ \t]*(" 1 'font-lock-function-name-face)

    ;; C++ end return type:：) -> Type {
    (")[ \t]*->[ \t]*\\([A-Za-z_][A-Za-z0-9_:<>]*\\)" 1 font-lock-type-face)

    ;; [[nodiscard]] [[deprecated]]
    ("\\[\\[[ \t]*\\([A-Za-z_][A-Za-z0-9_]*\\)" 1 font-lock-builtin-face)

    ;; __attribute__ / __declspec
    ("\\_<\\(__attribute__\\|__declspec\\)\\_>" 1 font-lock-builtin-face))
  "Simplea C++ face lock list."
  :group 'simpc++-mode)

(defun simpc++--proper-indentation (parse-status)
  "Simple C++ format function.
Argument PARSE-STATUS is current syntax context."
  (let ((depth (nth 0 parse-status))             ; Depth in parens
        (paren-start (nth 1 parse-status))       ; Position of the paren that started this list
        ;; (paren-prev (nth 2 parse-status))     ; Position of the previous sibling paren
        ;; (in-string (nth 3 parse-status))      ; Non-nil if inside a string
        (in-comment (nth 4 parse-status))        ; Non-nil if inside a comment
        ;; (string-start (nth 5 parse-status))   ; Start position of string or comment
        ;; (string-end (nth 6 parse-status))     ; End position of string or comment
        ;; (string-type (nth 7 parse-status))    ; Type of string or comment
        ;; (string-content (nth 8 parse-status)) ; Content of string or comment
        ;; (in-block (nth 9 parse-status))       ; Non-nil if inside a code block
        (cur-line (string-trim-right (thing-at-point 'line t))))
    ;; Print all information for debugging
    ;; (message "=== Parse Status ===")
    ;; (message "Depth: %S" depth)
    ;; (message "Paren start: %S" paren-start)
    ;; (message "Paren prev: %S" paren-prev)
    ;; (message "In string: %S" in-string)
    ;; (message "In comment: %S" in-comment)
    ;; (message "String start: %S" string-start)
    ;; (message "String end: %S" string-end)
    ;; (message "String type: %S" string-type)
    ;; (message "String content: %S" string-content)
    ;; (message "In block: %S" in-block)
    (save-excursion
      (back-to-indentation)
      (cond
       (in-comment (current-indentation))

       ((save-excursion
          (forward-line -1)
          (back-to-indentation)
          (looking-at "\\_<\\(if\\|while\\|for\\|else\\|do\\|try\\|catch\\)\\_>"))
        (save-excursion
          (forward-line -1)
          (back-to-indentation)
          (+ (current-indentation) simpc++-indent-width)))

       (paren-start
        (let* ((close-p (looking-at "[]})]"))
               (label-p (string-suffix-p ":" cur-line)))
          (goto-char paren-start)
          (back-to-indentation)
          (+ (current-column)
             (* simpc++-indent-width
                (cond
                 (close-p 0)
                 ((looking-at "\\_<switch\\_>") (if label-p 1 2))
                 (label-p 0)
                 (t 1))))))

       (t (prog-first-column))))))

(defun simpc++-indent-line ()
  "Simple C++ indent function."
  (let* ((parse-status
          (save-excursion (syntax-ppss (line-beginning-position))))
         (offset (- (point) (save-excursion (back-to-indentation) (point)))))
    (unless (nth 3 parse-status)
      (indent-line-to (simpc++--proper-indentation parse-status))
      (when (> offset 0) (forward-char offset)))))

(define-derived-mode simpc++-mode prog-mode "Simple C++"
  "Simple major mode for editing C++ files."
  :syntax-table simpc++-mode-syntax-table
  (setq-local font-lock-defaults '(simpc++-font-lock-keywords))
  (setq-local indent-line-function #'simpc++-indent-line)
  (setq-local comment-start "// ")
  (setq-local indent-tabs-mode nil)
  (setq-local tab-width simpc++-indent-width))

(provide 'simpc++-mode)
;;; simpc++-mode.el ends here
