(setq *READ 2 *WRITE 1)

(load '@lib/json.l)
(load "lib/util.l")
(load "lib/server.l")
(load "config.l")
(load "lib/relations.l")


(load (pack (confv '(client)) "/client.l"))

(de authn (Creds)
  (let (Cls (intern "+User" (intern (confv '(ns)))))
    (setq User (db 'eml Cls (car Creds))))
    (and User (= (pw_hash (cdr Creds) (get User 'salt)) (get User 'pw)) User)) #User needs to show up twice to prevent error and return User.


(de process (Verb Path Qs Post Creds)
  (default Path (confv '(default_path))) 
  (setq Cls (or (isa '+Rest (intern (to_cls_nm (++ Path)) (intern (confv '(ns))))) NIL))
  (setq Eid (any (car Path)))
  (ifn Cls
    (404)
    (if (need_auth> Cls Verb Path)
      (ifn (setq User (authn Creds))
        (401)
        (if (num? Eid)
          (let (Obj (db 'id Cls Eid))
            (ifn Obj
              (404)
              (ifn (authz> Obj Verb Path Qs Post User)
                (403)
                (send (any (pack "rest_" Verb ">")) Obj Path Qs Post User))))
          ( ifn (authz> Cls Verb Path Qs Post User)
            (403)
            (send (any (pack "rest_" Verb ">")) Cls Path Qs Post User))))
      (send (any (pack "rest_" Verb ">")) Cls Path Qs Post))))

(pool (confv '(pool)))

(class +REntity +Entity) 
  (var noauth '("new" "list" "post"))
  (var perms '((r w d)(r) (c)))

  (dm T @ (put> This 'eid (genKey 'eid '+REntity)))  #Every addressable entity has a unique ID.
  (rel eid (+Key +Number) NIL)

  (dm perms> (User)
    (setq Perms 
      (if (ext? This)
        (var: perms)
        (get (cls> This) 'perms))))

  (dm auth_req?> (Verb Path)

    (if (nil? ) 
      ()
      ())
    )

  (dm need_auth> (Verb Path) 
    (let (Noauth (car (or (get This 'noauth) (var: noauth)))) (not (or (member Verb Noauth) (member (car Path) Noauth) ))))
  (dm auth_get> (Path Qs Post User) T)
  (dm auth_post> (Path Qs Post User) (or (= "new" (car Path))(nil? Path)))
  (dm auth_del> (Path Qs Post User) (= (owner> This) User))

  (dm authz> (Verb Path Qs Post User) 
    (send (intern (pack "auth_" Verb ">")) This Path Qs Post User))
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
    (or (try (intern (pack "get_" (car Path) ">")) This Path Qs Post User) (404))) 

  (dm rest_post> (Path Qs Post User) 
    (if (= (car Path) "new")
      (prog 
        (setq E (new T (list This)))
        (try 'set_owner> E User))
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
      (filter '((R)(not (ext? (car R)))) (rels> (cls> This))  )))


