module Task.Create exposing (Settings, defaultSettings, Model, init, Msg(..), update, view)

import Html.Styled as Html exposing(Html)
import Html.Styled.Events as Ev
import Html.Styled.Attributes as Attr

import Latex.LatexEditor as Editor
import Latex.LatexList as LList

import Array exposing (Array)
import Task

import Shortcut

import Utils.ListEditor as ListEditor
import Task.CreateRemark as Remark

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

type alias Model = {
    statement : Editor.Model,
    answer    : Editor.Model,
    solutions : LList.Model,
    remarks   : Array Remark.Model,

    settings  : Settings
  }

init : Settings -> Model
init settings = {
    statement = Editor.init settings.editor,
    answer    = Editor.init settings.editor,
    solutions = LList.init {editor = settings.editor} 1,
    remarks   = ListEditor.init remarkListInfo 0,
    settings  = settings
  } 

-- UPDATE

type Msg
  = UpdateStatement Editor.Msg
  | UpdateAnswer    Editor.Msg
  | UpdateSolutions LList.Msg
  | RemarkListMsg   (ListEditor.Msg Remark.Msg)
  | CtrlS
  | NoMsg

update : Msg -> Model -> (Model, Cmd Msg)
update msg model = case msg of
  (UpdateStatement eMsg)  -> updateStatement eMsg model
  (UpdateAnswer    eMsg)  -> updateAnswer eMsg model
  (UpdateSolutions lMsg)  -> updateSolutions lMsg model
  (RemarkListMsg  rlMsg)  -> updateRemarks rlMsg model 
  CtrlS                   -> Debug.todo "Tab to next node on Ctrl+S"
  NoMsg                   -> (model, Cmd.none)

  

updateStatement : Editor.Msg -> Model -> (Model, Cmd Msg)
updateStatement eMsg model
  = let (editor1, eMsg1) = Editor.update eMsg model.statement
    in  ({ model | statement = editor1 }, Cmd.map UpdateStatement eMsg1)

updateAnswer : Editor.Msg -> Model -> (Model, Cmd Msg)
updateAnswer eMsg model
  = let (editor1, eMsg1) = Editor.update eMsg model.answer
    in  ({ model | answer = editor1 }, Cmd.map UpdateAnswer eMsg1)

updateSolutions : LList.Msg -> Model -> (Model, Cmd Msg)
updateSolutions lMsg model
  = let (list1, lMsg1) = LList.update lMsg model.solutions
    in ({ model | solutions = list1}, Cmd.map UpdateSolutions lMsg1)

updateRemarks : ListEditor.Msg Remark.Msg -> Model -> (Model, Cmd Msg)
updateRemarks msg model 
  = let (list1, lMsg1) = ListEditor.update remarkListInfo msg model.remarks
    in ({ model | remarks = list1 }, Cmd.map RemarkListMsg lMsg1)

-- VIEW

view : Model -> Html Msg
view model = Html.div [ Attr.class "container" ] [
    Html.fromUnstyled <| Shortcut.shortcutElement [ Shortcut.ctrlShortcut (Shortcut.Regular "S") CtrlS ] [] <| List.map Html.toUnstyled [
      Html.fieldset [] [
        Html.label [ Attr.class "form-label" ] [
          Html.text "Условие"
        ],
        Html.map UpdateStatement <| Editor.view model.statement
      ],
      Html.fieldset [] [
        Html.label [ Attr.class "form-label" ] [
          Html.text "Ответ"
        ],
        Html.map UpdateAnswer <| Editor.view model.answer
      ],
      Html.fieldset [] [
        Html.label [Attr.class "form-label" ] [
          Html.text "Решения"
        ],
        Html.map UpdateSolutions <| LList.view model.solutions,
        Html.button [ Ev.onClick <| UpdateSolutions LList.AddEditor ] [
          Html.text "Добавить решение"
        ]
      ],
      Html.fieldset [] [
        Html.label [ Attr.class "form-label" ] [
          Html.text "Примечания"
        ],
        Html.map RemarkListMsg <| ListEditor.view remarkListInfo model.remarks
      ]
    ]
  ]
  
