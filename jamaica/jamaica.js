
const NEW=1;
const SRCH=2;

const {div, p, a, span, pre, form, label, input, textarea, button, submit} = van.tags;
const labels={
  nm: "Name",
  desc: "Description",
  pw: "Password",
  addr: "Address",
  eml: "Email",
  max_grp: "Max Group"
}

function init() {
  u('a').handle ('click', navclick)
  u('#login').handle('click',login);
  u('#logout').handle('click',logout)
}

function login(e){
  e.preventDefault();
  fetch('/?nav', { headers: {'Authorization': 'Basic ' + getCreds()}})
    .then((res) => res.text())
    .then((html) => {u('#nav').html(html);u('#nav a').handle('click', navclick)})
    .catch((err) => console.error("error:", err));
}

function logout(e){

}

function getCreds() {
  return btoa(val('eml') + ":" + val('pw'));
}

function val(name) {
  return u('[name='+name+']').nodes[0].value;
}

function req(url, meth, body) {
  if (! meth) {meth="get"}
  return fetch(url, {method: meth, headers: {'Authorization': 'Basic ' + getCreds()}})
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


window.onload=init;

