
(de tag (Tag)
  (setq @Tag (name Tag))
  (fill '((Attrs Cont) 
      (pack "<" @Tag " "
      (mapcar '((A) (list (car A) "='" (cdr A) "' ")) Attrs)
      ">" Cont "</ " @Tag ">")
    )))

(for Tag '(html head script body h1 h2 h3 p em strong div form input textarea submit button) (set (intern (pack "$" Tag)) (tag Tag)))

(class +Client)
  (var js  ~(pack (in "jamaica/jamaica.js" (till))))
  (dm nav> () )
  (dm title> () (confv '(title)) )
  (dm get> (User) 
    ($html NIL 
      (list ($head NIL 
        ($script '((type text/javascript)) (: js) ))
      ($body NIL ($h1 NIL (title> This))))))
    

