
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
  return [label({for: this.name}, (labels[this.name] ? labels[this.name] : this.name) + ":"), input({type: this.type, name: this.name})]
}
Field.prototype.password=function() {
  return [this.default(), [label({for: "confirmpw"}, "Confirm Password:"), input({type: this.type, name: "confirmpw"})]];
}

