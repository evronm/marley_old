
(load "lib/marley.l")

(symbols 'entities 'pico)

(local) (+User +Venue +Provider +Service +Itinerary)


#Jamaica is the only client to date.  It is, however settable in config.l
#`process looks in the ns (from config.l) namespace (default 'enitities as above) for classes with (isa '+Rest) for "entity"
(class +Client +Jamaica +Rest)
  (dm home> (Qs User)
    (cond 
      ((not User))
      ((isa '+Venue User))
      ((isa '+Provider User))
      ((isa '+User User))
      ()))
  (dm nav> (Qs User)
    (cond 
      ((not User) (list ($a '((href . "/venue/list")) "Browse Venues") ($a '((href . "/provider/list")) "Browse providers") ))
      ((isa '+Venue User) (list ($a '((href . "/service/new")) "New Service") ($a '((href . "/itineraries/list")) "Browse Upcoming visitors") ))
      ((isa '+Provider User))
      ((isa '+User User))
      ()))

#+REntity inherits from +Entity and adds REST functionality.  URL syntax is /entity/[new|search|eid] .
#eid is unique for all addressable entitities in the DB.
#additional required parameter for rel's is permissions:  read/write for user, group, other. Implemented in lib/relations.l
#default class perms can be set in config.l

#This default app is an abstraction of a bespoke wine tour app.  The vendors corresond to tasting rooms, the providers to drivers, and the users to tasters.
#The framework, and the test app, should be sufficiently abstract that customisation required should be minimal for most gig/service oriented apps.

(class +User  +REntity +Rest)
  (rel eml (+Need +Key +Email) '((r w)(r)))
  (rel pw (+Need +Key +Password) '((w)))
  (rel salt (+String) NIL)
  (rel addr (+Idx +String) '((r w)(r)))
  (rel nm (+Need +Key +String) '((r w)(r)))
  (rel itins (+List +Joint) cust (+Itinerary) '((r w) (r)))

(class +Venue +User)
  (var perms ((r c u d)(r)(c)))
  (rel providers (+List +Joint) venues (+Provider) '((r w d)(r w d)(r)))
  (rel services (+List +Joint) venue (+Service) '((r w d)(r)(r)))

(class +Provider +User)
  (var perms ((r c u d)(r)(c)))
  (rel venues (+List +Joint) providers (+Venue) '((r w d)(r w d)(r)))
  (rel itins (+List +Joint) provider (+Itinerary) '((r w d)(r w d)))

(class +Service +REntity +Rest)
  (var perms ((r c u d)(r c)(r)))
  (dm owner> () (get This 'venue))
  (dm group_mem> (User) (isa '+Venue User))
  (dm set_owner>(User) (put> This 'venue User))

  (rel nm (+Need +Idx +String) '((r w d)(r)(r)))
  (rel duration (+Need +Number) '((r w d)(r)(r)))
  (rel price (+Need +Number) '((r w d)(r)(r)))
  (rel capacity (+Need +Number) '((r w d)(r)(r)))
  (rel max_grp (+Number) '((r w d)(r)(r)))
  (rel venue (+Need +Joint) services (+Venue) '((r w d)(r)(r)))
  (rel itins (+List +Joint) services (+Itinerary) '((r w d)(r)(r)))


(class +Itinerary +REntity +Rest)
  (dm owner> () (cust This))
  (dm grp> () (provider This))
  (rel start_addr (+Need +String) '((r w d)(r)))
  (rel dt (+Need +Idx +Date) '((r w d)(r)))
  (rel tm (+Need +Time) '((r w d)(r)))
  (rel cust (+Need +Joint) itins (+User) '((r w d)(r)))
  (rel ppl (+Need +Number) '((r w d)(r)()))
  (rel services (+List +Joint) itins (+Service) '((r w d)(r u)))
  (rel provider (+Joint) itins (+Venue) '((r w d)(r u)))

(de go ()
  (start process) )

(de dbg () (!))

(load T)
#(bye)

