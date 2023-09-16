

const {div, p, pre, form, input, textarea, button, submit} = van.tags;
function init() {
  u('#account_nav a').handle ('click', navclick)
}


function navclick(e) {
  fetch(e.target.href)
    .then((res) => res.json())
    .then((json) => console.log(json))
    .catch((err) => console.error("error:", err));
}

function Field (spec) {
  this.name=spec[0];
  this.type=spec[1];
  this.restrictions=spec[2];
  this.dom=() => {
    return input({type: this.type, name: this.name})
  }
}
