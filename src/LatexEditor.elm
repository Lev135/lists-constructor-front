module LatexEditor exposing (Model, Msg, init, update, view)

import Html.Styled as Html exposing(Html, Attribute)
import Html.Styled.Attributes as Attr
import Html.Styled.Events as Ev

import Json.Decode as JD

import Css
-- MODEL

type alias Settings = {
    previewWidth : Float
  }

defaultSettings : Settings
defaultSettings = {
    previewWidth = 40
  }

type alias Model = {
    text : String,
    settings : Settings
  }

init : Model
init = {
    text =  "",
    settings = defaultSettings
  }

-- UPDATE

type Msg = 
  TextChanged String

update : Msg -> Model -> (Model, Cmd Msg)
update msg model = case msg of
  TextChanged str -> ({model | text = str }, Cmd.none)

-- VIEW
view : Model -> Html Msg
view model =
  Html.div [Attr.class "row"] [
    viewEditor model,
    viewPreview model
  ]

viewEditor : Model -> Html Msg
viewEditor model = 
  Html.styled Html.div [
      Css.width << Css.pc <| (100 - model.settings.previewWidth) * 0.90
    ] [Attr.class "latex-editor-input"][
    latexArea [
      onTextChanged TextChanged
    ] []
  ]

viewPreview : Model -> Html Msg
viewPreview model =
  Html.styled Html.div [
      Css.width << Css.pc <| model.settings.previewWidth * 0.90
    ] [
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
