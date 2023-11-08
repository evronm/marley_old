
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

  (dm need_auth> (Verb Path) (not (may (req_action Verb Path) NIL This)))

  (dm owner> () This)
  (dm group_mem> (User) NIL)
  (dm cls> () (if (ext? This) (car (type This)) (name This)))
  (dm url> () (lowc (pack "/" (cdr (chop (cls> This))) "/" (when (ext? This) (get This 'eid)))  ))

  (dm rel> (R) (meta (list This) R))
  (dm rels> (User Act) 
    (! filter '((R) (may Act User This R)) (uniq (delete NIL (append (try 'rels> (car (type This)) User Act ) (get This 'rels)) ))))

  (dm link> () (list "url" (url> This) (get This 'nm) (get This 'desc)))
  (dm spec> (User Act Obj)
    (setq Rels 
      (if (n== Act 'c)
        (rels> This User Act)
        (filter '((R)(not (isa '+Link (rel> This R)))) (rels> This User Act))))
    (list
      (url> This)
      #(flags> This User Act Obj)
      (mapcar '((R) 
        (setq Rel (rel> This R))
        (list R (spec> Rel User Act) (restrict> Rel User (if (= 'c Act) 'c 'u)) )) Rels)))

  (dm flags> (User Act Obj) 
    (off Flags)
    (when (= 'c Act) (push Flags "new"))
    (when (or (and (= 'c Act) (not (may 'c User Obj))) (and (= 'u Act) (not (may 'u User Obj))) )  (push Flags "ro"))
    (when (may 'd User Obj) (push Flags "del"))
    Flags)

  (dm list> (Path QS Post User) 
    (ifn QS
        (lsearch NIL (list (list 'eid This)))
        (apply lsearch (qs2srch This QS))))
  (dm val> (R) 
    (let (V (get This R))
      (if (atom V)
        V
        (mapcar '((E)(link> E)) V))))
  (dm vals> (User Act) (mapcar '((R)(val> This R)) (rels> This User Act)))
  (dm list_vals> (Path QS Post User) (mapcar '((E) (vals> E User 'r)) (list> This Path QS Post User)))
      
  (dm get_new> (Path QS Post User) (list 200 (list "instance" (spec> This User 'c))))
  (dm get_search> (Path QS Post User) (new (append (str This) '(+Seach))))
  (dm get_list> (Path QS Post User) 
    (list 200 (list "instances" (spec> This User 'r) (list_vals> This Path QS Post User))))
  
  (dm rest_get> (Path QS Post User) 
    (if (ext? This)
      (list 200 (list "instance" (spec> (cls> This) User 'r This) (vals> This User 'r)))
      (default Path '("list"))
      (or (try (intern (pack "get_" (car Path) ">")) This Path QS Post User) (404))) )

  (dm rest_post> (Path QS Post User) 
    (if (= "del" (caar Post))
      (rest_del> This (cadar Post) User)
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
          ((not (may (req_action Verb Path) User This R) (push 'Errs (list R "Forbidden"))))
          (T (put> E R (if (num? (any V)) (any V) V)))))
      (if Errs
        (prog 
          (rollback)
          (prog1 (list 422 (cons '(error) Errs)) (setq Errs NIL)) ) 
        (commit)
        (list 201 '("mesg" "Success" "created successfully")))))
   (dm rest_del> (Eids User) 
     (for ID Eids
       (let (E (db 'eid '+REntity ID))
         (if (may 'd User E)
           (lose> E)
           (push 'Errs (list R "Forbidden")))))
    (if Errs
        (prog 
          (rollback)
          (prog1 (list 403 (cons '(error) Errs)) (setq Errs NIL)) ) 
        (commit)
        (list 204 '("mesg" "Success" "deleted successfully"))) ) 

