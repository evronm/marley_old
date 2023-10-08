(setq *READ 2 *WRITE 1)

(load '@lib/json.l)
(load "lib/util.l")
(load "lib/server.l")
(load "config.l")
(load "lib/relations.l")

(de conf (Lst)
  (if (= 1 (length Lst))
    (assoc (car Lst) *CONFIG)
    (assoc (car Lst) (conf (cdr Lst)))))

(de confv (Lst)
  (cdr (conf Lst)))

(load (pack (confv '(client)) "/client.l"))

(de reggae (Lst)
  (cond 
    ((num? Lst) Lst)
    ((or (sym? Lst) (str? Lst)) (pack "\"" Lst "\""))
    (T (pack "[" (glue ", " (mapcar '((Foo)( reggae Foo)) Lst)) "]"))))

(de authn (Eml Pw)
  (let (Cls (intern '+User (intern (confv '(ns)))))
    (setq User (db 'eml Cls Eml)))
    (and User (= (pw_hash Pw (get User 'salt)) (get User 'pw))))


(de process (Verb Path Qs Post Creds)
  (default Path (confv '(default_path))) 
  (setq Cls (or (isa '+Rest (intern (to_cls_nm (++ Path)) (intern (confv '(ns))))) NIL))
  (ifn Cls
    (404)
    (setq Obj (get> Cls Path Qs Post Creds))
    (ifn (need_auth> Obj)
      (if (setq R (try 'html> Obj))
        (list 200 R "html")
        (list 200 (reggae> Obj)))
      (ifn (authz> Obj)
        (403)
        (if (= "get" Verb)
          (if (setq R (try 'html> Obj))
            (list 200 R "html")
            (list 200 (reggae> Obj)))
          (send (any (pack "rest_" Verb ">")) Obj Path Qs Post User))))))

(pool (confv '(pool)))

(class +Rest) 
  (dm T @ (put This 'eid (genKey 'eid This)))
  (var noauth '(new list post))
  (var perms '(()))

  (rel eid (+Idx +Need +Number) NIL)

  (dm need_auth> (Verb Path) (not (or (member Verb (var: noauth)) (member (car Path) (var: noauth)) )))
  (dm authz> (User Verb Path) 
    T)
  (dm owner> () This)
  (dm url> () (pack "/" (lowc (cdr (chop (cls> This)))) "/" (if (isa '+New This)) "new" (get 'eid This) ))
  (dm cls> () (car (type This)))

  (dm rels> (Cls) 
    (setq Rels (delete NIL (append (try 'rels> (cls> This)) (filter '((r) (type (car r))) (getl This)))))
    (if (> Cls Nil)
      (filter '((r) (= Cls (sect Cls (type (car r))))) Rels)
      Rels))

  (dm reggae> ()
    (reggae (list "instance" 
      (cond 
        ((isa '+New This) (list 
          (url> This)
          (mapcar '((r) (list (sym (cdr r)) (reggae> (car r)))) (rels> This '(+Frm +New)))))
        (T (list
          (url> This)
          (mapcar '((r) (list (sym (cdr r)) (reggae> (car r)))) (rels> This '(+Frm)))))))))
      

  (dm get_new> (Path Qs Post User) (new (append (str This) '(+New))))
  (dm get_search> (Path Qs Post User) (new (append (str This) '(+Seach))))
  (dm get_list (Path Qs Post User) ())
  
  (dm get> (Path Qs Post User) 
    (try (intern (pack "get_" (car Path) ">")) This))

  (dm rest_post> (Path Qs Post User) 
    (setq E (new T (list (cls> This))))
    (for R Post (put> E (intern (car R)) (cdr R)))
    (if (setq Errs (errs> E))
      (prog 
        (rollback)
        (list 422 (reggae (cons '(error) Errs))) )
      (commit T)
      (list 201 (reggae '("mesg" "Success" "Your account has been created successfully")))))
  
  (dm rest_put> (Path Qs Post User) prinl 'put)
  (dm rest_delete> (Path Qs Post User) prinl 'del)

  (dm errs> () 
    (extract 
      '((R) 
        (let (Err (mis> (car R) (get This (cdr R)) This)) 
          (when Err 
            (list (cdr R) Err)))) 
      (rels> (cls> This))  ))


(when *Dbg

)
