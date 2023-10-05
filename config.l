(setq *CONFIG
  '(
    (client . "jamaica")
    (title . "Change This Title in config.l")
    (pool . "DB")
    (ns . "entities")
    (default_path . (client))
    (static_dir . "static/")
    (no_authn . 
      (
        (get . (("user" "new") "" ("app.js") ("reggae.js") ("jamaica.js")))
        (post . ((user)))
      )
    )
  )
)
