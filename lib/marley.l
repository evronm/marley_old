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

(de reggae (Args)
  (glue "," (split (replace (chop (str (list Args)) " ") "(" "[" ")" "]") " ")))

(de authn (Un Pw)
  (prinl Un "\n" Pw)
  T)

(de process_req (Verb Path Qs Post User)
  (default Path (confv '(default_path)))
  (setq Thing (car Path) Ns (intern (confv '(ns))))
  (or 
    (and 
      (setq Fn (car Path))
      (match (append '(@foo) '(.) '(@ext)) (chop Fn))
      (if  (member (pack @ext) '(html htmx css js png gif))
        (if ( info (pack (confv '(static_dir)) Fn)) 
          (respond 200 (in (pack (confv '(static_dir)) Fn ) (till)))
          (respond 404))
        (respond 403)))
    (respond 200 (let (Cls (or (isa '+Rest (intern (to_cls_nm Thing) Ns)) (intern (to_cls_nm (singularize Thing) Ns )))) (send (any (pack Verb ">")) Cls Path Qs Post User)) )
    (respond 404)))


(pool (confv '(pool)))


(class +Rest) 
  (dm owner_rel () 'uid)
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
    (case (cadr Path)
      ("new" (reggae> This T))
      ((NIL "list") )
      ("search" (reggae> This NIL T)) 
    ))

  (dm post> (Path Qs Post User) (!) )
  (dm delete> (Path Qs Post User) prinl 'del)

  (dm check> () 
    (mapcar 
      '((R) (check> (car R) )) 
      (rels> (cls> This))  ))

(when *Dbg

)
