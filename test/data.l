(load 'testapp.l)

(de proc_test @
  (process "post" (list (next) "new") NIL (next) (next)  ))

(symbols 'entities 'pico)
(for N 20
  (process "post" '("user" "new") NIL (list (cons "eml"  (pack "user" N "@eml.com")) (cons "pw" "asdf") (cons "addr"  (pack "user" N "address")) (cons "nm" (pack "user" N) ))))

(for N 5
  (process "post" '("provider" "new") NIL (list (cons "eml"  (pack "prov" N "@eml.com")) (cons "pw" "asdf") (cons "addr"  (pack "prov" N "address")) (cons "nm" (pack "prov" N) ))))

(for N 10
  (process "post" '("venue" "new") NIL (list (cons "eml"  (pack "ven" N "@eml.com")) (cons "pw" "asdf") (cons "addr"  (pack "ven" N "address")) (cons "nm" (pack "ven" N) ))))



(proc_test 'service '(  ("nm" . "serv11") ("duration" . 1) ("price" . 10) ("capacity" . 12) ("max_grp" . 4)) '("ven1@eml.com" . "asdf"))
(proc_test 'service '(  ("nm" . "serv12") ("duration" . 2) ("price" . 20) ("capacity" . 13) ("max_grp" . 5)) '("ven1@eml.com" . "asdf"))
(proc_test 'service '(  ("nm" . "serv13") ("duration" . 3) ("price" . 30) ("capacity" . 14) ("max_grp" . 6)) '("ven1@eml.com" . "asdf"))

(proc_test 'service '(  ("nm" . "serv21") ("duration" . 4) ("price" . 15) ("capacity" . 12) ("max_grp" . 4)) '("ven2@eml.com" . "asdf"))
(proc_test 'service '(  ("nm" . "serv22") ("duration" . 5) ("price" . 16) ("capacity" . 13) ("max_grp" . 5)) '("ven2@eml.com" . "asdf"))

(proc_test 'service '(  ("nm" . "serv31") ("duration" . 6) ("price" . 17) ("capacity" . 14) ("max_grp" . 6)) '("ven3@eml.com" . "asdf"))

(test 35 (length (lsearch NIL '((nm +User)))))
(test 6 (length (lsearch NIL '((nm +Service)))))

(test '(c) (may  'c (db 'nm '+Venue 'ven1) '+Service)) #A Venue can create a service.
(test NIL (may 'c (db 'nm '+Venue 'user1) '+Service)) #But a User cannot.
(test '(u d) (may 'u (db 'nm '+Venue 'ven1) (db 'nm '+Service 'serv11))) #A venue can update and delete a 
(test NIL (may 'u (db 'nm '+Venue 'ven2) (db 'nm '+Service 'serv11)))
