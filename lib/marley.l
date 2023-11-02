
(load "lib/util.l")
(load "lib/server.l")
(load "config.l")
(load "lib/er_mods.l")


(load (pack (confv '(client)) "/client.l"))

(de authn (Creds)
  (let (Cls (intern "+User" (intern (confv '(ns)))))
    (setq User (db 'eml Cls (car Creds))))
    (and User (= (pw_hash (cdr Creds) (get User 'salt)) (get User 'pw)) User)) #User needs to show up twice to prevent error and return User.

(de req_action (Verb Path) 
  (if (and (= "get" Verb) (member (car Path) '("list" "show" NIL)))
    'r
    (if (or (= "new" (car Path) ) (nil? (car Path)))
      'c
      (if (and (= "post" Verb) (num? (any (car Path)))) 
        'u 
        (if (= "del" (car Path) 'd NIL))))))

(de process (Verb Path QS Post Creds)
  (default Path (confv '(default_path))) 
  (setq RR (++ Path))  #RR = Requested Resource
  (setq Cls (or (isa '+Rest (intern (to_cls_nm RR) (intern (confv '(ns))))) NIL))
  (setq Eid (any (car Path)))
  (when Creds (setq User (authn Creds)))
  (ifn Cls
    (if (setq R (get (cls> User) (intern RR))) 
      (list> R User )
      (404))
    (if (need_auth> Cls Verb Path)
      (ifn User
        (401)
        (if (num? Eid)
          (let (Obj (db 'id Cls Eid))
            (ifn Obj
              (404)
              ( ifn (may (req_action Verb Path) User Obj)
                (403)
                (send (any (pack "rest_" Verb ">")) Obj Path QS Post User))))
          (ifn (may (req_action Verb Path) User Cls)
            (403)
            (send (any (pack "rest_" Verb ">")) Cls Path QS Post User))))
      (send (any (pack "rest_" Verb ">")) Cls Path QS Post User))))  #send user even though auth not required; could be logged in anyway.

(de may (Act User E R) 
  (ifn R 
    (member Act (perms> E User))
    (member Act  (perms> (or (get E R) (meta E R)) User)))) 


(pool (confv '(pool)))


