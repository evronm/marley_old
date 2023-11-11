

(load 'test/data.l)
(symbols 'entities 'pico)
#anon requests new user form
(test (200 ("instance" ("/user/" ("new") ((eml "text" (req)) (pw "password" (req)) (addr "text" NIL) (nm "text" (req)))))) (process "get" '("user" "new")))

#anon requests new venue form
(test (200 ("instance" ("/venue/" ("new") ((eml "text" (req)) (pw "password" (req)) (addr "text" NIL) (nm "text" (req)) (desc "text" (req))))))
  (process "get" '("venue" "new")))

#anon requests new provider form
(test (200 ("instance" ("/provider/" ("new") ((eml "text" (req)) (pw "password" (req)) (addr "text" NIL) (nm "text" (req)) (desc "text" (req))))))
  (process "get" '("provider" "new")))

#anon attempts to create empty user
(test (422 ((error) (nm "Input required") (pw "Input required") (eml "Input required"))) (process "post" '("user")))

#anon attempts to create user with missing data
(test (422 ((error) (nm "Input required") (pw "Input required"))) (process "post" '("user") NIL '((eml . "adasdf@eml.com"))))

#anon creates new user
(test (201 ("mesg" "Success" "created successfully")) (process "post" '("user") NIL '((eml . "adasdf@eml.com") (nm . "asdfa") (pw . "asdf"))))

#duplicate email
(test (422 ((error) (eml "Not unique"))) (process "post" '("user") NIL '((eml . "adasdf@eml.com") (nm . "asdfa") (pw . "asdf"))))

#anon browses all venues
(test (200 ("instances" ("/venue/" ("ro") ((nm "text" (ro req)) (desc "text" (ro req)) (providers "instances" (ro)) (services "instances" (ro)))) (("ven1" "venue desc 1" NIL (("url" "/service/38" "serv13" "serv13 desc") ("url" "/service/37" "serv12" "serv12 desc") ("url" "/service/36" "serv11" "serv11 desc"))) ("ven2" "venue desc 2" NIL (("url" "/service/40" "serv22" "serv22 desc") ("url" "/service/39" "serv21" "serv21 desc"))) ("ven3" "venue desc 3" NIL (("url" "/service/41" "serv31" "serv31 desc"))) ("ven4" "venue desc 4" NIL NIL) ("ven5" "venue desc 5" NIL NIL) ("ven6" "venue desc 6" NIL NIL) ("ven7" "venue desc 7" NIL NIL) ("ven8" "venue desc 8" NIL NIL) ("ven9" "venue desc 9" NIL NIL) ("ven10" "venue desc 10" NIL NIL))))(process "get" '("venue")))

#anon searches for venues whose name starts with "ven1"
(test (200 ("instances" ("/venue/" ("ro") ((nm "text" (ro req)) (desc "text" (ro req)) (providers "instances" (ro)) (services "instances" (ro)))) (("ven1" "venue desc 1" NIL (("url" "/service/38" "serv13" "serv13 desc") ("url" "/service/37" "serv12" "serv12 desc") ("url" "/service/36" "serv11" "serv11 desc"))) ("ven10" "venue desc 10" NIL NIL)))) (process "get" '("venue") '((nm . ven1))))

#anon browses all providers
(test (200 ("instances" ("/provider/" ("ro") ((nm "text" (ro req)) (desc "text" (ro req)) (venues "instances" (ro)))) (("prov1" "prov desc 1" NIL) ("prov2" "prov desc 2" NIL) ("prov3" "prov desc 3" NIL) ("prov4" "prov desc 4" NIL) ("prov5" "prov desc 5" NIL)))) (process "get" '("provider")))

#user creates itinerary with 3 services

#user adds service to existing itinerary

#user view itinerary

#user creates another itinerary

#user lists itineraries

#user views second itinerary

#user views first itinerary

#user attempts to add to past itinerary

#user attempts to delete from past itinerary

#user 







#
#
#
