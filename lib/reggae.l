
(de reggae (Args)
  (glue "," (split (replace (chop (str Args) " ") "(" "[" ")" "]") " ")))
