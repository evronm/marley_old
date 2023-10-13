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
    (and User (= (pw_hash Pw (get User 'salt)) (get User 'pw)) User)) #User needs to show up twice to prevent error and return User.


(de process (Verb Path Qs Post Creds)
  (default Path (confv '(default_path))) 
  (setq Cls (or (isa '+Rest (intern (to_cls_nm (++ Path)) (intern (confv '(ns))))) NIL))
  (ifn Cls
    (404)
    (if (need_auth> Cls Verb Path)
      (ifn (setq User (authn Creds))
        (401)
        (ifn (authz> Cls Verb Path Qs Post User)
          (403)
          (send (any (pack "rest_" Verb ">")) Cls Path Qs Post User)))
      (send (any (pack "rest_" Verb ">")) Cls Path Qs Post))))

(pool (confv '(pool)))

(class +REntity +Entity) 
  (var noauth '("new" "list" "post"))
  (var perms '(()))
  (dm T @ (put> This 'eid (genKey 'eid '+REntity))) # might want to move this to individual entities.
  (rel eid (+Key +Number) NIL)


  (dm need_auth> (Verb Path) 
    (let (Noauth (car (get This 'noauth))) (not (or (member Verb Noauth) (member (car Path) Noauth) ))))
  (dm authz> (User Verb Path) 
    T)
  (dm owner> () This)
  (dm url> (Path) (pack "/" (lowc (cdr (chop (sym This)))) "/" Path  ))
  (dm cls> () (car (type This)))

  (dm rels> (Cls) 
    (setq Rels (delete NIL (append (try 'rels> (cls> This)) (filter '((r) (type (car r))) (getl This)))))
    (if (> Cls Nil)
      (filter '((r) (= Cls (sect Cls (type (car r))))) Rels)
      Rels))

  (dm reggae> (New Srch)
    (reggae (list "instance" 
      (if New 
        (list 
          (url> This "new")
          (mapcar '((r) (list (sym (cdr r)) (reggae> (car r)))) (rels> This '(+Frm +New))))
        (T (list
          (url> This)
          (mapcar '((r) (list (sym (cdr r)) (reggae> (car r)))) (rels> This '(+Frm)))))))))
      

  (dm get_new> (Path Qs Post User) (list 200 (reggae> This T Nil)))
  (dm get_search> (Path Qs Post User) (new (append (str This) '(+Seach))))
  (dm get_list (Path Qs Post User) ())
  
  (dm rest_get> (Path Qs Post User) 
    (or (try (intern (pack "get_" (car Path) ">")) This) (404))) 

  (dm rest_post> (Path Qs Post User) 
    (if (= (car Path) "new")
      (prog 
        (setq E (new T (list This)))
        (try 'set_owner> This User))
      (setq E (db 'id This (car Path))))
    (for R Post (put> E (intern (car R)) (cdr R)))
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
      (rels> (cls> This))  ))


