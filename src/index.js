import { Elm } from "./Main.elm";

// CodeMirror для подсветки синтаксиса
import CodeMirror from "codemirror"
import "codemirror/mode/stex/stex"
import "codemirror/addon/hint/show-hint";

// Helper для работы с TeXом. Почему-то не работает
import {LaTeXHint} from "codemirror-latex-hint";
import macros from "codemirror-latex-hint/lib/macros.json";

CodeMirror.registerHelper("hint", "stex", (cm) => LaTeXHint(cm, macros));  

// Инициализизация Elm приложения
app = Elm.Main.init({ node: document.getElementById("root") });

// Настройки CodeMirror
cmOptions = {
  mode : "stex",
  lineNumbers : true
}

// Порт для инициализации CodeMirror на texterea по id 
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
