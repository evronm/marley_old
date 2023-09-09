(load '@lib/json.l)
(setq *NEWREC 1 *SEARCH 2)

(de reggae @
  (glue "," (mapcar '((Arg) (packJson Arg))  (rest)) ) )

(de mesg (Titl Msg)
  (list "mesg" Titl Msg))

(de url (Url Titl Desc)
  (list "url" Url Titl Desc))

(de row (Flgs Spec Vals)
  (list "row" Flgs Spec Vals))







(when *Dbg

(test "[\"url\", http://foo.com, \"Foo\", \"Foo website\"],[\"mesg\", \"Title\", \"Msg Content\"]" (reggae (url 'http://foo.com "Foo" "Foo website") (mesg "Title" "Msg Content")))

)
