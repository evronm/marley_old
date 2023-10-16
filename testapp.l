
(load "lib/marley.l")

(symbols 'entities 'pico)

(local) (+User +Venue +Provider +Service +Itinerary)


(class +Client +Jamaica +Rest)
  (dm home> (Qs User)
    (cond 
      ((not User))
      ((isa '+Vendor User))
      ((isa '+Provider User))
      ((isa '+User User))
      ()))
  (dm nav> (Qs User)
    (cond 
      ((not User) '((url "/venue/list" "Browse Venues") (url "/provider/list" "Browse providers") ))
      ((isa '+Vendor User))
      ((isa '+Provider User))
      ((isa '+User User))
      ()))

(class +User  +REntity +Rest)
  (rel eml (+Need +Key +Email +Frm +New) '((r w)(r)))
  (rel pw (+Need +Key +Password +Frm +New) '((w)))
  (rel salt (+String) NIL)
  (rel addr (+Idx +String +Frm +New) '((r w)(r)))
  (rel nm (+Need +Key +String +Frm +New) '((r w)(r)))
  (rel itins (+List +Joint +Frm) cust (+Itinerary) '((r w) (r)))

(class +Venue +User)
  (var perms ((r c u d)(r)(c)))
  (rel providers (+List +Joint +Frm) venues (+Provider) '((r w d)(r w d)(r)))
  (rel services (+List +Joint +Frm) venue (+Service) '((r w d)(r)(r)))

(class +Provider +User)
  (var perms ((r c u d)(r)(c)))
  (rel venues (+List +Joint +Frm) providers (+Venue) '((r w d)(r w d)(r)))
  (rel itins (+List +Joint +Frm) provider (+Itinerary) '((r w d)(r w d)))

(class +Service +REntity +Rest)
  (var perms ((r c u d)(r)(r)))
  (var noauth '("list"))
  (dm owner> () (get This 'venue))
  (dm set_owner>(User) (put This 'venue User))
  (dm auth_post> (Path Qs Post User) (and (isa '+Venue User) (super)))

  (rel nm (+Need +Idx +String +Frm +New) '((r w d)(r)(r)))
  (rel duration (+Need +Number +Frm +New) '((r w d)(r)(r)))
  (rel price (+Need +Number +Frm +New) '((r w d)(r)(r)))
  (rel capacity (+Need +Number +Frm +New) '((r w d)(r)(r)))
  (rel max_group (+Number +Frm +New) '((r w d)(r)(r)))
  (rel venue (+Need +Joint +Frm +New) services (+Venue) '((r w d)(r)(r)))
  (rel itins (+List +Joint) services (+Itinerary) '((r w d)(r)(r)))


(class +Itinerary +REntity +Rest)
  (dm owner> () (cust This))
  (dm grp> () (provider This))
  (rel start_addr (+Need +String +Frm +New) '((r w d)(r)))
  (rel dt (+Need +Idx +Date +Frm +New) '((r w d)(r)))
  (rel tm (+Need +Time +Frm +New) '((r w d)(r)))
  (rel cust (+Need +Joint) itins (+User) '((r w d)(r)))
  (rel ppl (+Need +Number +Frm +New) '((r w d)(r)()))
  (rel services (+List +Joint +Frm) itins (+Service) '((r w d)(r u)))
  (rel provider (+Joint) itins (+Venue) '((r w d)(r u)))

(de go ()
  (start process) )

(de dbg () (!))

#(load T)
#(bye)

