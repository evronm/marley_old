
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
  (rel providers (+List +Joint +Frm) venues (+Provider))
  (rel services (+List +Joint +Frm) venue (+Service))

(class +Provider +User)
  (rel venues (+List +Joint +Frm) providers (+Venue))
  (rel itins (+List +Joint +Frm) provider (+Itinerary))

(class +Service +Rest +Entity)
  (rel nm (+Idx +String +Frm +New))
  (rel duration (+Number +Frm +New))
  (rel price (+Number +Frm +New))
  (rel capacity (+Number +Frm +New))
  (rel max_group (+Number +Frm +New))
  (rel venue (+Joint +Frm +New) services (+Venue))
  (rel itins (+List +Joint) services (+Itinerary))


(class +Itinerary +Rest +Entity)
  (dm owner_rel () 'cust)
  (dm grp_rel () 'provider)
  (dm perms () '221)
  (rel start_addr (+String +Frm +New))
  (rel dt (+Idx +Date +Frm +New))
  (rel tm (+Time +Frm +New))
  (rel cust (+Joint) itins (+User))
  (rel ppl (+Number +Frm +New))
  (rel services (+List +Joint +Frm) itins (+Service))
  (rel provider (+Joint) itins (+Venue))

(de go ()
  (start authn process_req) )

(de dbg () (!))

#(load T)
#(bye)

