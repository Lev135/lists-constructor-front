module Latex.LatexList exposing (Model, Msg(..), init, update, view, subscriptions)

import Html.Styled as Html exposing(Html)
import Html.Styled.Events as Ev
import Html.Styled.Attributes as Attr

import Latex.LatexEditor as Editor

import Array as A exposing (Array)
import Array.Extra as A

import Accessibility.Key as AccessKey

-- MODEL

type alias Settings = {
    editor : Editor.Settings
  }

type alias Model = {
    editors : Array Editor.Model,
    settings : Settings
  }


init : Settings -> Int -> Model
init settings count = {
    editors  = A.repeat count <| Editor.init settings.editor, 
    settings = settings
  }

-- UPDATE
type Msg = AddEditor
         | RemoveEditor Int
         | EditorMsg Int Editor.Msg

update : Msg -> Model -> (Model, Cmd Msg)
update msg model = case msg of
    EditorMsg i eMsg         -> updateEditor model i eMsg
    AddEditor                -> addEditor model
    RemoveEditor i           -> removeEditor model i

updateEditor : Model -> Int -> Editor.Msg -> (Model, Cmd Msg)
updateEditor model i eMsg = case A.get i model.editors of
  Just editor ->  let (editor1, eCmd) = Editor.update eMsg editor 
                  in  (
                        { model | editors = A.set i editor1 model.editors }, 
                        Cmd.map (EditorMsg i) eCmd
                    )
  Nothing     ->  Debug.log  ("Incorrect editor index : " ++ String.fromInt i)
                  (model, Cmd.none)

addEditor : Model -> (Model, Cmd Msg)
addEditor model = ({ model | editors = A.push (Editor.init model.settings.editor) model.editors }, Cmd.none)

removeEditor : Model -> Int -> (Model, Cmd Msg)
removeEditor model i = ({model | editors = A.removeAt i model.editors}, Cmd.none)

-- VIEW

view : Model -> Html Msg
view model =  if A.length model.editors == 0
              then
                Html.label [ Attr.class "row" ] [Html.text "(пока что их нет)"]
              else
                if A.length model.editors == 1
                then case A.get 0 model.editors of
                  (Just editor) -> addRemoveButton 0 <| editorView 0 editor
                  Nothing       -> Html.div [] []
                else viewImpl model.editors

viewImpl : Array Editor.Model -> Html Msg
viewImpl = Html.div [] << A.toList << A.map (\m -> Html.fieldset[][m]) << A.indexedMap addRemoveButton << A.indexedMap editorView

addRemoveButton : Int -> Html Msg -> Html Msg
addRemoveButton i m = Html.div [ Attr.class "row" ] [
    Html.button [
        Attr.class "remove-button",
        Ev.onClick <| RemoveEditor i,
        Attr.fromUnstyled <| AccessKey.tabbable False 
      ] [ Html.text "X"],
    Html.div [ Attr.class "removable-block" ] [m]
  ]

editorView : Int -> Editor.Model -> Html Msg
editorView i = Html.map (EditorMsg i) << Editor.view

-- SUBSCRIPTIONS

subscriptions : Model -> Sub Msg
subscriptions _ = Sub.none
