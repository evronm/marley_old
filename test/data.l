(load 'testapp.l)

(de proc_test @
  (process "post" (list (next) "new") NIL (car (rest)) ))

(symbols 'entities 'pico)
(proc_test 'user '(("eml" . "user1@eml.com") ("pw" . "asdf") ("addr" . "user1 address") ("nm" . "user1")))
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
