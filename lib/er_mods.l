#add permissions option
(extend +relation)
  (dm perms> (User) ((role_pos> (get This 'cls) User) (mapcar 'chop ( : perms))))
  (dm set_perms> (P)  ( =: perms P) )
  (dm req> () (isa '+Need This))
  (dm ro> (User Act) (not (may Act User (get This 'cls) (get This 'var))))
  (dm spec> () 
    (if (setq typ (lowc (pack (cdr (chop (car (sect '(+Number +Date +Time +Bool +Password) (type This) )))))))
      typ
      "text")) #This is kind of ugly but is unlikely to need changing
  (dm restrict> (User Act)
    (setq Restr NIL)
    (when (isa '+Need This ) (push 'Restr 'req))
    (when (ro> This User Act) (push 'Restr 'ro))
    Restr)

(redef rel Lst
  (eval (cons 'rel (head -1 Lst) )) 
  (put *Class 'rels (append (get *Class 'rels) (list (car Lst))))
  (set_perms> (get *Class (car Lst)) (last Lst)))

(extend +List)
  (dm list> (Parent) (get Parent (get This 'var)))
  (dm spec> (User Act) "instances")

(class +Password +String)
  (dm put> (Obj Old Pw)
    (when (nil? (get Obj 'salt))
      (put> Obj 'salt (sym (in "/dev/urandom" (rd 10)))))
    (super Obj Old (sym (pw_hash Pw (get Obj 'salt))))
  )

(class +Email +String) (dm type> () "email")

