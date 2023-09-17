(setq *NEWREC 1 *SEARCH 2 *READ 2 *WRITE 1)

(load '@lib/json.l)
(load "lib/util.l")
(load "lib/server.l")
(load "config.l")

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

(extend +String) (dm reggae> () "text")
(extend +Number) (dm reggae> () "number")
(extend +Date) (dm reggae> () "date")
(extend +Time) (dm reggae> () "time")
(extend +Bool) (dm reggae> () "bool")
(extend +List) (dm reggae> () "instances")
(class +Password +String) (dm reggae> () "password")
(class +Email +String) (dm reggae> () "email")

(extend +relation)
  (dm perms> (p)
    (if p (=: perms p) (: perms)))


(redef rel Lst
  (if (and (num? (cdar (tail 1 Lst))) (not (num? (tail 1 Lst))))
    (prog (eval (cons 'rel (head -1 Lst) ))
      (perms> (get *Class (car Lst)) (car (tail 1 Lst))))
    (eval (cons 'rel Lst))))

(class +Rest) 
  (dm owner_rel () 'uid)
  (dm owner_at_creation> () (or (: owner_at_creation) current_user))
  (dm perms> () '211)
  
  (dm rels> (Cls) 
    (setq Rels (delete NIL (append (try 'rels> (car (type This))) (filter '((r) (<> (cdr r) '*Dbg)) (getl This)))))
    (if (> Cls Nil)
      (filter '((r) (= Cls (sect Cls (type (car r))))) Rels)
      Rels))

  (dm reggae> (new?  search?)
    (reggae (list "instance" 
      (cond 
        (new? (list 
          *NEWREC
          (mapcar '((r) (list (sym (cdr r)) (reggae> (car r)))) (rels> This '(+Frm +New)))))
        (T (list
          0
          (mapcar '((r) (list (sym (cdr r)) (reggae> (car r)))) (rels> This '(+Frm)))))))))
      

  (dm get> (Path Qs Post User) 
    (case (cadr Path)
      ("new" (reggae> This T))
      ((NIL "list") )
      ("search" (reggae> This NIL T)) 
    ))

  (dm post> () prinl 'post)
  (dm put> () prinl 'put)
  (dm delete> () prinl 'del)


(when *Dbg

)
