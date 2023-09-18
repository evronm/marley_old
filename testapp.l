
(load "lib/marley.l")

(symbols 'entities 'pico)

(local) (+User +Venue +Provider +Service +Itinerary)

(class +User +Rest +Entity)
  (rel id (+Key +Number) '111)
  (rel eml (+Key +Email +Frm +New) '210)
  (rel pw (+Key +Password +Frm +New) '200)
  (rel salt (+String) '000)
  (rel addr (+Idx +String +Frm +New) '210)
  (rel nm (+String +Frm +New) '210)
  (rel itins (+List +Joint +Frm) cust (+Itinerary) '210)

(class +Venue +User +Entity)
  (rel providers (+List +Joint +Frm) venues (+Provider) '221)
  (rel services (+List +Joint +Frm) venue (+Service) '211)

(class +Provider +User)
  (rel venues (+List +Joint +Frm) providers (+Venue) '221)
  (rel itins (+List +Joint +Frm) provider (+Itinerary) '222)

(class +Service +Rest +Entity)
  (rel nm (+Idx +String +Frm +New) '211)
  (rel duration (+Number +Frm +New) '211)
  (rel price (+Number +Frm +New) '211)
  (rel capacity (+Number +Frm +New) '211)
  (rel max_group (+Number +Frm +New) '211)
  (rel venue (+Joint +Frm +New) services (+Venue) '211)
  (rel itins (+List +Joint) services (+Itinerary) '222)


(class +Itinerary +Rest +Entity)
  (dm owner_rel () 'cust)
  (dm grp_rel () 'provider)
  (dm perms () '221)
  (rel start_addr (+String +Frm +New) '211)
  (rel dt (+Idx +Date +Frm +New) '211)
  (rel tm (+Time +Frm +New) '211)
  (rel cust (+Joint) itins (+User) '211)
  (rel ppl (+Number +Frm +New) '211)
  (rel services (+List +Joint +Frm) itins (+Service) '211)
  (rel provider (+Joint) itins (+Venue) '211)

(de go ()
  (start authn process_req) )

(de dbg () (!))

(load T)
(bye)

