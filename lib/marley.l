(setq *READ 2 *WRITE 1)

(load "lib/util.l")
(load "lib/server.l")
(load "config.l")
(load "lib/er_mods.l")


(load (pack (confv '(client)) "/client.l"))

(de authn (Creds)
  (let (Cls (intern "+User" (intern (confv '(ns)))))
    (setq User (db 'eml Cls (car Creds))))
    (and User (= (pw_hash (cdr Creds) (get User 'salt)) (get User 'pw)) User)) #User needs to show up twice to prevent error and return User.


(de process (Verb Path Qs Post Creds)
  (default Path (confv '(default_path))) 
  (setq Cls (or (isa '+Rest (intern (to_cls_nm (++ Path)) (intern (confv '(ns))))) NIL))
  (setq Eid (any (car Path)))
  (when Creds (setq User (authn Creds)))
  (ifn Cls
    (404)
    (if (need_auth> Cls Verb Path)
      (ifn User
        (401)
        (if (num? Eid)
          (let (Obj (db 'id Cls Eid))
            (ifn Obj
              (404)
              (ifn (authz> Obj Verb Path Qs Post User)
                (403)
                (send (any (pack "rest_" Verb ">")) Obj Path Qs Post User))))
          ( ifn (authz> Cls Verb Path Qs Post User)
            (403)
            (send (any (pack "rest_" Verb ">")) Cls Path Qs Post User))))
      (send (any (pack "rest_" Verb ">")) Cls Path Qs Post User))))  #send user even though auth not required; could be logged in anyway.

(de may (User Act E R) 
  (ifn R 
    (member Act (perms> E User))
    (member Act ((role_pos> E User) (perms> E User)))))


(pool (confv '(pool)))


