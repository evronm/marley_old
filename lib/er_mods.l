

#add permissions option
(extend +relation)
  (dm perms> (p)
    (if p (=: perms p) (: perms)))

(redef rel Lst
  (eval (cons 'rel (head -1 Lst) ))
  (perms> (get *Class (car Lst)) (car (tail 1 Lst))))

#reggae for vaious prefix classes
(extend +String) (dm reggae> () "text")
(extend +Number) (dm reggae> () "number")
(extend +Date) (dm reggae> () "date")
(extend +Time) (dm reggae> () "time")
(extend +Bool) (dm reggae> () "bool")
(extend +List)
  (dm reggae> () "instances")
(class +Password +String)
  (dm reggae> () "password")
  (dm put> (Obj Old Pw)
    (when (nil? (get Obj 'salt))
      (put> Obj 'salt (sym (in "/dev/urandom" (rd 10)))))
    (super Obj Old (sym (pw_hash Pw (get Obj 'salt))))
  )
(class +Email +String) (dm reggae> () "email")

(class +REntity +Entity) 
  (var perms (~(confv '(default_cls_perms)))) #kind of ugly; requires some thought to grok; bear in mind `var` is an f-expression

  (dm T @ (put> This 'eid (genKey 'eid '+REntity)))  #Every addressable entity has a unique ID.
  (rel eid (+Key +Number) NIL)

  (dm role_pos> (User)
    (cond 
    ((= User (owner> This)) 'car)
    ((group_mem> This User) 'cadr)
    (T 'last )))

  (dm perms> (User)
    (setq Perms (car (or (get This 'perms) (var: perms))))
    ((role_pos> This User) Perms))

  (dm need_auth> (Verb Path) (not (member (req_action Verb Path) (perms> This NIL))))

  (dm authz> (Verb Path Qs Post User) (member (req_action Verb Path) (perms> This User)))

  (dm owner> () This)
  (dm group_mem> (User) NIL)
  (dm url> (Path) (pack "/" (lowc (cdr (chop (sym This)))) "/" Path  ))
  (dm cls> () (car (type This)))

  (dm rels> (User) 
    (setq role_pos (role_pos> This User))
    (delete NIL (append (try 'rels> (cls> This)) (filter '((r)
      (and 
        ( type (car r))
        (member 'r (role_pos (perms> (car r)))))) 
      (getl This)))))

  (dm reggae> (User)
    (setq Rels 
      (if (ext? This)
        (rels> This User)
        (filter '((R)(not (isa '+Link (car R)))) (rels> This User))))
    (reggae (list "instance" 
        (list
          (url> This)
          (mapcar '((r) (list (sym (cdr r)) (reggae> (car r)))) Rels)))))
      

  (dm get_new> (Path Qs Post User) (list 200 (reggae> This T Nil)))
  (dm get_search> (Path Qs Post User) (new (append (str This) '(+Seach))))
  (dm get_list (Path Qs Post User) 
    ())
  
  (dm rest_get> (Path Qs Post User) 
    (or (try (intern (pack "get_" (car Path) ">")) This Path Qs Post User) (404))) 

  (dm rest_post> (Path Qs Post User) 
    (if (or (= (car Path) "new") (nil? (car Path)))
      (prog 
        (setq E (new T (list This)))
        (try 'set_owner> E User))
      (setq E (db 'id This (car Path))))
    (for R Post (put> E (intern (car R)) (if (num? (any (cdr R))) (any (cdr R)) (cdr R))))
    (if (setq Errs (errs> E))
      (prog 
        (rollback)
        (list 422 (reggae (cons '(error) Errs))) )
      (commit T)
      (list 201 (reggae '("mesg" "Success" "created successfully")))))
  
  (dm rest_put> (Path Qs Post User) prinl 'put)
  (dm rest_delete> (Path Qs Post User) prinl 'del)

  (dm errs> () 
    (extract 
      '((R) 
        (let (Err (mis> (car R) (get This (cdr R)) This)) 
          (when Err 
            (list (cdr R) Err)))) 
      (filter '((R)(not (ext? (car R)))) (rels> (cls> This))  )))

