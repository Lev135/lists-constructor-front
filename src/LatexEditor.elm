port module LatexEditor exposing (Model, Msg, init, update, view, subscriptions)

import Html.Styled as Html exposing(Html)
import Html.Styled.Attributes as Attr
import Html.Styled.Events as Ev

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
    id   : String,
    text : String,
    settings : Settings
  }

init : String -> () -> (Model, Cmd a)
init id _ = (Model id "" defaultSettings, createEditor id)

-- UPDATE

type Msg = 
  TextChanged String

update : Msg -> Model -> (Model, Cmd Msg)
update msg model = case msg of
  TextChanged str -> ({model | text = str }, Cmd.none)

-- PORTS

port createEditor : String -> Cmd msg
port onEdited : (String -> msg) -> Sub msg

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
    Html.textarea [
      Attr.id <| "latex-editor-input-" ++ model.id
    ] []
  ]

viewPreview : Model -> Html Msg
viewPreview model =
  Html.styled Html.div [
      Css.width << Css.pc <| model.settings.previewWidth * 0.90
    ] [
    Attr.class "latex-editor-preview",
    Attr.id <| "latex-editor-preview-" ++ model.id 
  ] [
    Html.text "Здесь будет предпросмотр скомпилированных блоков, когда я разберусь с парсером TeX'a"
  ]

-- SUBSCRIPTIONS

subscriptions : Model -> Sub Msg
subscriptions _ = onEdited TextChanged 

