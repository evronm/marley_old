
(load "lib/marley.l")

(symbols 'entities 'pico)

(local) (+User +Venue +Provider +Service +Itinerary)


(class +Client +Jamaica +Rest)

(class +User  +Rest +Entity)
  (rel id (+Key +Number) '111)
  (rel eml (+Need +Key +Email +Frm +New) '210)
  (rel pw (+Need +Key +Password +Frm +New) '200)
  (rel salt (+String) '000)
  (rel addr (+Idx +String +Frm +New) '210)
  (rel nm (+Need +Key +String +Frm +New) '210)
  (rel itins (+List +Joint +Frm) cust (+Itinerary) '210)

(class +Venue +User)
  (rel providers (+List +Joint +Frm) venues (+Provider) '221)
  (rel services (+List +Joint +Frm) venue (+Service) '211)

(class +Provider +User)
  (rel venues (+List +Joint +Frm) providers (+Venue) '221)
  (rel itins (+List +Joint +Frm) provider (+Itinerary) '222)

(class +Service +Rest +Entity)
  (rel nm (+Need +Idx +String +Frm +New) '211)
  (rel duration (+Need +Number +Frm +New) '211)
  (rel price (+Need +Number +Frm +New) '211)
  (rel capacity (+Need +Number +Frm +New) '211)
  (rel max_group (+Number +Frm +New) '211)
  (rel venue (+Need +Joint +Frm +New) services (+Venue) '211)
  (rel itins (+List +Joint) services (+Itinerary) '222)


(class +Itinerary +Rest +Entity)
  (dm owner_rel () 'cust)
  (dm grp_rel () 'provider)
  (dm perms () '221)
  (rel start_addr (+Need +String +Frm +New) '211)
  (rel dt (+Need +Idx +Date +Frm +New) '211)
  (rel tm (+Need +Time +Frm +New) '211)
  (rel cust (+Need +Joint) itins (+User) '211)
  (rel ppl (+Need +Number +Frm +New) '211)
  (rel services (+List +Joint +Frm) itins (+Service) '211)
  (rel provider (+Joint) itins (+Venue) '211)

(de go ()
  (start process_req) )

(de dbg () (!))

(load T)
(bye)

