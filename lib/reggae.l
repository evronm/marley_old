(load '@lib/json.l)

(de reggae @
  (glue "," (mapcar '((Arg) (packJson Arg))  (rest)) ) )

(de mesg (Titl Msg)
  (list "mesg" Titl Msg))

(de url (Url Titl Desc)
  (list "url" Url Titl Desc))

(de instance (Flgs Spec Vals)
  (list "instance" Flgs Spec Vals))







(when *Dbg

(test "[\"url\", http://foo.com, \"Foo\", \"Foo website\"],[\"mesg\", \"Title\", \"Msg Content\"]" (reggae (url 'http://foo.com "Foo" "Foo website") (mesg "Title" "Msg Content")))

)
