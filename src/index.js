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
  mode : "stex",
  lineNumbers : true
}
// CodeMirror.fromTextArea(document.getElementById("Statement"), cmOptions);

app.ports.createEditor.subscribe(id => {
  setTimeout(() => {
    const cm = CodeMirror.fromTextArea(document.getElementById(getEditorName(id)), cmOptions)
    cm.setSize(null, 100)
    cm.on("change", () => {
      app.ports.onEdited.send(JSON.stringify({id, msg : cm.getValue()}));
    })
  }, 10)
})

function getEditorName(id) {
  return "latex-editor-input-" + id;
}
/*
function getOuputName(id) {
  return "latex-editor-output-" + id;
}
*/
