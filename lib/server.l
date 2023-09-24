(load "lib/util.l")
#(symbols 'serv 'util 'pico)

(setq *Port 4200)
(setq P (port *Port))
(setq *Char64 `'(chop "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/" ) )
(de decode64 (S)
   (let S (chop S)
      (pack
         (make
            (while S
               (let
                  (A (dec (index (++ S) *Char64))
                     B (dec (index (++ S) *Char64))
                     C (dec (index (++ S) *Char64))
                     D (dec (index (++ S) *Char64)) )
                  (link
                     (char (| (>> -2 A) (>> 4 B))) )
                  (and
                     C
                     (link
                        (char
                           (| (>> -4 (& B 15)) (>> 2 C)) ) )
                     D
                     (link
                        (char (| (>> -6 (& C 3)) D)) ) ) ) ) ) ) ) )
(de url_dec (S) 
  (let (s (split (replace S "+" " ") '%))
    (pack 
      (cons 
        (car s)
        (mapcar '((s)
          (cons (char (hex (pack (head 2 s)))) (nth s 3))
        ) (cdr s))
      )
    )
  )
)

(de parse_qs (Qs)
  (mapcar '((Pr) 
    (let  (Kv (split Pr "="))
      (cons (url_dec (car Kv)) (url_dec (cadr Kv))) 
    ) ) (split Qs '&)
  )
)

(de respond (Stat Body Ty)
  (case Stat
    (200 (out *Sock (prinl "HTTP/1.1 200 OK\n" "Server: Marley\n" "Content-Type: text/html; charset=UTF-8\n\n"  Body)))
    (401 (out *Sock (prinl "HTTP/1.1 401 Unauthorized\n" "WWW-Authenticate: Basic realm=\"Please Log In\"\n")))
    (403 (out *Sock (prinl "HTTP/1.1 403 Forbidden\n" )))
    (404 (out *Sock (prinl "HTTP/1.1 404 Not Found\n" )))
  )
)


(de start (Authenticator Processor)
  (loop
    (setq *Sock (listen P))
    (setq Req (make (while (in *Sock (line T)) (link @))))
    (let (Vp (sc (car Req) " "))
      (setq Verb (lowc (pack (car Vp))))
      (let Pq (split (cadr Vp) "?")
        (setq Path (mapcar 'pack (split (cdar Pq) "/")))
        (setq Qs (parse_qs (cdr Pq)))
      )
    )
    (setq Headers (mapcar '((H) (let (F (sc H ":")) (cons (pack (car F)) (pack (cdr F))))) (cdr Req)))
    (when (setq Len (format (cdr (assoc "Content-Length" Headers))))
      (setq Post (parse_qs (in *Sock (make (do (- Len 1) (link (char)))))))
    )

    (if (or (= NIL Path ) (member Path (conf (append (list Verb) '(no_authn)))))
      (Processor Verb Path Qs Post User)
      (if (setq Unpw (pack (tail 1 (sc (cdr (assoc "Authorization" Headers)) " "))))
        (if (Authenticator (mapcar 'pack (sc (decode64 Unpw) ":")))
          (Processor Verb Path Qs Post User)
          (respond 401)
        )
        (respond 401)
      )
    )
    ( close *Sock) 
  )
)
