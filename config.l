(setq *CONFIG
  '(
    (pool . "DB")
    (ns . "entities")
    (default_path . "index.html")
    (static_dir . "static/")
    (no_authn . 
      (
        (get . ((user new) "" "app.js"))
        (post . ((user)))
      )
    )
  )
)
