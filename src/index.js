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

// Веб-компонента для редактора LaTeX
customElements.define('latex-area',
    class extends HTMLElement {
        constructor() { 
          super();
        }
        connectedCallback() {
          const cm = CodeMirror(elt => {
            this.appendChild(elt);
          }, cmOptions)
          cm.on('change', () => {
            this.dispatchEvent(textChanged(cm.getValue()))
          })
        }
        attributeChangedCallback() {  }
        static get observedAttributes() { return []; }
    }
);

// Custom'ное событие веб-компоненты 
function textChanged(text) {
  return new CustomEvent('textChanged', {
    detail : text
  })
}