module Latex.LatexList exposing (Model, Msg(..), init, update, view, subscriptions)

import Array as A exposing (Array)
import Array.Extra as A

import Html.Styled as Html exposing(Html)

import Latex.LatexEditor as Editor

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
         | EditorMsg Int Editor.Msg

update : Msg -> Model -> (Model, Cmd Msg)
update msg model = case msg of
    EditorMsg i eMsg         -> updateEditor model i eMsg
    AddEditor                -> addEditor model

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

-- VIEW

view : Model -> Html Msg
view model = Html.div [] [
    Html.div [] 
      (A.toList <| A.indexedMap editorView model.editors)
  ]
  
editorView : Int -> Editor.Model -> Html Msg
editorView i = Html.map (EditorMsg i) << Editor.view

-- SUBSCRIPTIONS

subscriptions : Model -> Sub Msg
subscriptions _ = Sub.none
