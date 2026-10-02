;;; simpcc-mode.el --- Simple C++ mode -*- lexical-binding: t; -*-

;; Copyright (C) 2026 zhaodaniu

;; Author: zhaodaniu <zhaodaniu1@gmail.com>
;; Homepage: https://github.com/zHaOdANiuu/simpcc-mode
;; Version: 1.0.0
;; Package-Requires: ((emacs "28.1"))
;; Keywords: simpcc-mode, simple, fast

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
;;   (require 'simpcc-mode)
;;   (simpcc-mode)
;;
;; Customize with `M-x customize-group RET simpcc-mode RET'.

;;; Code:

(defgroup simpcc-mode nil
  "Simplae CC mode group."
  :prefix "simpcc-mode")

(defcustom simpcc-indent-width 2
  "simpcc indent width."
  :type 'number
  :group 'simpcc-mode)

(defcustom simpcc-mode-syntax-table
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
  "Simplae CC syntax table."
  :group 'simpcc-mode)

(defcustom simpcc-types
  '("FILE"
    "char" "int" "long" "short" "void" "bool" "float" "double" "signed" "unsigned"
    "char8_t" "char16_t" "char32_t"
    "int8_t"  "int16_t"  "int32_t"  "int64_t"
    "uint8_t" "uint16_t" "uint32_t" "uint64_t"
    "float16_t" "float32_t" "float64_t" "float128_t" "bfloat16_t"
    "size_t"
    "intptr_t" "uintptr_t" "ptrdiff_t"
    "va_list")
  "Simple CC base type list."
  :group 'simpcc-mode)

(defcustom simpcc-keywords
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
  "Simple CC keywords."
  :group 'simpcc-mode)

(defcustom simpcc-constant
  '("true" "false" "nullptr" "NULL"

    ;; GNU
    "__GNUC__" "__FUNCTION__" "__PRETTY_FUNCTION__" "__func__"

    ;; std
    "__LINE__" "__FILE__" "__DATE__" "__TIME__"
    "__STDC__" "__STDC_VERSION__" "__STDC_HOSTED__"

    ;; c99
    "__STDC_ISO_10646__"
    "__STDC_IEC_559_COMPLEX__"
    "__STDC_MB_MIGHT_NEQ_WC__"
    "__VA_ARGS__"

    "LLONG_MIN" "LLONG_MAX" "ULLONG_MAX"
    "INT8_MIN" "INT16_MIN" "INT32_MIN" "INT64_MIN"
    "INT8_MAX" "INT16_MAX" "INT32_MAX" "INT64_MAX"
    "UINT8_MAX" "UINT16_MAX" "UINT32_MAX" "UINT64_MAX"
    "INTPTR_MIN" "INTPTR_MAX" "UINTPTR_MAX"
    "INTMAX_MIN" "INTMAX_MAX" "UINTMAX_MAX"
    "PTRDIFF_MIN" "PTRDIFF_MAX"
    "SIG_ATOMIC_MIN" "SIG_ATOMIC_MAX"
    "SIZE_MAX"
    "WCHAR_MIN" "WCHAR_MAX"
    "WINT_MIN" "WINT_MAX")
  "Simple CC constant."
  :group 'simpcc-mode)

(defcustom simpcc-font-lock-keywords
  `(;; initilation
    ("^[ \t]*#[ \t]*\\(?:[a-zA-Z0-9_]+\\)" . font-lock-preprocessor-face)
    ("^[ \t]*#[ \t]*\\(warn\\|error\\)" . font-lock-warning-face)
    ("^[ \t]*#[ \t]*include\\(?:_next\\)?\\s-+\\(\\(<\\|\"\\).*\\(>\\|\"\\)\\)" 1 font-lock-string-face)
    ("\\_<defined\\_>" . font-lock-preprocessor-face)
    (,(regexp-opt simpcc-keywords 'symbols) . font-lock-keyword-face)
    (,(regexp-opt simpcc-types 'symbols) . font-lock-type-face)
    (,(regexp-opt simpcc-constant 'symbols) . font-lock-constant-face)
    ;; 0 / 123
    ("\\_<\\(?:0[xX][0-9a-fA-F']+\\|0[bB][01']+\\|0[0-7']+\\|[0-9][0-9']*\\(?:\\.[0-9']*\\)?\\(?:[eE][+-]?[0-9']+\\)?[uUlLfFzZ]*\\)\\_>"
     . font-lock-constant-face)
    ;; [[nodiscard]] [[deprecated]]
    ("\\[\\[[ \t]*\\([A-Za-z_][A-Za-z0-9_]*\\)" (1 font-lock-builtin-face))
    ;; __attribute__ / __declspec
    ("\\_<\\(__attribute__\\|__declspec\\)\\_>" . font-lock-builtin-face)
    ;; c++ 26
    ("\\(\\^\\^\\|\\[:\\)" . font-lock-builtin-face)
    (":\\]" . font-lock-builtin-face))
  "Simplea CC face lock list."
  :group 'simpcc-mode)

(defun simpcc--proper-indentation (parse-status)
  "Simple CC format function.
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
          (+ (current-indentation) simpcc-indent-width)))

       (paren-start
        (let* ((close-p (looking-at "[]})]"))
               (label-p (string-suffix-p ":" cur-line)))
          (goto-char paren-start)
          (back-to-indentation)
          (+ (current-column)
             (* simpcc-indent-width
                (cond
                 (close-p 0)
                 ((looking-at "\\_<switch\\_>") (if label-p 1 2))
                 (label-p 0)
                 (t 1))))))

       (t (prog-first-column))))))

(defun simpcc-indent-line ()
  "Simple CC indent function."
  (let* ((parse-status
          (save-excursion (syntax-ppss (line-beginning-position))))
         (offset (- (point) (save-excursion (back-to-indentation) (point)))))
    (unless (nth 3 parse-status)
      (indent-line-to (simpcc--proper-indentation parse-status))
      (when (> offset 0) (forward-char offset)))))

(define-derived-mode simpcc-mode prog-mode "Simple CC"
  "Simple major mode for editing CC files."
  :syntax-table simpcc-mode-syntax-table
  (setq-local font-lock-defaults '(simpcc-font-lock-keywords))
  (setq-local indent-line-function #'simpcc-indent-line)
  (setq-local comment-start "// ")
  (setq-local indent-tabs-mode nil)
  (setq-local tab-width simpcc-indent-width))

(provide 'simpcc-mode)
;;; simpcc-mode.el ends here
