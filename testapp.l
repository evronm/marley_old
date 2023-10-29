
(load "lib/marley.l")

(symbols 'entities 'pico)

(local) (+User +Venue +Provider +Service +Itinerary)


#Jamaica is the only client to date.  It is, however settable in config.l
#`process looks in the ns (from config.l) namespace (default 'enitities as above) for classes with (isa '+Rest) for "entity"
(class +Client +Jamaica +Rest)
  (dm home> (QS User)
    (cond 
      ((not User))
      ((isa '+Venue User))
      ((isa '+Provider User))
      ((isa '+User User))
      ()))
  (dm nav> (QS User)
    (cond 
      ((not User) (list ($a '((href . "/venue/list")) "Browse Venues") ($a '((href . "/provider/list")) "Browse providers") ))
      ((isa '+Venue User) (list ($a '((href . "/service/new")) "New Service") ($a '((href . "/service/list")) "Browse Services") ($a '((href . "/itineraries/list")) "Browse Upcoming visitors") ))
      ((isa '+Provider User))
      ((isa '+User User))
      ()))

#+REntity inherits from +Entity, adding rest methods and overriding a couple.  URL syntax is /entity/[new|search|eid] .
#eid is unique for all addressable entitities in the DB.
#additional required parameter for rel's is permissions:  read/write for user, group, other. Implemented in lib/relations.l
#default class perms can be set in config.l
#Each class should define a 'nm relation or method.  This needn't be unique, but will be used in link text for individual instances.

#This default app is an abstraction of a bespoke wine tour app.  The vendors corresond to tasting rooms, the providers to drivers, and the users to tasters.
#The framework, and the test app, should be sufficiently abstract that customisation required should be minimal for most gig/service oriented apps.

(class +User  +REntity +Rest)
  (rel eml (+Need +Key +Email) '(crud r c))
  (rel pw (+Need +Key +Password) '(cru NIL c))
  (rel salt (+String) NIL)
  (rel addr (+Idx +String) '(crud r c))
  (rel nm (+Need +Key +String) '(crud r c))
  (rel itins (+List +Joint) cust (+Itinerary) '(crud r c))

(class +Venue +User)
  (var perms (crud r cr))
  (rel providers (+List +Joint) venues (+Provider) '(crd crd cr))
  (rel services (+List +Joint) venue (+Service) '(crud r cr))

(class +Provider +User)
  (var perms (crud r cr))
  (rel venues (+List +Joint) providers (+Venue) '(crd crd r))
  (rel itins (+List +Joint) provider (+Itinerary) '(rd crd NIL))

(class +Service +REntity +Rest)
  (var perms (crud rc r))
  (dm owner> () (get This 'venue))
  (dm group_mem> (User) (isa '+Venue User))
  (dm set_owner>(User) (put> This 'venue User))

  (rel nm (+Need +Aux +Key +String) (venue) '(crud cr r))
  (rel duration (+Need +Number) '(crud cr r))
  (rel price (+Need +Number) '(crud cr r))
  (rel capacity (+Need +Number) '(crud cr r))
  (rel max_grp (+Number) '(crud cr r))
  (rel venue (+Need +Joint) services (+Venue) '(crud cr r))
  (rel itins (+List +Joint) services (+Itinerary) '(r crud NIL))


(class +Itinerary +REntity +Rest)
  (dm owner> () (cust This))
  (dm grp> () (provider This))
  (rel start_addr (+Need +String) '(crud r NIL))
  (rel dt (+Need +Idx +Date) '(crud r NIL))
  (rel tm (+Need +Time) '(crud r NIL))
  (rel cust (+Need +Joint) itins (+User) '(crud r NIL))
  (rel ppl (+Need +Number) '(crud r NIL))
  (rel services (+List +Joint) itins (+Service) '(crud r NIL))
  (rel provider (+Joint) itins (+Venue) '(crud r NIL))

(de go ()
  (start process) )

(de dbg () (!))

(load T)
#(bye)
