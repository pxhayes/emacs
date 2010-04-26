;;;;******************************************************************************
;;;;FILE:               pjb-strings.el
;;;;LANGUAGE:           emacs lisp
;;;;SYSTEM:             emacs
;;;;USER-INTERFACE:     emacs
;;;;DESCRIPTION
;;;;
;;;;    This module exports string utility functions.
;;;;
;;;;AUTHORS
;;;;    <PJB> Pascal J. Bourguignon 
;;;;MODIFICATIONS
;;;;    2003-01-20 <PJB> Removed string-replace for regexp-replace-in-string.
;;;;    2002-03-23 <PJB> Corrected string-replace: replace go on from the end
;;;;                     of the replace string.
;;;;    199?-??-?? <PJB> Creation.
;;;;BUGS
;;;;LEGAL
;;;;    LGPL
;;;;
;;;;    Copyright Pascal J. Bourguignon 1990 - 2003
;;;;
;;;;    This library is free software; you can redistribute it and/or
;;;;    modify it under the terms of the GNU Lesser General Public
;;;;    License as published by the Free Software Foundation; either
;;;;    version 2 of the License, or (at your option) any later version.
;;;;
;;;;    This library is distributed in the hope that it will be useful,
;;;;    but WITHOUT ANY WARRANTY; without even the implied warranty of
;;;;    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
;;;;    Lesser General Public License for more details.
;;;;
;;;;    You should have received a copy of the GNU Lesser General Public
;;;;    License along with this library; if not, write to the Free Software
;;;;    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307  USA
;;;;
;;;;******************************************************************************
(require 'pjb-cl)
(require 'pjb-list)
(provide 'pjb-strings)

(defun list-to-string (char-list)
  "
RETURN: A new string containing the characters in char-list.
"
  (let ((result (make-string (length char-list) 0))
        (i 0))
    (dolist (char char-list)
      (aset result i char)
      (setq i (1+ i)))
    result))


(defun cut-string (string length)
  "
RETURN: A list of substrings of length LENGTH (but the last that may be shorter)
"
  (do ((i 0 (+ i length))
       (result nil)
       )
      ((>= i (length string)) (nreverse result))
    (push (subseq string i (+ i length)) result)))



(defun is-digit (x)
  (cond
    ((stringp x) (is-digit (string-to-char x)))
    ((integerp x) (and (<= ?0 x) (<= x ?9)))
    (t nil)))


(defun is-letter (x)
  (cond
    ((stringp x) (is-letter (string-to-char x)))
    ((integerp x) (not (equal (downcase x) (upcase x))))
    (t nil)))




(defun basename (path)
  "RETURN: The last name in the file PATH."
  (file-namestring path))


(defun dirname (path)
  "RETURN: All but the last name in the file PATH."
  (directory-namestring path))


;;; (dolist 
;;;     (p '( 
;;;          "/" "/to" "/to/" "/to/ti" "/to/ti/" "/to/ti/ta"
;;;          "." "./" "./to" "./to/" "./to/ti" "./to/ti/" "./to/ti/ta"
;;;          "aa" "aa/" "aa/to" "aa/to/" "aa/to/ti" "aa/to/ti/" "aa/to/ti/ta"
;;;          "aa/../../to/ti"))



(defun string-index (string char &optional frompos)
  "RETURN: the position in STRING of the first occurence of CHAR searching  
        FROMPOS, or from the start if FROMPOS is absent or nil. 
        If CHAR is not found, then return nil.
SEE-ALSO: string-position."
  (string-match 
   (regexp-quote 
    (cond
      ((or (characterp char) (numberp char)) (format "%c" char))
      ((stringp char) char)
      (t 
       (error "string-index expects a char, number of string as 2nd argument."))
      )) string frompos))


;;  (let ((index (cond ((null frompos) 0)
;;                      (t (error (format 
;;                         "Wrong type of argument: integerp, 3 (got: %S)"
;;                         frompos)))))
;;        (target (cond ((characterp char) char)
;;                      ((stringp char) (string-to-char char))
;;                         "Wrong type of argument: CHARACTERP, 2 (got: %S)" char))))))
;;      (setq index (+ 1 index)))
;;        index
;;      nil)))

