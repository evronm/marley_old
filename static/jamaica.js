

const {div, p, pre, form, input, textarea, button, submit} = van.tags;
function init() {
  u('#account_nav a').handle ('click', navclick)
}

function reggae(resp) {
  foo=resp.json()
}

function navclick(e) {
  fetch(e.target.href)
    .then((res) => res.json())
    .then((json) => console.log(json))
    .catch((err) => console.error("error:", err));


}
