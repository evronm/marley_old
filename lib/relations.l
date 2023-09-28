

#add permissions option
(extend +relation)
  (dm perms> (p)
    (if p (=: perms p) (: perms)))
  (dm err> (Val Obj)  (mis> This Val Obj))

(redef rel Lst
  (if (and (num? (cdar (tail 1 Lst))) (not (num? (tail 1 Lst))))
    (prog (eval (cons 'rel (head -1 Lst) ))
      (perms> (get *Class (car Lst)) (car (tail 1 Lst))))
    (eval (cons 'rel Lst))))

(extend +String)
  (dm reggae> () "text")
(extend +Number)
  (dm reggae> () "number")
(extend +Date) 
  (dm reggae> () "date")
(extend +Time)
  (dm reggae> () "time")
(extend +Bool)
  (dm reggae> () "bool")
(extend +List)
  (dm reggae> () "instances")
(class +Password +String)
  (dm reggae> () "password")
(class +Email +String) 
  (dm reggae> () "email")

