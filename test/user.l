
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


#anon searches for venues whose name starts with "ven1"
(test  (200 ("instances" ("/venue/" ("ro") ("eid" ("ro")) ((nm "text" (ro req)) (desc "text" (ro req)) (providers "instances" (ro)) (services "instances" (ro)))) ((@ID "ven1" "venue desc 1" NIL (("url" @URL "serv13" "serv13 desc") ("url" @URL "serv12" "serv12 desc") ("url" @URL "serv11" "serv11 desc"))) (@ID "ven10" "venue desc 10" NIL NIL)))) (process "get" '("venue") '((nm . ven1))))

#anon browses all providers
(test (200 ("instances" ("/provider/" ("ro") ("eid" ("ro")) ((nm "text" (ro req)) (desc "text" (ro req)) (venues "instances" (ro)))) ((@ID "prov1" "prov desc 1" NIL) (@ID "prov2" "prov desc 2" NIL) (@ID "prov3" "prov desc 3" NIL) (@ID "prov4" "prov desc 4" NIL) (@ID "prov5" "prov desc 5" NIL)))) (process "get" '("provider")))

#anon browses services from ven2
(process "get" '("service") (list (cons "venue"  (eid> (db 'nm '+Venue "ven2")))))

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
