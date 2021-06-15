port module LatexList exposing (Model, Msg, init, update, view, subscriptions)

import Array as A exposing (Array)
import Array.Extra as A

import Html.Styled as Html exposing(Html)
import Html.Styled.Events as Ev

import Json.Decode as JD


import LatexEditor as Editor

-- MODEL

type alias Model = {
    editors : Array Editor.Model
  }

init : () -> (Model, Cmd a)
init _ = ({ editors = A.empty }, Cmd.none)

-- UPDATE
type Msg = AddEditor
         | EditorMsg Int Editor.Msg
         | EditorSubMsgReceived String

update : Msg -> Model -> (Model, Cmd Msg)
update msg model = case msg of
    EditorMsg i eMsg         -> updateEditor model i eMsg
    AddEditor                -> addEditor model
    EditorSubMsgReceived sub -> sendSubMsg model sub

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
addEditor model = let (editor, eCmd) = Editor.init (String.fromInt << A.length <| model.editors) createEditor
                  in  (
                        { model | editors = A.push editor model.editors }, 
                        Cmd.map (EditorMsg <| A.length model.editors - 1) eCmd
                    )

sendSubMsg : Model -> String -> (Model, Cmd Msg)
sendSubMsg model str = case JD.decodeString editorSubMsgDecoder str of
  Ok   (EditorSubMsg si msg) -> case String.toInt si of 
          Just i  -> update (EditorMsg i msg) model
          Nothing -> Debug.log("Parse command error: " ++ str) (model, Cmd.none) 
  Err  _                    -> Debug.log ("Parse command error: " ++ str) (model, Cmd.none)

-- VIEW

view : Model -> Html Msg
view model = Html.div [] [
    Html.div [] 
      (A.toList <| A.indexedMap editorView model.editors),
    Html.button [ Ev.onClick AddEditor ] [ Html.text "Добавить редактор" ]
  ]
  
editorView : Int -> Editor.Model -> Html Msg
editorView i = Html.map (EditorMsg i) << Editor.view

-- SUBSCRIPTIONS

subscriptions : Model -> Sub Msg
subscriptions _ = onEdited EditorSubMsgReceived

type EditorSubMsg = EditorSubMsg String Editor.Msg 

editorSubMsgDecoder : JD.Decoder EditorSubMsg
editorSubMsgDecoder = 
  JD.map2 EditorSubMsg
    (JD.field "id"   JD.string)
    (JD.field "msg"  Editor.subMsgDecoder)

-- PORTS
port createEditor : String -> Cmd msg
port onEdited : (String -> msg) -> Sub msg
