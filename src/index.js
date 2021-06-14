import { Elm } from "./Main.elm";


import CodeMirror from "codemirror"
import "codemirror/mode/stex/stex"
import "codemirror/addon/hint/show-hint";


// Почему-то не работает
import {LaTeXHint} from "codemirror-latex-hint";
import macros from "codemirror-latex-hint/lib/macros.json";

CodeMirror.registerHelper("hint", "stex", (cm) => LaTeXHint(cm, macros));  

app = Elm.Main.init({ node: document.getElementById("root") });

cmOptions = {
  mode : "stex"
}
CodeMirror.fromTextArea(document.getElementById("Statement"), cmOptions);
app.ports.sendMessage.subscribe(id => {
  CodeMirror.fromTextArea(document.getElementById(id), cmOptions);      
})
