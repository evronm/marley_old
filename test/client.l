
(load 'test/data.l)

# anon requests new user form

# anon requests new venue form

# anon requests new provider form

# anon requests new service form

# vendor requests new service form

# anon requests new service form




(test (200 ("instance" ("/user/" ("new") ((eml "text" (req)) (pw "password" (req)) (addr "text" NIL) (nm "text" (req)))))) (process "get" '("user" "new")))
(test (200 ("instance" ("/provider/" ("new") ((eml "text" (req)) (pw "password" (req)) (addr "text" NIL) (nm "text" (req)) (desc "text" (req))))))
  (process "get" '("provider" "new")))
(test (200 ("instance" ("/venue/" ("new") ((eml "text" (req)) (pw "password" (req)) (addr "text" NIL) (nm "text" (req)) (desc "text" (req))))))
  (process "get" '("venue" "new")))


(test (401) (process "get" '("service" "new")))
(test (200 ("instance" ("/service/" ("new") ((nm "text" (req)) (desc "text" (req)) (duration "number" (req)) (price "number" (req)) (capacity "number" (req)) (max_grp "number" NIL))))) 
  (process "get" '("service" "new") NIL NIL '("ven1@eml.com" "asdf")))

(test (200 ("instance" ("/service/" ("ro") ((nm "text" (ro req)) (duration "number" (ro req)) (price "number" (ro req)) (capacity "number" (ro req)) (max_grp "number" (ro)) (venue "text" (ro req)))) ("serv13" 3 30 14 6 {137}))) 
  (process "get" '("service" 38)))
