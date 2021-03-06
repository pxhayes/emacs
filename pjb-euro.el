;;;; -*- mode:emacs-lisp;coding:utf-8 -*-
;;;;*****************************************************************************
;;;;FILE:               pjb-euro.el
;;;;LANGUAGE:           emacs lisp
;;;;SYSTEM:             emacs
;;;;USER-INTERFACE:     emacs
;;;;DESCRIPTION
;;;;
;;;;    This module exports
;;;;
;;;;AUTHORS
;;;;    <PJB> Pascal J. Bourguignon
;;;;MODIFICATIONS
;;;;    199?/??/?? <PJB> Creation.
;;;;BUGS
;;;;LEGAL
;;;;    LGPL
;;;;
;;;;    Copyright Pascal J. Bourguignon 1990 - 2011
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
;;;;*****************************************************************************
(require 'pjb-cl)
(require 'pjb-list)

(require 'pjb-utilities)
(require 'pjb-strings)
(require 'pjb-html)
(require 'pjb-emacs)


(defvar euro-parities '(
    ;; Cours fixes:
        (:EUR 1.00000  0.01 "%10.2f" "Euro")
    (:BEF 40.3399  1.00 "%10.0f" "Franc Belge")
        (:DEM 1.95583  0.01 "%10.2f" "Mark Allemand")
        (:ESP 166.386  1.00 "%10.0f" "Peseta Espagnole")
    (:FRF 6.55957  0.01 "%10.2f" "Franc Français")
        (:IEP 0.787564 0.01 "%10.2f" "Lire Irlandaise")
        (:ITL 1936.27  1.00 "%10.0f" "Lire Italienne")
        (:LUF 40.3399  1.00 "%10.0f" "Franc Luxembourgeois")
        (:NLG 2.20371  1.00 "%10.2f" "Florin Néerlandais")
        (:ATS 13.7604  0.01 "%10.2f" "Shilling Autrichien")
        (:PTE 200.428  1.00 "%10.0f" "Escudo Portuguais")
        (:FIM 5.94573  1.00 "%10.0f" "Mark Finlandais")
    ;; Cours variables:
    (:UKL 1.0 0.01 "%10.2f" "Livre Sterling")
    (:AUD 1.0 0.01 "%10.2f" "Dollar Australien")
    (:USD 1.0 0.01 "%10.2f" "Dollar Américain")
    (:CAD 1.0 0.01 "%10.2f" "Dollar Canadien")
    (:JPY 1.0 1.00 "%10.0f" "Yen Japonais")
    (:FRS 1.0 0.01 "%10.2f" "Franc Suisse")
    (:SEK 1.0 0.01 "%10.2f" "Couronne Suèdoise")
    (:DKK 1.0 0.01 "%10.2f" "Couronne Danoise")
    (:NOK 1.0 0.01 "%10.2f" "Couronne Norvégienne")
    )
"This is the list of the devises that are in the euro,
with their conversion ratios.
To update the devises with variable quotes, use update-devises.
")

;; Create the devise symbols.
(mapc (lambda (x)
        (let ((symbol (car x)))
          (set (intern (subseq (symbol-name symbol) 1)) symbol)))
      euro-parities)




(defun euro-parity-replace-ratio (parity new-ratio)
  "PRIVATE"
  (cons (car parity) (cons new-ratio (cddr parity))))


(defun euro-update-devise-body (cours devise parities)
  "PRIVATE"
  (cond ((null parities) parities)
        ((eq (caar parities) devise)
         (cons (euro-parity-replace-ratio (car parities) cours)
               (cdr parities)))
        (t
         (cons (car parities)
               (euro-update-devise-body cours devise (cdr parities))))))

(defun euro-update-devise (cours devise)
  "PRIVATE"
  (setq euro-parities (euro-update-devise-body cours devise euro-parities)))


(defvar *devise-url* "http://www.ecb.europa.eu/stats/eurofxref/eurofxref-daily.xml")

(defun update-devisess ()
  "DO:  Retrieves the devise quotes from the url at `*devise-url*'."
  (interactive)
  ;; (shell-command-to-string
  ;;  "update-devisess boursorama > ~/.emacs-devises~ && mv ~/.emacs-devises~  ~/.emacs-devises ")
  ;;  (load "~/.emacs-devises")

  ;; (with-file ("~/.emacs-devises" :save t :kill t)
  ;;   (erase-buffer)
  ;; )
  (loop
     for (nil entry)
     in (remove-if-not 'consp
                       (flet ((clean (xml) (cddr (find-if 'consp xml))))
                         (clean (clean
                                 (pjb-find-html-tag
                                  'Cube
                                  (pjb-parse-xml
                                   (url-retrieve-as-string *devise-url*)))))))
     for currency = (intern (format ":%s" (cdr (assoc 'currency entry))))
     for rate     = (car (read-from-string (cdr (assoc 'rate entry))))
     ;; do (insert (format "%S\n" (list 'euro-update-devise rate currency)))
     do (euro-update-devise rate currency)))


(defun euro-update-devisess ()
  "RETURN: The list of known devises."
  (mapcar 'car euro-parities))


(defun euro-get-parity (parities devise)
  "PRIVATE"
  (cond ((null parities) parities)
                ((equal (caar parities) devise) (car parities))
                (t (euro-get-parity (cdr parities) devise))))

(defun euro-is-devise (devise)
  "RETURN: Whether devise is a known devise."
  (euro-get-parity euro-parities devise))


(defun euro-get-ratio (devise)
  "RETURN: The ratio between devise and euro."
  (cadr (euro-get-parity euro-parities devise)))

(defun euro-get-round (devise)
  "RETURN: The smallest strictly positive value that can be expressed
        in the devise.
NOTE:   This value is used to round the values in the device."
  (caddr (euro-get-parity euro-parities devise)))

(defun euro-get-format (devise)
  "RETURN: The string  used to format values in the devise."
  (cadddr (euro-get-parity euro-parities devise)))

(defun euro-get-label (devise)
  "RETURN: The name of the devise."
  (cadddr (cdr (euro-get-parity euro-parities devise))))


(defun euro-value-to-string (value devise)
  "Return a string containing the value formated with the number of
decimals needed for the devise, followed by a space, then by the
three-letter devise code. The value is euro-round'ed before formating."
  (if (not (euro-is-devise devise))
      (error "DEVISE must be a devise. See (euro-update-devisess)."))
  (setq value (euro-round value devise))
  (chop-spaces (format (concat (euro-get-format devise) " %3s") value devise)))


(defun euro-round (value devise)
  "RETURN: The value rounded according to the devise rule."
  (let ((round (euro-get-round devise)))
    (if (< 0.0 value)
        (* round (truncate (/ (+ value (/ round 2.0)) round)))
      (* round (truncate (/ (- value (/ round 2.0)) round))))))


(defun euro-from-value (value devise)
  "RETURN: The value converted into euro from devise."
  (euro-round (/ value (euro-get-ratio devise)) :EUR))

(defun euro-to-value (devise value-euro)
  "RETURN: The value converted into devise, from euro."
  (euro-round (* value-euro (euro-get-ratio devise)) devise))


(defun euro-from-devise (value devise)
  "DO:     Inserts a line with the value expressed in devise and in euro."
  (interactive)
  (insert
   (format (concat "\n"
                   (euro-get-format devise) " %s = "
                   (euro-get-format :EUR) " %s")
           value devise
           (euro-round (/ value (euro-get-ratio devise)) :EUR) :EUR)))

(defun euro-to-devise (devise value-euro)
  "DO:     Inserts a line with the value expressed in euro and in devise."
  (interactive)
  (insert
   (format (concat "\n"
                   (euro-get-format :EUR) " %s = "
                   (euro-get-format devise) " %s")
           value-euro :EUR
           (euro-round (* value-euro (euro-get-ratio devise)) devise) devise)))


(defun euro-test ()
  "DO:      Inserts results of testing the pjb-euro module."
  (interactive)
  (insert
   (apply 'concat
    (mapcar (lambda (dev)
              (format "\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n"
                      (euro-to-devise dev 100)
                      (euro-from-devise (euro-to-value dev 100) dev)
                      (euro-from-devise 100 dev)
                      (euro-to-devise dev (euro-from-value 100 dev))
                      (euro-to-devise dev 33)
                      (euro-from-devise (euro-to-value dev 33) dev)
                      (euro-from-devise 33 dev)
                      (euro-to-devise dev (euro-from-value 33 dev))))
            (euro-update-devisess)))))



; (euro-get-parity euro-parities 'FRF)
; (euro-from-devise 4000 'FRF)
; (euro-to-devise 'ESP 380)
; (euro-test)




(defparameter gold-coins
  '(
    ("Kruger Rand" 31.1)
    ("1/2 Kruger Rand" 15.54)
    ("1/4 Kruger Rand" 7.77)
    ("1/10 Kruger Rand" 3.105)
    ("Lingot" 1000.00)
    ("Barre" 1000.00)
    ("Napoléon (Pièce Française 20 FRF)" 5.80)
    ("Pièce Suisse 20 Francs" 5.80)
    ("Pièce Union Latine 20 Francs" 5.80)
    ("Souverain" 7.32)
    ("Pièce 20 Dollars Américains" 30.09)
    ("Pièce 10 Dollars Américains" 15.04)
    ("Pièce 50 Pesos Mexicains" 37.50)
    ("Pièce 10 Florins" 6.05)
    ("Demi-Napoléon (Pièce Française 10 FRF)" 2.90)
    ("Pièce Tunisienne 20 Francs" 5.80)
    ("Souverain Elisabeth II" 7.32)
    ("Demi-Souverain" 3.66)
    ("Pièce 5 Dollars Américains" 7.52)
    ("Pièce 20 Marks" 7.17)
    )
  "A list of sublist (name gold-mass-in-gram) of gold coins and lingot."
);;gold-coins



(defun between (min max &optional step)
  (setq step (or step 1))
  (let ((s-value (gensym "value"))
        (s-max   (gensym "max"))
        (s-step  (gensym "step")))
    (set s-value min)
    (set s-max   max)
    (set s-step  step)
    `(lambda ()
       (if (<= ,s-value ,s-max)
         (values (prog1 ,s-value (incf ,s-value ,s-step)) t)
         (values nil nil)))
    ));;between


(defun append-enumerators (&rest enumerators)
  "
RETURN:        An enumerator that enumerates all the enumerators in turn.
"
  (lambda ()
    (block :meta-enum
      (loop
       (if (null enumerators)
         (return-from :meta-enum (values nil nil))
         (multiple-value-bind (val ind) (funcall (car enumerators))
           (if ind
             (return-from :meta-enum (values val ind))
             (pop enumerators)))))))
  );;append-enumerators



(defun collect-enumerator (enumerator)
  (do ((result '())
       (done nil))
      (done result)
    (multiple-value-bind (val ind) (funcall enumerator)
      (if ind
        (push val result)
        (setq done t))))
  );;collect-enumerator



(defun map-enumerator (lambda-expr enumerator)
  (do ((result '())
       (done nil))
      (done (nreverse result))
    (multiple-value-bind (val ind) (funcall enumerator)
      (if ind
        (push (funcall lambda-expr val) result)
        (setq done t))))
  );;map-enumerator



(defun make-gold-table ()
  (setq gold-coins
        (sort gold-coins
              (lambda (a b)
                (or (< (second a) (second b))
                    (and (= (second a) (second b))
                         (STRING> (first a) (first b)))))))
  (let ((umass-coins
         (set-difference
          (remove-duplicates gold-coins :key (lambda (a) (second a)))
          '(("Barre") ("Lingot"))
          :key (function first)
          :test (function string=)))
        (prices (between 9400 11000 50))
        (lines '())
        (line  '()))
    (map-enumerator
     (lambda (price)
       (setq line (list (format "%.0f" price)))
       (dolist (coin umass-coins)
         (push (format "%.2f" (/ (* (second coin) price) 1000.0)) line))
       (push (nreverse line) lines))
     prices)
    (setq lines (nreverse lines))
    (push (cons "Lingot" (mapcar (function first) umass-coins)) lines)
    lines)
  );;make-gold-table



(defun format-table (ll)
  (let* ((titles   (car ll))
         (lines    (cdr ll))
         (widths   (mapcar (lambda (line) (mapcar (function length) line)) lines))
         col-widths top-cols)
    (macrolet ((h-bars
                () `(do ((col-widths col-widths (cdr col-widths)))
                        ((null col-widths))
                      (insert (make-string* (car col-widths)
                                            :initial-element (character "-")))
                      (insert (if (null (cdr col-widths)) "\n" " ")))))
      ;; compute the column widths:
      (setq col-widths (copy-seq (car widths)))
      (dolist (lin-widths widths)
        (do ((col-widths col-widths (cdr col-widths))
             (lin-widths lin-widths (cdr lin-widths)))
            ((null col-widths))
          (setf (car col-widths) (max (car col-widths) (car lin-widths)))))
      ;; compute the top-lines columns:
      (setq top-cols
            (do ((col-widths col-widths (cdr col-widths))
                 (cur-col 0 (+ 1 cur-col (car col-widths)))
                 (top-cols '()))
                ((null col-widths) (nreverse top-cols))
              (push (+ (/ (car col-widths) 2) cur-col) top-cols)))
      ;; print the titles
      (do ((titles   (reverse titles)   (cdr titles))
           (top-cols (reverse top-cols) (cdr top-cols))
           (right    "" (format "%s|%s"
                                (if (endp (rest titles))
                                    0
                                    (make-string* (- (first top-cols)
                                                     (or (second top-cols) 0) 1)
                                                  :initial-element (character " ")))
                                right))
           name col)
          ((null titles))
        (setq name (car titles))
        (setq col (car top-cols))
        (insert
         (if (<= (length name) col)
           (format "%s%s+%s\n"
                   name
                   (make-string* (- col (length name))
                                :initial-element (character "-"))
                   right)
           (format "%s%s\n%sV%s\n"
                   name
                   (subseq right (- (length name) col 1))
                   (make-string* col  :initial-element (character " "))
                   right))))
      ;; print the lines
      (do ((lines lines (cdr lines))
           (i 0 (1+ i)))
          ((null lines))
        (when (zerop (mod i 5)) (h-bars))
        (do ((line     (car lines) (cdr line))
             (col-widths col-widths (cdr col-widths))
             )
            ((null line))
          (insert (format (format "%%%ds%s"
                                  (car col-widths)
                                  (if (null (cdr line)) "" " "))
                          (car line))))
        (insert "\n"))
      (h-bars))))




;; (format-table (make-gold-table))


(defun pjb-eurotunnel ()
  "
DO:      update-devisess and insert some eurotunnel data.
"
  (interactive)
  (let ((today (calendar-current-date)))
    (update-devisess)
    (mapcar
     (lambda (line)
       (let* ((fields   (split-string line ";"))
              (sym      (nth 0 fields))
              (quo      (string-to-number
                         (replace-regexp-in-string "," "." (nth 1 fields) nil nil))))
         (cond

           ((string-match "22457" sym)
            (printf
             "  | %4d-%02d-%02d    %8.6f   %4d %10s = %7.2f %11s |\n"
             (nth 2 today) (nth 0 today) (nth 1 today)
             quo 4400 sym (* quo 4400) " "))

           ((string-match "12537" sym)
            (printf
             "  | %4d-%02d-%02d    %8.6f        %10s    %18s |\n"
             (nth 2 today) (nth 0 today) (nth 1 today)
             quo  sym  " "))

           ((string-equal sym "GBP=X")
            (printf
             "  | %4d-%02d-%02d    %8.6f          %3s      ~ %7.4f %11s |\n"
             (nth 2 today) (nth 0 today) (nth 1 today)
             (/ (euro-from-value 10000 UKL) 10000.0) 'UKL
             (/ (+ (euro-from-value (* 1495 0.68) UKL) (* 1495 1.0214)) 1495)
             "EUR/12537"))

           (t))))

     (split-string
      (url-retrieve-as-string
       "http://fr.finance.yahoo.com/d/quos.csv?s=22456+22457+12537+GBP=X&m=PA&f=sl1d1t1c1ohgv&e=.csv")))))


;; (update-devises)
(provide 'pjb-euro)
;;;; THE END ;;;;
