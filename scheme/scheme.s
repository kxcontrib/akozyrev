; define mutable/unmutable list functions
(define (mcons x y) (lambda :pair 0))
(define (:madr x y)
  (if (mpair? x)
      (:resolve-ctx (:get-ctx x) y)
      (error "mcar/mcdr: bad arg")))
(define (mcar x) (:madr x 'x))
(define (mcdr x) (:madr x 'y))
(define (mpair? x) (= (:type x) 201))
(define (pair? x) (or (mpair? x) (:pair? x)))
(define (cons x y)
  (if (or (mpair? x) (not (list? y)))
      (mcons x y)
      (:cons x y)))
(define (car x) (if (mpair? x) (mcar x) (:car x)))
(define (cdr x) (if (mpair? x) (mcdr x) (:cdr x)))
(define (mlist . a)
  (cond ((null? a) ()) ((pair? a) (mcons (car a) (apply mlist (cdr a)))) (else a)))
(define (list . a)
  (cond ((null? a) ()) ((mpair? (car a)) (mlist a)) (else (cons (car a) (apply list (cdr a))))))
(define (unmut a) (cond ((null? a) ()) ((mpair? a) (:cons (car a) (unmut (cdr a)))) (else a)))
(define (unmutr l)
    (if (mpair? l) (map unmutr (unmut l)) l))
(define (length a) (cond ((null? a) 0) ((mpair? a) (+ 1 (length (cdr a)))) ((pair? a) (:length a)) (else "length: bad arg")))
(define (foldr f a . s)
   (if (null? s)
       (cond ((null? a) ()) ((null? (cdr a)) (car a)) (else (f (car a) (foldr f (cdr a)))))
       (cond ((null? a) (car s)) (else (f (car a) (foldr f (cdr a) (car s)))))))
(define (foldl f a s)
   (cond ((null? a) s) (else (foldl f (cdr a) (f (car a) s)))))
(define (append . a)
  (define (append2 x y) (if (pair? x) (foldr cons x y) (error "append: invalid arg")))
  (if (null? a) () (if (pair? (car a)) (foldr append2 a) (error "append:bad arg"))))
(define (reverse a) (foldl cons a ()))
(define (make-mut a) (apply mlist a))
(define (set-car! a b) (if (mpair? a) (set! x (:get-ctx a) b) (error "set-car!: bad arg")))
(define (set-cdr! a b) (if (mpair? a) (set! y (:get-ctx a) b) (error "set-cdr!: bad arg")))

; define helper functions
(define (negative? a) (< a 0))
(define (positive? a) (> a 0))
(define (even? a) (= (remainder a 2) 0))
(define (odd? a) (not (even? a)))
(define (average x y) (/ (+ x y) 2))
(define (square x) (* x x))
(define (gcd a b)
  (if (= b 0)
     a
     (gcd b (remainder a b))))
(define (fib n)
  (cond ((= n 0) 0)
        ((= n 1) 1)
        (else (+ (fib (- n 1))
                 (fib (- n 2))))))
(define nil '())
(define (caar a) (car (car a)))
(define (cadr a) (car (cdr a)))
(define (cdar a) (cdr (car a)))
(define (cddr a) (cdr (cdr a)))
(define (caddr a) (car (cdr (cdr a))))
(define (list? a) (or (null? a) (pair? a)))
(define (map proc items)
  (if (null? items)
      nil
      (cons (proc (car items))
            (map proc (cdr items)))))
(define false #f)
(define true #t)
(define (memq item x)
  (cond ((null? x) false)
        ((eq? item (car x)) x)
        (else (memq item (cdr x)))))
(define eqv? eq?)
(define memv memq)
(define (member item x)
  (cond ((null? x) false)
        ((equal? item (car x)) x)
        (else (member item (cdr x)))))
(define (symbol? a) (= (:type a) -11))
(define (number? a) (pair? (memq (:type a) '(-6 -9))))
(define (for-each f lst)
  (if (null? lst) nil (begin (f (car lst)) (for-each f (cdr lst)))))
(define call-with-current-continuation call/cc)
