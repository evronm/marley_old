#(symbols 'util 'pico)
(load "lib/plursing.l")

(de reggae (Lst)
  (cond 
    ((num? Lst) Lst)
    ((or (sym? Lst) (str? Lst)) (pack "\"" Lst "\""))
    (T (pack "[" (glue ", " (mapcar '((Foo)( reggae Foo)) Lst)) "]"))))

(de conf (Lst)
  (if (= 1 (length Lst))
    (assoc (car Lst) *CONFIG)
    (assoc (car Lst) (conf (cdr Lst)))))

(de confv (Lst)
  (cdr (conf Lst)))

(de req_action (Verb Path) 
  (if (= "new" (car Path))
    'c
    (if (and (= "post" Verb) (num? (any (car Path)))) 
      'u 
      (if (= "del" (car Path) 'd 'r)))))

(de pw_hash (Pw Salt)
  (pipe (out (list 'argon2 Salt '-r) (prin Pw)) (read)))

(de sc (Str . @)
  (eval (append '(split) '((chop Str)) (rest))))

(de assov (K Lst)
  (cdr (assoc K Lst)))

(de capitalize (Str)
  (let s (chop Str)
    (pack (uppc (car s)) (cdr s))))

(de camelize (Str)
  (pack (mapcar 'capitalize (sc Str "_") )))

(de to_cls_nm (Str)
  (pack "+" (camelize Str)))

(de cls_to_str (Cls)
  (pack (cdr (chop (name Cls)))))

(de nil? (Foo)
  (= NIL Foo))

(de surr (Str Surr)
  (let (Close (
    case Surr
      ("(" . ")")
      ("[" . "]")
      ("{" "}")
      (T Surr)
  )) 
    (pack Surr Str Close)
  )
)


(when *Dbg
  ~(assert (= 'cbc25a53074d0702178e1f0cb015c2a4667f6af5b6ba1ba9289b289afaa7ca26 (pw_hash 'password '12345678)))
  ~(assert (= "xasdfx" (surr "asdf" "x")))
  ~(assert (= "(asdf)" (surr "asdf" "(")))
  ~(assert (= "[asdf]" (surr "asdf" "[")))
  ~(assert (= "{asdf}" (surr "asdf" "{")))

  ~(assert (= "+AsdfXxx" (to_cls_nm 'asdf_xxx)))


)

