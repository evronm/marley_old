
(load "lib/proto.l")
(load "lib/util.l")
(load "lib/server.l")
(load "config.l")

(de conf (Lst)
  (if (= 1 (length Lst))
    (assoc (car Lst) *CONFIG)
    (assoc (car Lst) (conf (cdr Lst)))))

(de confv (Lst)
  (cdr (conf Lst)))


(de authn (Un Pw)
  (prinl Un "\n" Pw)
  T
)

(de Authz (Un Verb Path)
)



(de process_req (Verb Path Qs Post User)
  (default Path (confv '(default_path)))
  (setq Thing (car pth) Ns (intern (confv 'ns)))
  (or 
    (and 
      (setq Fn (car Path))
      (match (append '(@foo) '(.) '(@ext)) (chop Fn))
      (if  (member (pack @ext) '(html htmx css js png gif))
        (if ( info (pack (confv '(static_dir)) Fn)) 
          (respond 200 (in (pack (confv '(static_dir)) Fn ) (till)))
          (respond 404))
        (respond 403)))
    (respond 200 (let (Cls (or (isa '+Rest (intern (to_cls_nm Noun) Ns)) (intern (to_cls_nm (singularize Noun) Ns )))) (send Verb Cls Path Qs Post User)) )
    (respond 404)))


(pool (confv '(pool)))

(class +Rest +Entity)
  (dm owner_col> (
    'uid
  ))
  (dm owner_at_creation> ()
    (or (: owner_at_creation) current_user)
  )
  (dm perms> ()
    (or (: perms) 611)
  )
  
  (dm get> () prinl 'get)
  (dm post> () prinl 'post)
  (dm put> () prinl 'put)
  (dm delete> () prinl 'del)

(when *Dbg

)
