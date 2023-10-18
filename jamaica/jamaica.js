
const NEW=1;
const SRCH=2;

const {div, p, a, span, pre, form, label, input, textarea, button, submit} = van.tags;
const labels={
  nm: "Name",
  pw: "Password",
  addr: "Address",
  eml: "Email",
}

function init() {
  u('#nav a').handle ('click', navclick)
  u('#creds').handle('submit',login);
}

function login(e){
  e.preventDefault();
  fetch('/', { headers: {method: "POST",'Authorization': 'Basic ' + getCreds()}}).then((res) => res.text()).then((text) => {u('html').html(text);init()});
}

function getCreds() {
  return btoa(val('eml') + ":" + val('pw'));
}

function val(name) {
  return u('[name='+name+']').nodes[0].value;
}

function req(url, meth, body) {
  if (! meth) {meth="get"}
  return fetch(url, {method: meth, headers: {'Authorization': 'Basic ' + btoa(val('eml') + ":" + val('pw'))}})
    .then((res) => res.json())
}

function navclick(e) {
  req(e.target.href)
    .then((json) => show('#main', json))
    .catch((err) => console.error("error:", err));
}

function show(target, json) {
  u(target).empty().append(reggae2dom(json));
  u('#main form').on('submit', formSubmit);
}

function processResponse(json) {
  if (json[0] == "error") {
    showError(json);
  } else {
    show('#main', json);
  }
}

function showError(json) {
  json.shift();
  for (var e of json) {
    u('[name=' + e[0] + ']').addClass('error').after(span({class: "err_msg"}, e[1]));
  }
}

function formSubmit(e) {
  e.preventDefault();
  fetch(e.target.action, {method: "POST", body: u(e.target).serialize()}).
    then((res) => res.json()).
    then((json) => processResponse(json)).
    catch((err) => console.error("error:", err));
}

function reggae2dom(json) {
  if (typeof(json[0])=="string") {
    return (Reggae[json[0]](json));
  } else {
    return json.map((m) => Reggae[m[0]](m));
  }
}
const Reggae={
  instance: (json) => {
    var spec=json[1];
    var url=spec[0];
    var srch=false;
    var method= (srch ? "get" : "post");
    var fields=spec[1].map((s) => {return new Field(s).dom()});
    return form({action: url, method: method}, fields, input({type:"submit", value: (srch ? "Search" : "Save")}));

  },
  mesg: (title, content) => {
    return "asdf";
  },
  url: (json) => {
    return a({href: json[1]}, json[2]);
  }
}


function Field (spec) {
  this.name=spec[0];
  this.type=spec[1].replace('bool', 'checkbox'); //yes, facepalm :/
  this.restrictions=spec[2];
}

Field.prototype.dom=function() {
  if (this[this.type]){
    return this[this.type]();
  } else {
    return this.default();
  }
}

Field.prototype.default=function() {
  return [label({for: this.name}, labels[this.name] + ":"), input({type: this.type, name: this.name})]
}
Field.prototype.password=function() {
  return [this.default(), [label({for: "confirmpw"}, "Confirm Password:"), input({type: this.type, name: "confirmpw"})]];
}


window.onload=init;

