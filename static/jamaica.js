

const {div, p, pre, form, label, input, textarea, button, submit} = van.tags;
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
  this.type=spec[1].replace('bool', 'checkbox'); //god I hate this fucking line so fucking much!
  this.restrictions=spec[2];
  this.dom=() => {
    return [label({for: this.name}, this.name + ":"), input({type: this.type, name: this.name})]
  }
}

