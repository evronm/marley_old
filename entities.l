

(symbols 'entities 'rst 'r 'pico)

(local) (+User +Venue +Vendor +Event)

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
  (rel providers (+List +Joint) vendor (+Provider))
  (rel itins (+List +Joint) venue (+Itinerary))

(class +Provider +User)
  (rel nm (+Idx +String))
  (rel vendues (+List +Joint) vendor (+Venue))
  (rel itins (+List +Joint) vendor (+Itinerary))

(class +Service +Rest)
  (rel 

(class +Itinerary +Rest)
  (dm T ()
    (=: perms 666)
    (=: owner 'cust)
    (=: grp 'vendors 'vendors)
  )
  (rel dt (+Idx +Date))
  (rel tm (+Time))
  (rel cust (+Joint) event (+User))
  (rel services (+List +Joint) event (+Service))
  (rel provider (+Joint) event (+Venue))

(when *Dbg

)

