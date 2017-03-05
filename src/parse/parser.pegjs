Program
  = c:Statement* _? {return {node:"?program", args:c};}

Statement
  /*Statements are the core top rule*/
  =   _? a:Assign {return a;}
  / _? d:Def {return d;}
  / _? i:If {return i;}
  / _? f:For {return f;}
  / _? g:Gen {return g;}
  / _? l:Loop {return l;}
  / _? c:Call {return c;}
  / _? r:Return {return r;}

Call
  /*Can Parse Function Calls*/
  = node:[a-zA-Z!><=/+%*_@$-]+ "(" _ args:Operands _ ")" {
     return {node:node.join(""), args:args};
  }
  / method:Attribute "(" _ args:Operands _ ")" {
     return {node:"?method", args:[method].concat(args)};
  }

Def
  = "def" _ n:Name _ "(" _ params:Params _ ")" _ b:Body _ "_" {
     return {node:"?=", args:[n, {node:"?func", args:[params, b]}]};
  }


Gen
  = "gen" _ n:Name _ b:Body _ "call" _ c:Body _ "_" {
     return {node:"?=", args:[n, {node:"?gen", args:[b, c]}]};
  }

Return
  = "return" _ a:Argument _ {
    return {node:"?return", args:[a]};
  }

If
  = "if" _ c:Argument _ b:Body _ "_" {
    return {node:"?if", args:[c, b]};
  }

For
  = "for" _ v:Name _ "in" _ a:Argument _ b:Body _ "_" {
     return {node:"?for", args:[v, a, b]};
  }

Loop
  = "loop" _ c:Argument _ b:Body _ "_" {
     return {node:"?loop", args:[c, b]};
  }

Assign
  =  _? v:Name _? "=" _? val:Argument {return {node:"?=", args:[v, val]};}
  / _? v:Attribute _? "=" _? val:Argument {return {node:"?=>", args:[v, val]};}

List
  = "[" _ args:Operands _ "]" {
    return {node:"?list", args:args};
  }
  / "[" _ args:Pair* _ "]" {
    return {node:"?map", args:args};
  }
  / "[:]" {return {node:"?map", args:[]};}

Pair
  = _ arg1:Word ":" arg2:Argument _ {
    return {node:"?pair", args:[arg1, arg2]};
  }

Attribute
  = obj:Name "." attr:Word {return {node:"?.", args:[obj, attr]};}

Lambda
  = "lambda " "(" p:Params ")" " -> " b:Argument " "* "\n"* {
     return {node:"?func", args:[p, {node:"?params", args:[{node:"?return", args:[b]}]}]};
  }

Operands
  = Argument*

Params
  = p:Name* {return {node:"?params", args:p};}

Body
  = s:Statement* {return {node:"?body", args:s};}

Process
  = "~{" _ proc:Body _ "}" {return {node:"?process", args:[proc]}}

Argument
  = _? c:Call {return c;}
  / _? f:Lambda {return f;}
  / _? p:Process {return p;}
  / _? l:List {return l;}
  / _? s:String {return s;}
  / _? a:Attribute {return a;}
  / _? a:Word {return a;}

_ "whitespace"
  = [ \t\n\r,]*

Name
  = _? n:[a-zA-Z_@$-]+ {return {node:"?name", args:[n.join("")]};}


Word
  =  w:[a-z0-9A-Z-_$@]+ {
      var result = w.join("");
      var imdict = {'true':['?bool', true], 'false':['?bool', false], 'null':['?null', null]};
      if(result in imdict) {return {node:imdict[result][0], args:[imdict[result][1]]}}
      else if(isNaN(result)) {return {node:"?word", args:[result]};}
      else return {node:"?number", args:[result]};
  }

String
  = '"' s:[^"]* '"' {return {node:"?string", args:[s.join("")]};}



