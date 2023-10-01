(setq *CONFIG
  '(
    (pool . "DB")
    (ns . "entities")
    (default_path . "index.html")
    (static_dir . "static/")
    (no_authn . 
      (
        (get . (("users" "new") "" ("app.js") ("reggae.js") ("jamaica.js")))
        (post . ((user)))
      )
    )
  )
)
