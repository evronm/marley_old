
(load 'test/data.l)

(test (200 ("instance" ("/user/" ("new") ((eml "text" (req)) (pw "password" (req)) (addr "text" NIL) (nm "text" (req)))))) (process "get" '("user" "new")))
(test (200 ("instance" ("/provider/" ("new") ((eml "text" (req)) (pw "password" (req)) (addr "text" NIL) (nm "text" (req)) (desc "text" (req))))))
  (process "get" '("provider" "new")))
(test (200 ("instance" ("/venue/" ("new") ((eml "text" (req)) (pw "password" (req)) (addr "text" NIL) (nm "text" (req)) (desc "text" (req))))))
  (process "get" '("venue" "new")))


(test (401) (process "get" '("service" "new")))
(test (200 ("instance" ("/service/" ("new") ((nm "text" (req)) (desc "text" (req)) (duration "number" (req)) (price "number" (req)) (capacity "number" (req)) (max_grp "number" NIL))))) 
  (process "get" '("service" "new") NIL NIL '("ven1@eml.com" "asdf")))
