
const NEW=1;
const SRCH=2;

const {div, p, pre, form, label, input, textarea, button, submit} = van.tags;
function init() {
  u('#account_nav a').handle ('click', navclick)
}


function navclick(e) {
  fetch(e.target.href)
    .then((res) => res.json())
    .then((json) => show('#main', json))
    .catch((err) => console.error("error:", err));
}

function show(target, json) {
  u(target).html(Reggae[json[0]](json));

}
const Reggae={
  instance: (json) => {
    var spec=json[1];
    var newrec=spec[0] & NEW;
    var srch=spec[0] & SRCH;
    var url=spec[1]
    var fields=spec[2].map((s) => {return field(s)});
    return form({action: url}, fields);

  },
  mesg: (title, content) => {
    return "asdf";
  }
}


function field (spec) {
  var name=spec[0];
  var type=spec[1].replace('bool', 'checkbox'); //yes, facepalm :/
  var restrictions=spec[2];
  return [label({for: name}, name + ":"), input({type: type, name: name})]
}



