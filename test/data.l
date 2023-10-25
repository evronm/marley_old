(load 'testapp.l)

(de proc_test @
  (process "post" (list (next) "new") NIL (next) (next)  ))

(symbols 'entities 'pico)
(proc_test 'user '(("eml" . "user1@eml.com") ("pw" . "asdf") ("addr" . "user1 address") ("nm" . "user1") ))
(proc_test 'user '(("eml" . "user2@eml.com") ("pw" . "asdf") ("addr" . "user2 address") ("nm" . "user2")))
(proc_test 'user '(("eml" . "user3@eml.com") ("pw" . "asdf") ("addr" . "user3 address") ("nm" . "user3")))
(proc_test 'user '(("eml" . "user4@eml.com") ("pw" . "asdf") ("addr" . "user4 address") ("nm" . "user4")))
(proc_test 'user '(("eml" . "user5@eml.com") ("pw" . "asdf") ("addr" . "user5 address") ("nm" . "user5")))

(proc_test 'provider '(("eml" . "prov1@eml.com") ("pw" . "asdf") ("addr" . "prov1 address") ("nm" . "prov1")))
(proc_test 'provider '(("eml" . "prov2@eml.com") ("pw" . "asdf") ("addr" . "prov2 address") ("nm" . "prov2")))
(proc_test 'provider '(("eml" . "prov3@eml.com") ("pw" . "asdf") ("addr" . "prov3 address") ("nm" . "prov3")))

(proc_test 'venue '(("eml" . "ven1@eml.com") ("pw" . "asdf") ("addr" . "ven1 address") ("nm" . "ven1")))
(proc_test 'venue '(("eml" . "ven2@eml.com") ("pw" . "asdf") ("addr" . "ven2 address") ("nm" . "ven2")))
(proc_test 'venue '(("eml" . "ven3@eml.com") ("pw" . "asdf") ("addr" . "ven3 address") ("nm" . "ven3")))


(proc_test 'service '(  ("nm" . "serv11") ("duration" . 1) ("price" . 10) ("capacity" . 12) ("max_grp" . 4)) '("ven1@eml.com" . "asdf"))
(proc_test 'service '(  ("nm" . "serv12") ("duration" . 2) ("price" . 20) ("capacity" . 13) ("max_grp" . 5)) '("ven1@eml.com" . "asdf"))
(proc_test 'service '(  ("nm" . "serv13") ("duration" . 3) ("price" . 30) ("capacity" . 14) ("max_grp" . 6)) '("ven1@eml.com" . "asdf"))

(proc_test 'service '(  ("nm" . "serv21") ("duration" . 4) ("price" . 15) ("capacity" . 12) ("max_grp" . 4)) '("ven2@eml.com" . "asdf"))
(proc_test 'service '(  ("nm" . "serv22") ("duration" . 5) ("price" . 16) ("capacity" . 13) ("max_grp" . 5)) '("ven2@eml.com" . "asdf"))

(proc_test 'service '(  ("nm" . "serv31") ("duration" . 6) ("price" . 17) ("capacity" . 14) ("max_grp" . 6)) '("ven3@eml.com" . "asdf"))

(test '(c) (may  'c (db 'nm '+Venue 'ven1) '+Service)) #A Venue can create a service.
(test NIL (may 'c (db 'nm '+Venue 'user1) '+Service)) #But a User cannot.
(test '(u d) (may 'u (db 'nm '+Venue 'ven1) (db 'nm '+Service 'serv11))) #A venue can update and delete a 
(test NIL (may 'u (db 'nm '+Venue 'ven2) (db 'nm '+Service 'serv11)))
