

(symbols 'entities 'pico)

(local) (+User +Venue +Provider +Service +Itinerary)

(class +User +Rest)
  (rel id (+Key +Number))
  (rel eml (+Key +String))
  (rel pw (+Key +String))
  (rel salt (+String))
  (rel addr (+Idx +String))
  (rel nm (+String))
  (rel itins (+List +Joint) cust (+Itinerary))

(class +Venue +User)
  (rel nm (+Idx +String))
  (rel providers (+List +Joint) venues (+Provider))
  (rel services (+List +Joint) venues (+Service))

(class +Provider +User)
  (rel nm (+Idx +String))
  (rel venues (+List +Joint) providers (+Venue))
  (rel itins (+List +Joint) provider (+Itinerary))

(class +Service +Rest)
  (rel nm (+Idx +String))
  (rel duration (+Number))
  (rel price (+Number))
  (rel capacity (+Number))
  (rel max_group (+Number))
  (rel venue (+Joint) services (+Venue))


(class +Itinerary +Rest)
  (dm T ()
    (=: perms 664)
    (=: owner 'cust)
    (=: grp 'provider)
  )
  (rel dt (+Idx +Date))
  (rel tm (+Time))
  (rel cust (+Joint) itins (+User))
  (rel ppl (+Number))
  (rel services (+List +Joint) event (+Service))
  (rel provider (+Joint) event (+Venue))

(when *Dbg

)

