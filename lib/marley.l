(setq *NEWREC 1 *SEARCH 2 *READ 2 *WRITE 1)

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

(de authz (User Obj Verb) 
 T
)

(de process (Verb Path Qs Post Creds)
  (default Path (confv '(default_path))) 
  (setq Obj (or (isa '+Rest (intern (to_cls_nm (car Path)) Ns)) NIL))
  (ifn Obj
    (respond 404)
    (if (and (need_auth> Obj) (nil? Creds))
      (respond 401)
      (setq User (eval (append '(authn) Creds)))
      (ifn (authz User Obj Verb)
        (respond 403)
        (send (any (pack Verb ">")) Obj Path Qs Post User)))))

(pool (confv '(pool)))

(class +Rest) 
  (var noauth '(new list post))
  (dm need_auth> (Verb Path) (not (or (member Verb (var: noauth)) (member (car Path) (var: noauth)) )))
  (dm owner_rel> () 'uid)
  (dm owner_at_creation> () (or (: owner_at_creation) current_user))
  (dm perms> () '311)
  (dm url> () (pack "/" (lowc (cdr (chop This)))))
  (dm cls> () (car (type This)))

  (dm rels> (Cls) 
    (setq Rels (delete NIL (append (try 'rels> (cls> This)) (filter '((r) (<> (cdr r) '*Dbg)) (getl This)))))
    (if (> Cls Nil)
      (filter '((r) (= Cls (sect Cls (type (car r))))) Rels)
      Rels))

  (dm reggae> (new?  search?)
    (reggae (list "instance" 
      (cond 
        (new? (list 
          *NEWREC
          (url> This)
          (mapcar '((r) (list (sym (cdr r)) (reggae> (car r)))) (rels> This '(+Frm +New)))))
        (T (list
          0
          (url> This)
          (mapcar '((r) (list (sym (cdr r)) (reggae> (car r)))) (rels> This '(+Frm)))))))))
      

  (dm get> (Path Qs Post User) 
    (respond 200
      (case (cadr Path)
        ("new" (reggae> This T))
        ((NIL "list") )
        ("search" (reggae> This NIL T)) 
      )))

  (dm post> (Path Qs Post User) 
    (setq E (new T (str This)))
    (for R Post (put> E (intern (car R)) (cdr R)))
    (if (setq Errs (errs> E))
      (prog 
        (rollback)
        (respond 422 (reggae (cons '(error) Errs))) )
      (commit T)
      (respond 201 (reggae '("mesg" "Success" "Your account has been created successfully")))))
  
  (dm delete> (Path Qs Post User) prinl 'del)

  (dm errs> () 
    (extract 
      '((R) 
        (let (Err (mis> (car R) (get This (cdr R)) This)) 
          (when Err 
            (list (cdr R) Err)))) 
      (rels> (cls> This))  ))


(when *Dbg

)
