
(load 'test/data.l)

#anon requests new service form
(test (401) (process "get" '("service" "new")))
#anon tries to create service
(test (401) (process "get" '("service" "new")))
#vendor requests new service form
(test (200 ("instance" ("/service/" ("new") ((nm "text" (req)) (desc "text" (req)) (duration "number" (req)) (price "number" (req)) (capacity "number" (req)) (max_grp "number" NIL))))) 
  (process "get" '("service" "new") NIL NIL '("ven1@eml.com" "asdf")))

#(test (200 ("instance" ("/service/" ("ro") ((nm "text" (ro req)) (duration "number" (ro req)) (price "number" (ro req)) (capacity "number" (ro req)) (max_grp "number" (ro)) (venue "text" (ro req)))) ("serv13" 3 30 14 6 {137}))) 
#  (process "get" '("service" 38)))
