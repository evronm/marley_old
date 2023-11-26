
(load "lib/util.l")
(load "lib/server.l")
(load "config.l")
(load "lib/rentity.l")
(load "lib/er_mods.l")


(load (pack (confv '(client)) "/client.l"))

# Authentication.  Creds is a list of (email . password) cons cells.
(de authn (Creds)
  (let (Cls (intern "+User" (intern (confv '(ns)))))
    (setq User (db 'eml Cls (car Creds))))
    (and User (= (pw_hash (cdr Creds) (get User 'salt)) (get User 'pw)) User)) #User needs to show up twice to prevent error and return User.

(de req_action (Verb Path) 
  (if (and (= "get" Verb) (or (num? (any (car Path))) (member (car Path) '("list" "show" NIL))))
    'r
    (if (or (= "new" (car Path) ) (nil? (car Path)))
      'c
      (if (and (= "post" Verb) (num? (any (car Path)))) 
        'u 
        (if (= "del" (car Path) 'd NIL))))))

#This is the default processor that gets sent to the server.
(de process (Verb Path QS Post Creds)  #Verb is the HTTP verb, Path is the path, QS is the query string, Post is the post data, Creds is the credentials.
  (default Path (confv '(default_path))) 
  (let (RR (++ Path)  #RR = Requested Resource
    Cls (or (isa '+Rest (intern (to_cls_nm RR) (intern (confv '(ns))))) NIL)
    Eid (any (car Path))
    User (authn Creds))
      (ifn Cls  #This is kind of syntactic sugar, but it really makes URL's a lot cleaner.
        (if (or (not User) (not (= "get" Verb)))
          (403)
          (rest_get> User (list NIL RR) QS Post User))
        (if (need_auth> Cls Verb Path)
          (ifn User
            (401)
            (if (num? Eid)
              (let (Obj (db 'eid '+REntity Eid))
                (ifn Obj
                  (404)
                  (ifn (may (req_action Verb Path) User Obj)
                    (403)
                    (send (any (pack "rest_" Verb ">")) Obj Path QS Post User))))
              (ifn (may (req_action Verb Path) User Cls)
                (403)
                (send (any (pack "rest_" Verb ">")) Cls Path QS Post User))))
          (if (num? Eid)
            (let (Obj (db 'eid '+REntity Eid))
                (ifn Obj
                  (404)
                  (ifn (may (req_action Verb Path) User Obj)
                    (403)
                    (send (any (pack "rest_" Verb ">")) Obj Path QS Post User))))
            (send (any (pack "rest_" Verb ">")) Cls Path QS Post User))))))  #send user even though auth not required; could be logged in anyway.

#This gets used all over the place.  It is entirely about frontend capabilities.
(de may (Act User E R) 
  (ifn R 
    (member Act (perms> E User))
    (member Act  
      (perms> 
        (if 
          (and (type (get E R)) (not (ext? (get E R))))  #make sure perms are for the relation, not the target entity.
          (get E R) 
          (meta E R)) 
        User E)))) 

(de go ()
  (start process) )

(pool (confv '(pool)))


