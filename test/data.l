(call 'rm 'DB)
(load 'testapp.l)


(de post @
  (process "post" (list (next) "new") NIL (next) (next)  ))

(symbols 'entities 'pico)
(for N 20
  (process "post" '("user" "new") NIL (list (cons "eml"  (pack "user" N "@eml.com")) (cons "pw" "asdf") (cons "addr"  (pack "user" N "address")) (cons "nm" (pack "user" N) ))))

(for N 5
  (process "post" '("provider" "new") NIL (list (cons "eml"  (pack "prov" N "@eml.com")) (cons "pw" "asdf") (cons "addr"  (pack "prov" N "address")) (cons "nm" (pack "prov" N) ) (cons "desc" (pack "prov desc " N) ))))

(for N 10
  (process "post" '("venue" "new") NIL (list (cons "eml"  (pack "ven" N "@eml.com")) (cons "pw" "asdf") (cons "addr"  (pack "ven" N "address")) (cons "nm" (pack "ven" N) ) (cons "desc" (pack "venue desc " N) ))))



(post 'service '(  ("nm" . "serv11") ("desc" . "serv11 desc") ("duration" . 1) ("price" . 10) ("capacity" . 12) ("max_grp" . 4)) '("ven1@eml.com" . "asdf"))
(post 'service '(  ("nm" . "serv12") ("desc" . "serv12 desc") ("duration" . 2) ("price" . 20) ("capacity" . 13) ("max_grp" . 5)) '("ven1@eml.com" . "asdf"))
(post 'service '(  ("nm" . "serv13") ("desc" . "serv13 desc") ("duration" . 3) ("price" . 30) ("capacity" . 14) ("max_grp" . 6)) '("ven1@eml.com" . "asdf"))

(post 'service '(  ("nm" . "serv21") ("desc" . "serv21 desc") ("duration" . 4) ("price" . 15) ("capacity" . 12) ("max_grp" . 4)) '("ven2@eml.com" . "asdf"))
(post 'service '(  ("nm" . "serv22") ("desc" . "serv22 desc") ("duration" . 5) ("price" . 16) ("capacity" . 13) ("max_grp" . 5)) '("ven2@eml.com" . "asdf"))

(post 'service '(  ("nm" . "serv31") ("desc" . "serv31 desc") ("duration" . 6) ("price" . 17) ("capacity" . 14) ("max_grp" . 6)) '("ven3@eml.com" . "asdf"))

(test 35 (length (lsearch NIL '((eid +User)))))
(test 6 (length (lsearch NIL '((nm +Service)))))

(test '(c) (may  'c (db 'nm '+Venue 'ven1) '+Service)) #A Venue can create a service.
(test NIL (may 'c (db 'nm '+Venue 'user1) '+Service)) #But a User cannot.
(test '(u d) (may 'u (db 'nm '+Venue 'ven1) (db 'nm '+Service 'serv11))) #A venue can update and delete a 
(test NIL (may 'u (db 'nm '+Venue 'ven2) (db 'nm '+Service 'serv11)))


#(test '(422 ((error) (nm "Input required") (pw "Input required") (eml "Input required"))) (post 'user ))
#(test '(422 ((error) (pw "Input required") (eml "Input required"))) (post 'user '(("nm" . "asdf"))) )

#(test '(422 ((error) (desc "Input required") (nm "Not unique"))) (post 'service '(  ("nm" . "serv11") ("duration" . 1) ("price" . 10) ("capacity" . 12) ("max_grp" . 4)) '("ven1@eml.com" . "asdf")))
