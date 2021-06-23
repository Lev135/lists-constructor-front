import { Elm } from "./Main.elm";

// CodeMirror для подсветки синтаксиса
import CodeMirror from "codemirror"
import "codemirror/mode/stex/stex"
import "codemirror/addon/hint/show-hint";

// Helper для работы с TeXом. Почему-то не работает
import {LaTeXHint} from "codemirror-latex-hint";
import macros from "codemirror-latex-hint/lib/macros.json";

CodeMirror.registerHelper("hint", "stex", (cm) => LaTeXHint(cm, macros));  

// Пакет для работы с ShortCuts
import "elm-keyboard-shortcut"

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
          this.tabIndex = -1
          this.onfocus = event => {
            cm.focus()
          }
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

let mathJaxLoaded = false;

loadMathJax();
function loadMathJax () {
  
  let script = document.createElement('script');

  script.src = "https://cdn.jsdelivr.net/npm/mathjax@3/es5/tex-chtml.js"
  document.head.append(script);

  script.onload = function() {
    mathJaxLoaded = true;
  };
}

// Веб-компонента для LatexView
customElements.define('latex-preview',
  class extends HTMLElement {
    rendering = false;
    constructor() {
      super();
      this.rendering = false;
    }
    connectedCallback() {
    }
    attributeChangedCallback() {
      this.render();
    }
    static get observedAttributes() {
      return ['code'];
    }
    async render() {
      if (!mathJaxLoaded || this.rendering)
        return;
      const value = this.getAttribute('code');
      
      this.rendering = true;
      this.innerHTML = value;
      MathJax.texReset();
      try {
        await MathJax.typesetPromise([this]);
        //  Update the document to include the adjusted CSS for the
        //    content of the new equation.
//        MathJax.startup.document.clear();
//        MathJax.startup.document.updateDocument();
      }
      catch(err) {
        this.appendChild(document.createElement('pre')).appendChild(document.createTextNode(err.message));
      }
      this.rendering = false;
    }
  }
)