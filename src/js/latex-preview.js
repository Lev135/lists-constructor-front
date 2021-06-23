MathJax = {
  tex: {
    inlineMath: [['$', '$']]
  }
};

let mathJaxLoaded = false;

let script = document.createElement('script');
script.src = "https://cdn.jsdelivr.net/npm/mathjax@3/es5/tex-chtml.js"
document.head.append(script);
script.onload = function() {
  mathJaxLoaded = true;
};

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
