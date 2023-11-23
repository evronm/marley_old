
function reggae2dom(json) {
  if (typeof(json)=="object") {
    if (typeof(json[0])=="string") {
      return (Reggae[json.shift()](json));
    } else {
      return json.map((m) => Reggae[m[0]](m));
    }
  } else {
    return json
  }
}

const Reggae={
  instance: (json) => {
    var url=json[0][0];
    try {var [foo, typ, eid] = url.match(/\/(.+)\/(.+)\//);} catch (e) {}
    var flags=json[0][1];
    var vals=json[1] || [];
    var srch=false;  //change to implement search
    var method= (srch ? "get" : "post");
    var fields=json[0][2].map((s,i) => {return new Field(s, vals[i+1]).dom()});
    if (flags=="ro"){
      return div({class:typ, id:eid}, fields);
    } else {
      return form({action: url, method: method}, fields, input({type:"submit", value: (srch ? "Search" : "Save")}));
    }

  },
  instances: (json) => {return new Table(json).dom()},
  mesg: (title, content) => {
    return "asdf";
  },
  url: (json) => {
    return a({href: json[1]}, json[2]);
  }
}


function Field (spec, val) {
  this.name=spec[0];
  this.type=spec[1].replace('bool', 'checkbox'); //yes, facepalm :/
  this.restrictions=spec[2];
  this.val=val;
}

Field.prototype.dom=function() {
  if (this.restrictions.indexOf("ro")>-1) {
    return this.ro();
  }
  if (this[this.type]){
    return this[this.type]();
  } else {
    return this.default();
  }
}

Field.prototype.default=function() {
  return [label({for: this.name}, (labels[this.name] ? labels[this.name] : this.name) + ":"), input({type: this.type, name: this.val})]
}
Field.prototype.password=function() {
  return [this.default(), [label({for: "confirmpw"}, "Confirm Password:"), input({type: this.type, name: "confirmpw"})]];
}

Field.prototype.ro=function() {
  return [label({for: this.name}, (labels[this.name] ? labels[this.name] : this.name) + ":"), span({class: "ro"}, this.val)];
}

function Table(json) {
  this.url=json[0][0];
  this.flags=json[0][1];
  this.spec=json[0][2];
  this.data=json[1];
}
Table.prototype.dom=function() {
  return table(
    thead(tr( this.spec.map ((s) => th({class: s[1]}, s[0]) ))),
    tbody(this.data.map((r) => tr({"eid": r.shift()}, r.map((f) => td(reggae2dom (f)))))));
}
