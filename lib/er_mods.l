
#add permissions option
(extend +relation)
  (dm perms> (User) ((role_pos> (get This 'cls) User) (mapcar 'chop ( : perms))))
  (dm set_perms> (P)  ( =: perms P) )
  (dm req> () (isa '+Need This))
  (dm ro> (User Act) (not (may Act User (get This 'cls) (get This 'var))))
  (dm type> () 
    (if (setq typ (lowc (pack (cdr (chop (car (sect '(+Number +Date +Time +Bool +Password) (type This) )))))))
      typ
      "text")) #This is kind of ugly but is unlikely to need changing
  (dm restrict> (User Act)
    (setq Restr Nil)
    (when (isa '+Need This ) (push 'Restr 'req))
    (when (ro> This User Act) (push 'Restr 'ro))
    Restr)

(redef rel Lst
  (eval (cons 'rel (head -1 Lst) )) #can't use apply here; apparently due to redef; should look into it.
  (put *Class 'rels (append (get *Class 'rels) (list (car Lst))))
  (set_perms> (get *Class (car Lst)) (last Lst)))

(extend +List)
  (dm type> () "instances")
  (dm list> (Parent) (get Parent (get This 'var)))
  (dm spec> () (spec> (car (get This 'type))))

(class +Password +String)
  (dm put> (Obj Old Pw)
    (when (nil? (get Obj 'salt))
      (put> Obj 'salt (sym (in "/dev/urandom" (rd 10)))))
    (super Obj Old (sym (pw_hash Pw (get Obj 'salt))))
  )

(class +Email +String) (dm type> () "email")

(class +REntity +Entity) 
  (var perms (~(confv '(default_cls_perms)))) #kind of ugly; requires some thought to grok; bear in mind `var` is an f-expression  (crud r c) as of now...

  (dm T @ (put> This 'eid (genKey 'eid '+REntity)))  #Every addressable entity has a unique ID.
  (rel eid (+Key +Number) NIL)

  (dm role_pos> (User)
    (cond 
    ((= User (owner> This)) 'car)
    ((group_mem> This User) 'cadr)
    (T 'last )))

  (dm perms> (User)
    (setq Perms (car (or (get This 'perms) (var: perms))))
    (chop ((role_pos> This User) Perms)))

  #(dm need_auth> (Verb Path) (not (member (req_action Verb Path) (perms> This NIL))))
  (dm need_auth> (Verb Path) (not (may (req_action Verb Path) NIL This)))

  (dm owner> () This)
  (dm group_mem> (User) NIL)
  (dm cls> () (if (ext? This) (car (type This)) (name This)))
  (dm url> () (lowc (pack "/" (cdr (chop (cls> This))) "/" (when (ext? This) (get This 'eid)))  ))

  (dm rels> (User Act) 
    (delete NIL (append (try 'rels> (car (type This)) User Act ) (filter '((R) ( may Act User This R)) (get This 'rels)) )))

  (dm link> () (list "url" (url> This) (get This 'nm) (get This 'desc)))
  (dm spec> (User Act)
    (setq Rels 
      (if (ext? This)
        (rels> This User Act)
        (filter '((R)(not (isa '+Link (meta (list This) R)))) (rels> This User Act))))
    (list
      (url> This)
      (mapcar '((R) 
        (setq Rel (meta (list This) R))
        (list R (type> Rel) (restrict> Rel) )) Rels)))

  (dm vals> (User Act) (mapcar '((R)(meta (list E) R)) (rels> This User Act)))

  (dm list> (Path QS Post User) 
    (ifn QS
        (lsearch NIL (list (list 'eid This)))
        ()))

  (dm list_vals> (Path QS Post User) (mapcar '((E) (vals> E User 'r)) (list> This Path QS Post User)))
      
  (dm get_new> (Path QS Post User) (list 200 (list "instance" (spec> This User 'c))))
  (dm get_search> (Path QS Post User) (new (append (str This) '(+Seach))))
  (dm get_list> (Path QS Post User) 
    (list 200 (list "instances" (spec> This User 'r) (list_vals> This Path QS Post User))))
  
  (dm rest_get> (Path QS Post User) 
    (default Path '("list"))
    (or (try (intern (pack "get_" (car Path) ">")) This Path QS Post User) (404))) 

  (dm rest_post> (Path QS Post User) 
    (if (or (= (car Path) "new") (nil? (car Path)))
      (prog 
        (setq E (new T (list This)))
        (try 'set_owner> E User))
      (setq E (db 'id This (car Path))))
    (for R (rels> This User (req_action Verb Path))
      (setq V (cdr (assoc R Post)))
      (cond
        ((isa '+Link (meta E R)))  #This may have to change; not how I will handle links
        ((setq Err (mis> E R V)) (push 'Errs (list R Err )))
        ((not (may (req_action Verb Path) User This R) (push 'Errs R "Forbidden")))
        (T (put> E R (if (num? (any V)) (any V) V)))))
    (if Errs
      (prog 
        (rollback)
        (prog1 (list 422 (cons '(error) Errs)) (setq Errs NIL)) ) 
      (commit T)
      (list 201 '("mesg" "Success" "created successfully"))))
  
  (dm rest_put> (Path QS Post User) prinl 'put)
  (dm rest_delete> (Path QS Post User) prinl 'del)

