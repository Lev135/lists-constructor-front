module Latex.LatexEditor exposing (Model, Settings, defaultSettings, Msg, init, update, view)

import Html.Styled as Html exposing(Html, Attribute)
import Html.Styled.Attributes as Attr
import Html.Styled.Events as Ev

import Json.Decode as JD

-- MODEL

type alias Settings = {
  }

defaultSettings : Settings
defaultSettings = {
  }

type alias Model = {
    text : String,
    settings : Settings
  }

init : Settings -> Model
init settings = {
    text =  "",
    settings = settings
  }

-- UPDATE

type Msg = 
  TextChanged String

update : Msg -> Model -> (Model, Cmd Msg)
update msg model = case msg of
  TextChanged str -> ({model | text = str }, Cmd.none)

-- VIEW
view : String -> Model -> Html Msg
view id model =
  Html.div [Attr.class "latex-editor"] [
    viewEditor id,
    viewPreview model
  ]

viewEditor : String -> Html Msg
viewEditor id = 
  Html.div [][
    latexArea [
      Attr.class "latex-editor-input",
      Attr.id id,
      onTextChanged TextChanged
    ] []
  ]

viewPreview : Model -> Html Msg
viewPreview model =
  Html.div [
    Attr.class "latex-editor-preview"
  ] [
    Html.p [] [
      Html.text "Здесь будет предпросмотр скомпилированных блоков, когда я разберусь с парсером TeX'a."
    ],
    Html.p [] [
      Html.text <| "Вы ввели: " ++ model.text
    ]
  ]

-- CUSTOM HTML

latexArea : List (Attribute msg) -> List (Html msg) -> Html msg
latexArea =
    Html.node "latex-area"

onTextChanged : (String -> msg) -> Attribute msg
onTextChanged tagger = 
  Ev.on "textChanged" <| JD.map tagger (JD.field "detail" JD.string)
