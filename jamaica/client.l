

(de tag (Tag)
  (setq @Tag (name Tag))
  (fill '((Attrs Cont) 
    (pack "<" @Tag " "
      (mapcar '((A) (list (car A) "='" (cdr A) "' ")) Attrs)
      ">" Cont "</" @Tag ">"))))

(for Tag '(html head script link body h1 h2 h3 a p em strong div form label input textarea submit button) (set (intern (pack "$" Tag)) (tag Tag)))

(class +Jamaica)
  (dm need_auth> () NIL)
  (dm nav> (User) )
  (dm account> (User)
    (list 
    ($form '((id . creds))  
      (list ($label '((for . eml)) "Email:") 
      ($input '((name . eml)(type . text)) )
      ($label '((for . pw)) "Password:") 
      ($input '((name . pw)(type . password)) )
      ($button '((id . login)) "Login")
      ($button '((id . logout)) "Logout")))

      ($a '((href . /user/new)) "Sign up")
      (mapcar 
        '((U) ($a (list (cons 'href (pack (cls_to_str U) "/new") )) (pack "Register as a " (cls_to_str U)))) 
        (filter '((E)(isa (intern "+User" (intern (confv '(ns)))) E)) (all (intern (confv '(ns))))))))

  (dm title> () (confv '(title)) )
  (dm rest_get> (Path QS Post User) 
    (list 200($html NIL (list 
      ($head NIL ( list
        #($link '((rel . stylesheet) (href . https://unpkg.com/mvp.css)))
        ($script '((type text/javascript) (src . https://cdn.jsdelivr.net/npm/umbrellajs)))
        ($script '((type text/javascript) (src . https://cdn.jsdelivr.net/gh/vanjs-org/van/public/van-1.2.0.nomodule.min.js)))
        ($script '((type text/javascript)) (pack (in "jamaica/reggae.js" (till))))
        ($script '((type text/javascript)) (pack (in "jamaica/jamaica.js" (till))))))
      ($body NIL (list 
        ($div '((id . header)) (list
          ($h1 NIL (title> This))
          ($div '((id . account)) (account> This))))
        ($div '((id . nav)) (nav> This QS User))
        ($div '((id . main))))))) "html")) 
   

