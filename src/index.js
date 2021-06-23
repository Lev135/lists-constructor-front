import { Elm } from "./Main.elm";

import "./js/latex-area"
import "./js/latex-preview"


// Пакет для работы с ShortCuts
import "elm-keyboard-shortcut"

// Инициализизация Elm приложения
app = Elm.Main.init({ node: document.getElementById("root") });

