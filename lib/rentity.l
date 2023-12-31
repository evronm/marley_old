
#This is a wrapper class for +Entity which adds a bunch of REST methods.
(class +REntity +Entity) 
  (var perms (~(confv '(default_cls_perms)))) #kind of ugly; requires some thought to grok; bear in mind `var` is an f-expression  (crud r c) as of now...

  (dm T @ (put> This 'eid (genKey 'eid '+REntity)))  #Every addressable entity has a unique ID.
  (rel eid (+Key +Number) NIL)

  #override this to use more than the default permission slots (owner, group, logged in, and anon)
  (dm role_pos> (User) #usually users and anons get the same perms; and caddr and last happen to be the same.  Need to watch out for this and may want to change it.
    (cond 
      ((= User (owner> This)) 'car)
      ((group_mem> This User) 'cadr)
      ((bool User) 'caddr)
      (T 'last )))

  (dm perms> (User)
    (setq Perms (car (or (get This 'perms) (var: perms))))
    (chop ((role_pos> This User) Perms)))

  (dm need_auth> (Verb Path) (not (may (req_action Verb Path) NIL This)))

  (dm owner> () This)
  (dm group_mem> (User) NIL) #no priveleged groups by default
  (dm cls> () (if (ext? This) (car (type This)) (name This)))
  (dm cls_nm> () (lowc (pack (cdr (chop (cls> This)))) ))
  (dm url> () (pack "/" (cls_nm> This) "/" (when (ext? This) (get This 'eid))))
  (dm link> () (list "url" (url> This) (get This 'nm) (get This 'desc)))

  (dm rel> (R) (meta (list This) R))
  (dm rels> (User Act) 
    (filter '((R) (may Act User This R) )
      (uniq (delete NIL (append (try 'rels> (car (type This)) User Act ) ((if (ext? This) meta get) This 'rels)) ))))

  (dm spec> (User Act)
    (setq Rels 
      (if (n== Act 'c)
        (rels> This User Act)
        (filter '((R)(not (isa '+Link (rel> This R)))) (rels> This User Act))))
    (list
      (cls_nm> This)
      (if (ext? This) (get This 'eid) "new")
      (flags> This User Act)
      (mapcar '((R) 
        (setq Rel (rel> (if (ext? This) (cls> This) This) R))
        (list R (spec> Rel User Act) (restrict> Rel User (if (= 'c Act) 'c 'u) This) )) Rels)))

  (dm flags> (User Act) 
    (off Flags)
    (when (= 'c Act) (push 'Flags "new"))
    (unless (or (and (= 'c Act) (may 'c User This)) (and (= 'u Act) (may 'u User This)) )  (push 'Flags "ro"))
    (when (may 'd User This) (push 'Flags "del"))
    Flags)

  (dm list> (Path QS Post User) 
    (ifn QS
        (lsearch NIL (list (list 'nm This)))
        (apply lsearch (qs2srch This QS))))

  (dm val> (R) 
    (let (V (get This R))
      (if (atom V)
        (if (ext? V ) (link> V) V)
        (mapcar '((E)(link> E)) V))))

  (dm vals> (User Act) 
    (if (== 'c Act)
      (mapcar '((R)(val> This R)) (rels> This User Act))
      (cons (get This 'eid) (mapcar '((R)(val> This R)) (rels> This User Act)))))

  (dm list_vals> (Path QS Post User) (mapcar '((E) (vals> E User 'r)) (list> This Path QS Post User)))
      
  (dm get_new> (Path QS Post User) (list 200 (list "instance" (spec> This User 'c))))
  (dm get_search> (Path QS Post User) (new (append (str This) '(+Seach))))
  (dm get_list> (Path QS Post User) 
    (list 200 (list "instances" (spec> This User 'r) (list_vals> This Path QS Post User))))
  (dm get_rel_options> (Path QS Post User) #not working yet
    (let (E (get (get This (cadr Path)) 'cls)) 
      (get_list> E)))
  
  (dm rest_get> (Path QS Post User) 
    (if (ext? This)
      (if (num? (any (car Path))) #Really don't like this; may need to restructure `process` because of it.
        (list 200 (list "instance" (spec> This User 'r) (vals> This User 'r)))
        (let (Rs (get This (intern (cadr Path))) Kls (intern (get (get (cls> This) (intern (cadr Path))) 'type)))
          (ifn Kls  #The whol mishigas above is just for this test :/
            (404)
            (list 200 (list "instances" (spec> Kls User 'r) (mapcar '((R)(vals> R User 'r)) Rs)))))) #Use first result for spec; not sure what to do if no results
      (default Path '("list"))
      (or (try (intern (pack "get_" (car Path) ">")) This Path QS Post User) (404))) )

  (dm rest_post> (Path QS Post User) 
    (if (= "del" (car Post))
      (rest_del> This (cdr Post) User)
      (if (or (= (car Path) "new") (nil? (car Path)))
        (prog 
          (setq E (new T (list This)))
          (try 'set_owner> E User))
        (setq E This))
      (for R (rels> E User (req_action Verb Path))
        (if (isa '+Link (meta E R))
          (for Eid (cdr (assoc R Post))
            (ifn (setq Ent (db 'eid '+REntity (any Eid)))
              (push 'Errs (list Eid "Does not exist"))
              (put> E R Ent)))
          (let (V (cdr (assoc R Post)))
            (cond
              ((setq Err (mis> E R (or (if (num? (any V)) (any V) V) (get E R)))) (push 'Errs (list R Err )))
              ((and V (not (may (req_action Verb Path) User This R))) (push 'Errs (list R "Forbidden")))
              (V (put> E R (if (num? (any V)) (any V) V)))))))
      (if Errs
        (prog 
          (rollback)
          (prog1 (list 422 (cons '(error) Errs)) (setq Errs NIL)) ) 
        (commit)
        (list 201 (list "instance" (spec> E User 'u) (vals> E User 'u)))) ) )
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