(defun string-position (string substr &optional frompos)
  "Return the position in STRING of the first occurence of the SUBSTR
searching FROMPOS, or from the start if FROMPOS is absent or nil. 
If the SUBSTR is not found, then return nil.

SEE-ALSO: string-index"
  (string-match (regexp-quote substr) string frompos))

;;  (let* (
;;         (index 
;;          (cond ((null frompos) 0)
;;                (t (error (format 
;;                           "Wrong type of argument: integerp, 3 (got: %S)"
;;                           frompos)))))
;;         (maxindex  (- (length string) sublen))
;;         )
;;                (not (string-equal (substring string index endpos) substr)))
;;            endpos (+ 1 endpos)))
;;        index
;;      nil)))

(defun unsplit-string (string-list &rest separator)
  "Does the inverse than split-string. If no separator is provided 
then a simple space is used."
  (if (null separator)
      (setq separator " ")
      (if (= 1 (length separator))
          (setq separator (car separator))
          (error "unsplit-string: Too many separator arguments.")))
  (if (not (char-or-string-p separator))
      (error "unsplit-string: separator must be a string or a char."))
  (apply 'concat (list-insert-separator string-list separator)))

(defun join (string-list separator) (unsplit-string string-list separator))

(defun string-repeat (num string)
  "Return a string built from the concatenation of num times string."
  (cond ((<= num 0) "")
        ((= 0 (% num 2)) (let ((sub (string-repeat (/ num 2) string))) 
                           (concat sub sub)))
        (t (let ((sub (string-repeat (/ (- num 1) 2) string))) 
             (concat sub sub string)))))


(defun string-replace (&rest arg)
  "Please use `replace-regexp-in-string' instead of string-replace."
  (error "Please use replace-regexp-in-string instead of string-replace."))

;;; (defun string-replace (string regexp replace &optional fixedcase literal)
;;;         are replaced by the `replace' string."
;;;   (let ( (start 0)
;;;          (replace-length (length replace))
;;;     (while (< start max)
;;;           (progn
;;;             (setq string (replace-match replace fixedcase literal  string))
;;;             (setq max    (length string)))
;;;   string
;;;   )


(defun string-justify-left (string &optional width left-margin)
  "RETURN: a left-justified string built from string. 
NOTE:   The default width is 72 characters, the default left-margin is 0. 
        The width is counted from column 0.
        The word separators are those of split-string: [ \\f\\t\\n\\r\\v]+, which
        means that the string is justified as one paragraph."
  (if (null width) (setq width 72))
  (if (null left-margin) (setq left-margin 0))
  (if (not (stringp string)) 
      (error "string-justify-left: The first argument must be a string."))
  (if (not (and (integerp width) (integerp left-margin)))
      (error "string-justify-left: The optional arguments must be integers."))
  (let* (
         (margin (make-string left-margin 32))
         (splited (split-string string))
         (col left-margin)
         (justified (substring margin 0 col))
         (word)
         (word-length 0)
         (separator "")
         )
    (while splited
      (setq word (car splited))
      (setq splited (cdr splited))
      (setq word-length (length word))
      (if (> word-length 0)
          (if (>= (+ col (length word)) width)
              (progn
                (setq justified (concat justified "\n" margin word))
                (setq col (+ left-margin word-length)))
              (progn
                (setq justified (concat justified separator word))
                (setq col (+ col 1 word-length)))))
      (setq separator " "))
    (if (< col width)
        (setq justified (concat justified (make-string (- width col) 32))))
    justified))


(defun string-from-file-literally (filename &optional beg end)
  "RETURN: a string with the contents of the file FILENAME.
        If the optional BEG and END numbers are present, only this range from
        the file is read."
  (with-temp-buffer
    (insert-file-contents-literally filename nil beg end)
    (buffer-string)))



(defun string-has-prefix (string prefix)
  (cond
    ((or
      (not (stringp string))
      (not (stringp prefix)))
     (error "The parameters STRING and PREFIX must be strings."))
    ((< (length string) (length prefix)) nil)
    (t (string-equal (substring string 0 (length prefix)) prefix))))


(defun string-has-suffix (string suffix)
  (cond
    ((or
      (not (stringp string))
      (not (stringp suffix)))
     (error "The parameters STRING and SUFFIX must be strings."))
    ((< (length string) (length suffix)) nil)
    (t (string-equal (substring string (- (length string) (length suffix)))
                     suffix))))



;;; (defmacro cl-parsing-keywords (kwords other-keys &rest body)
;;;    'let*
;;;    (cons (mapcar
;;; 	  (function
;;; 	   (lambda (x)
;;; 		    (mem (list 'car (list 'cdr (list 'memq (list 'quote var)
;;; 	       (if (eq var ':test-not)
;;; 	       (if (eq var ':if-not)
;;; 	       (list (intern
;;; 		      (format "cl-%s" (substring (symbol-name var) 1)))
;;; 	  kwords)
;;; 	  (and (not (eq other-keys t))
;;; 		(list 'let '((cl-keys-temp cl-keys))
;;; 			    (list 'or (list 'memq '(car cl-keys-temp)
;;; 						  (mapcar
;;; 						   (function
;;; 						    (lambda (x)
;;; 							  (car x) x)))
;;; 							   other-keys))))
;;; 						   cl-keys)))
;;; 					  (car cl-keys-temp)))
;;; 	  body))))
;;; (put 'cl-parsing-keywords 'edebug-form-spec '(sexp sexp &rest form))

(defun copy-to-substring (src from-src to-src dst from-dst)
  "
PRE:     (< (+ from-dst (- to-src from-src)) (length dst))
DO:      Copy characters of string src between `from-src' and `to-src' to 
         the string dst between `from-dst' and `from-dst'+`to-src'-`from-src'.
RETURN:  dst
"
  (loop for i from from-src to to-src
     for j = from-dst then (1+ j)
     do (setf (char dst j) (char src i))
     finally return dst))



(defun string-pad (string length &rest cl-keys)
  "Append spaces before, after or at both end of string to pad it to length.
RETURN: A padded string.
"
  (let ((slen (length string)))
    (if (<= length slen)
        string
        (cl-parsing-keywords ((:padchar 32))  t
          (when (stringp cl-padchar) 
            (setq cl-padchar (string-to-char cl-padchar)))
          (let ((result (make-string* length :initial-element cl-padchar)))
            (cond
              ((memq :right cl-keys)
               (copy-to-substring string 0 (1- slen) 
                                  result (- length slen)))
              ((memq :center cl-keys)
               (copy-to-substring string 0 (1- slen) 
                                  result (/ (- length slen) 2)))
              (t 
               (copy-to-substring string 0 (1- slen) result 0))))))))




(defun chop-spaces-old (string)
  "RETURNS: a substring of STRING with the prefix and postfix spaces removed."
  (let ((i 0)
        (l (1- (length string)))
        (space 32))
    (while (and (< 0 l) (eq (aref string l) space))
      (setq l (1- l)))
    (setq l (1+ l))
    (while (and (< i l) (eq (aref string i) space))
      (setq i (1+ i)))
    (substring string i l)))



(defun chop (string &rest cl-keys) 
  "
RETURN: A substring of string from which the characters in the set  of
        :characters (only space by default) are removed from left and
        right (or only from left when :only-left is specified, or only
        from right when :only-right is specified.  
NOTE:   The argument passed with :characters can be a list of characters
        or a string.
"
  (if string
      (cl-parsing-keywords ((:characters (list (character " ")))) t
        (let ((cl-right (not (member :only-left  cl-keys)))
              (cl-left  (not (member :only-right cl-keys))))
          (when (stringp cl-characters)
            (setq cl-characters (string-to-list cl-characters)))
          (let ((from 0)
                (to   (1- (length string))))
            (when cl-right
              (loop while (and (<= 0 to)
                               (member (aref string to) cl-characters))
                 do (setq to (1- to))))
            (when cl-left
              (loop while (and (<= from to)
                               (member (aref string from) cl-characters))
                 do (setq from (1+ from))))
            (if (<= from to)
                (subseq string from (1+ to)) "")
            )))
      nil))


(defun chop-spaces-nl (string)
  "RETURNS: a substring of STRING with the prefix and postfix spaces removed."
  (save-match-data
    (let ((chopped " \t\n"))
      (if (string-match 
           (format "^[%s]*\\([^%s].*[^%s]\\|[^%s]\\)[%s]*$" 
             chopped chopped chopped chopped chopped) string)
          (match-string 1 string)
          string))))


(defun chop-spaces (string)
  "RETURNS: a substring of STRING with the prefix and postfix spaces removed."
  (save-match-data
    (if (string-match "^ *\\([^ ].*[^ ]\\|[^ ]\\) *$" string)
        (match-string 1 string)
        string)))


;;; (unless t
;;;   (mapcar (lambda (s)
;;;             (error "Regression failed on %S : %S != %S."
;;;                    s (chop-spaces s) (chop-spaces-2 s))))
;;;            "Hello World !    "
;;;            "    Hello World !"
;;;            "Hello World !"
;;;            " xy "
;;;            "  xy"
;;;            "xy  "
;;;            "xy"
;;;            " Z "
;;;            "  Z"
;;;            "Z  "
;;;            "Z"))



(defun chop-prefix (string prefix &rest options)
  "
RETURN: If prefix is a prefix of string then the substring following it
        else nil.
OPTIONS can contain :ignore-case in which case the case string and prefix 
        are matched case insensitively.
"
  (if (or (null string) (null prefix))
      nil
      (let ((mstring string))
        (if (member :ignore-case options) 
            (setq mstring (upcase string)
                  prefix  (upcase prefix)))
      
        (if (and (<= (length prefix) (length mstring))
                 (string-equal prefix (substring mstring 0 (length prefix))))
            (substring string (length prefix))
            nil))))

(defalias 'string-prefix-p 'chop-prefix)



(defvar iso-latin-1-approximation nil 
  "An array mapping ISO-8859-1 characters to ASCII-characters")


(defun make-iso-latin-1-approximation ()
  (setq iso-latin-1-approximation (make-vector 256 0))
  (loop for i from 0 to 127 
     do (aset iso-latin-1-approximation i i))
  (loop for i from 128 below 160 
     for c from 0 below 32 
     do (aset iso-latin-1-approximation i c))
  (loop for i from 160 to 255
     for c across (concat " !cL$Y|S\"Ca<--R\"o~23'uP.,1o>***?"
                          "AAAAAAECEEEEIIIITNOOOOOxOUUUUYPs"
                          "aaaaaaeceeeeiiiitnooooo/ouuuuypy")
     do (aset iso-latin-1-approximation i c))       
  iso-latin-1-approximation)



(defun string-remove-accents (string)
  "
RETURN: modified string
DO:     replace in string all accented characters with an unaccented version.
        This is done only for ISO-5581-1 characters.
"
  (unless iso-latin-1-approximation 
    (make-iso-latin-1-approximation))
  (let ((result (make-string (length string) 0)))
    (loop for p from 0 below (length string)
       do 
       (aset result p (aref iso-latin-1-approximation 
                            (% (aref string p) 256))))
    result))


(defmacro deftranslation (table string language translated-string)
  `(progn
     (unless (and (boundp (quote ,table)) ,table)
       (setq ,table (make-vector 7 0)))
     (put (intern ,string ,table)
          ,language 
          (if (eq ,translated-string :idem) ,string ,translated-string))))


(defun localize (table language string)
  "
RETURN: A version of the string in the given language.
"
  (let ((sym (intern-soft string table)))
    (if sym 
        (let ((result (get sym language))) 
          (if result 
              result
              (localize table :en string)))
        string)))



;; This is for Emacs.
;; Local Variables:
;; eval: (put 'deftranslation 'lisp-indent-function 2)
;; eval: (put 'cl-parsing-keywords 'lisp-indent-function 2)
;; End:

;;;; pjb-strings.el                   --                     --          ;;;;
