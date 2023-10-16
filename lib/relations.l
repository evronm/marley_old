

#add permissions option
(extend +relation)
  (dm perms> (p)
    (if p (=: perms p) (: perms)))

(redef rel Lst
  (eval (cons 'rel (head -1 Lst) ))
  (perms> (get *Class (car Lst)) (car (tail 1 Lst))))

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
  (dm put> (Obj Old Pw)
    (when (nil? (get Obj 'salt))
      (put> Obj 'salt (sym (in "/dev/urandom" (rd 10)))))
    (super Obj Old (sym (pw_hash Pw (get Obj 'salt))))
  )
(class +Email +String) 
  (dm reggae> () "email")

