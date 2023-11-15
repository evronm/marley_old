
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
(test (201 @N) (process "post" '("user") NIL '((eml . "adasdf@eml.com") (nm . "asdfa") (pw . "asdf"))))

#duplicate email
(test (422 ((error) (eml "Not unique"))) (process "post" '("user") NIL '((eml . "adasdf@eml.com") (nm . "asdfa") (pw . "asdf"))))


#anon searches for venues whose name starts with "ven1"
#(test  (200 ("instances" ("/venue/" ("ro") ("eid" ("ro")) ((nm "text" (ro req)) (desc "text" (ro req)) (providers "instances" (ro)) (services "instances" (ro)))) ((@ID "ven1" "venue desc 1" NIL (("url" @URL "serv13" "serv13 desc") ("url" @URL "serv12" "serv12 desc") ("url" @URL "serv11" "serv11 desc"))) (@ID "ven10" "venue desc 10" NIL NIL)))) (process "get" '("venue") '((nm . ven1))))

#anon browses all providers
#(test (200 ("instances" ("/provider/" ("ro") ("eid" ("ro")) ((nm "text" (ro req)) (desc "text" (ro req)) (venues "instances" (ro)))) ((@ID "prov1" "prov desc 1" NIL) (@ID "prov2" "prov desc 2" NIL) (@ID "prov3" "prov desc 3" NIL) (@ID "prov4" "prov desc 4" NIL) (@ID "prov5" "prov desc 5" NIL)))) (process "get" '("provider")))

#anon browses services from ven2
#(test (200 ("instances" ("/service/" ("ro") ("eid" ("ro")) ((nm "text" (ro req)) (duration "number" (ro req)) (price "number" (ro req)) (capacity "number" (ro req)) (max_grp "number" (ro)) (venue "text" (ro req)))) ((@Serv1 "serv21" 4 15 12 4 @V1) (@Serv2 "serv22" 5 16 13 5 @V1)))) (process "get" '("service") (list (cons "venue"  (eid> (db 'nm '+Venue "ven2"))))))

#anon requests new itinerary form
(test (401) (process "get" '("Itinerary" "new")))

#user requests new itinerary form
(test (200 ("instance" ("/itinerary/" ("new") ((start_addr "text" (req)) (dt "date" (req)) (tm "time" (req)) (ppl "number" (req)))))) (process "get" '("Itinerary" "new") NIL NIL '("user1@eml.com" "asdf")))

#user tries to create an itenerary with no data
(test (422 ((error) (ppl "Input required") (tm "Input required") (dt "Input required") (start_addr "Input required"))) (process "post" '("itinerary" "new") NIL NIL '("user1@eml.com" . "asdf")))

#user tries to create itinerary with incomplete data
(test (422 ((error) (tm "Input required") (dt "Input required"))) (process "post" '("itinerary" "new") NIL '((ppl . 2) (start_addr . "asdf asdf")) '("user1@eml.com" . "asdf")))

#user creates itinerary successfully; grab ID to add services in next test
(match '(@Code @Id) (process "post" '("itinerary" "new") NIL '((ppl . 2) (start_addr . "asdf asdf") (dt . "2024-01-03") (tm . "11:30")) '("user1@eml.com" . "asdf")))
(test (201) @Code)

#user adds service to existing itinerary
#(process "post" (list "itinerary" (car @Id)) NIL (list "services" (eid> (db 'nm '+Service "serv11"))) '("user1@eml.com" . "asdf"))

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
