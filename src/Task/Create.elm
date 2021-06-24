module Task.Create exposing (Settings, defaultSettings, Model, init, Msg(..), update, view, subscriptions)

import Html.Styled as Html exposing(Html)
import Html.Styled.Attributes as Attr
import Html.Styled.Events as Ev

import Latex.LatexEditor as Editor

import Array as A exposing (Array)
import Task

import Utils.ListEditor as ListEditor
import Task.CreateRemark as Remark

import Json.Encode as JE
import Utils.Json.Encode.Extra as JE
import Json.Decode as JD

-- MODEL

type alias Settings = {
    editor : Editor.Settings
  }

defaultSettings : Settings
defaultSettings = {
    editor = Editor.defaultSettings
  }

remarkListInfo : ListEditor.Info Remark.Model Remark.Msg
remarkListInfo = {
    contId      = "remarks",
    initVal     = Remark.defaultModel,
    updateFunc  = Remark.update,
    viewFunc    = Remark.view,
    elName      = "примечание"
  }

solutionListInfo : Editor.Settings -> ListEditor.Info Editor.Model Editor.Msg
solutionListInfo settings = {
    contId        = "solutions",
    initVal       = Editor.init settings,
    updateFunc    = Editor.update,
    viewFunc      = Editor.view,
    elName        = "решение"
  }

type alias Uuid = String

type Status
  = Editing
  | Saving
  | Saved

type alias Model = {
    uuid      : Maybe Uuid,
    
    statement : Editor.Model,
    answer    : Editor.Model,
    solutions : Array Editor.Model,
    remarks   : Array Remark.Model,

    settings    : Settings,
    sendMsg     : String -> Cmd Msg,
    msgReceiver : (String -> Msg) -> Sub Msg,
    status      : Status
  }

init : Settings -> (String -> Cmd Msg) -> ((String -> Msg) -> Sub Msg) -> Model
init settings sendMsg msgReceiver = {
    uuid        = Nothing,
    statement   = Editor.init settings.editor,
    answer      = Editor.init settings.editor,
    solutions   = ListEditor.init (solutionListInfo settings.editor) 1,
    remarks     = ListEditor.init remarkListInfo 0,
    settings    = settings,
    sendMsg     = sendMsg,
    msgReceiver = msgReceiver,
    status      = Editing
  } 

-- UPDATE

type Msg
  = UpdateStatement Editor.Msg
  | UpdateAnswer    Editor.Msg
  | SolutionListMsg (ListEditor.Msg Editor.Msg)
  | RemarkListMsg   (ListEditor.Msg Remark.Msg)
  | SaveRough
  | RoughSaved      Uuid

update : Msg -> Model -> (Model, Cmd Msg)
update msg model = case msg of
  (UpdateStatement eMsg)   -> updateStatement eMsg model
  (UpdateAnswer    eMsg)   -> updateAnswer eMsg model
  (SolutionListMsg slMsg)  -> updateSolutions slMsg model
  (RemarkListMsg  rlMsg)   -> updateRemarks rlMsg model 
  SaveRough                -> saveRough model
  (RoughSaved uuid)        -> ({ model | uuid = Just uuid, status = Saved }, Cmd.none)
  

updateStatement : Editor.Msg -> Model -> (Model, Cmd Msg)
updateStatement eMsg model
  = let (editor1, eMsg1) = Editor.update eMsg model.statement
    in  ({ model | statement = editor1, status = Editing }, Cmd.map UpdateStatement eMsg1)

updateAnswer : Editor.Msg -> Model -> (Model, Cmd Msg)
updateAnswer eMsg model
  = let (editor1, eMsg1) = Editor.update eMsg model.answer
    in  ({ model | answer = editor1, status = Editing }, Cmd.map UpdateAnswer eMsg1)

updateSolutions : ListEditor.Msg Editor.Msg -> Model -> (Model, Cmd Msg)
updateSolutions lsMsg model
  = let (list1, lMsg1) = ListEditor.update (solutionListInfo model.settings.editor) lsMsg model.solutions
    in ({ model | solutions = list1, status = Editing }, Cmd.map SolutionListMsg lMsg1)

updateRemarks : ListEditor.Msg Remark.Msg -> Model -> (Model, Cmd Msg)
updateRemarks msg model 
  = let (list1, lMsg1) = ListEditor.update remarkListInfo msg model.remarks
    in ({ model | remarks = list1, status = Editing }, Cmd.map RemarkListMsg lMsg1)

-- VIEW

view : Model -> Html Msg
view model = Html.div [ Attr.class "form" ] [
    Html.div [ Attr.class "form-elem" ] [
      Html.label [ Attr.class "form-label" ] [
        Html.text "Условие"
      ],
      Html.map UpdateStatement <| Editor.view "statement" model.statement
    ],
    Html.div [ Attr.class "form-elem" ] [
      Html.label [ Attr.class "form-label" ] [
        Html.text "Ответ"
      ],
      Html.map UpdateAnswer <| Editor.view "answer" model.answer
    ],
    Html.div [ Attr.class "form-elem" ] [
      Html.label [Attr.class "form-label" ] [
        Html.text "Решения"
      ],
      Html.map SolutionListMsg <| ListEditor.view (solutionListInfo model.settings.editor) model.solutions
    ],
    Html.div [ Attr.class "form-elem" ] [
      Html.label [ Attr.class "form-label" ] [
        Html.text "Примечания"
      ],
      Html.map RemarkListMsg <| ListEditor.view remarkListInfo model.remarks
    ],
    Html.div [ Attr.class "form-buttons" ] [
      Html.button [ 
        Attr.class "form-buttons-button",
        Ev.onClick SaveRough,
        Attr.disabled <| model.status /= Editing
      ] [ Html.text "Сохранить черновик" ]
    ]
  ]

-- SUBSCRIPTIONS

subscriptions : Model -> Sub Msg
subscriptions m = case m.status of
   Saving -> m.msgReceiver (\uuid -> RoughSaved uuid)
   _      -> Sub.none

-- HTTP

encodeSolutionPost : Editor.Model -> JE.Value
encodeSolutionPost m = JE.object [
    ("body" , JE.string m.text),
    ("grade", JE.int 0)
  ]
encodeRemarkPost : Remark.Model -> JE.Value
encodeRemarkPost m = JE.object [
    ("type" , JE.string m.typeR),
    ("label", JE.string m.label),
    ("body" , JE.string m.body )
  ]
encodeRoughPost : Model -> JE.Value
encodeRoughPost m = JE.object [
    ("uuid"     , JE.maybeNull JE.string      m.uuid),
    ("statement", JE.string m.statement.text),
    ("answer"   , JE.string m.answer.text),
    ("solutions", JE.array encodeSolutionPost m.solutions),
    ("remarks"  , JE.array encodeRemarkPost   m.remarks  )
  ]

saveRough : Model -> (Model, Cmd Msg)
saveRough m = ({ m | status = Saving }, m.sendMsg <| JE.encode 0 <| encodeRoughPost m)
