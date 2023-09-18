
const NEW=1;
const SRCH=2;

const {div, p, pre, form, label, input, textarea, button, submit} = van.tags;
function init() {
  u('#account_nav a').handle ('click', navclick)
}


function navclick(e) {
  fetch(e.target.href)
    .then((res) => res.json())
    .then((json) => foo=json)
    .catch((err) => console.error("error:", err));
}



function Field (spec) {
  this.name=spec[0];
  this.type=spec[1].replace('bool', 'checkbox'); //god I hate this fucking line so fucking much!
  this.restrictions=spec[2];
  this.dom=() => {
    return [label({for: this.name}, this.name + ":"), input({type: this.type, name: this.name})]
  }
  return this;
}

function Instance(spec) {
  this.new=spec[0] & NEW;
  this.srch=spec[0] & SRCH;
  this.url=spec[1]
  this.fields=spec[2].map((s) => {return new Field(s)});
  return this
}

