module Task.Create exposing (Settings, defaultSettings, Model, init, Msg(..), update, view)

import Html.Styled as Html exposing(Html)
import Html.Styled.Events as Ev
import Html.Styled.Attributes as Attr

import Latex.LatexEditor as Editor
import Latex.LatexList as LList

-- MODEL

type alias Settings = {
    editor : Editor.Settings
  }

defaultSettings : Settings
defaultSettings = {
    editor = Editor.defaultSettings
  }

type alias Model = {
    statement : Editor.Model,
    answer    : Editor.Model,
    solutions : LList.Model,
    settings  : Settings
  }

init : Settings -> Model
init settings = {
    statement = Editor.init settings.editor,
    answer    = Editor.init settings.editor,
    solutions = LList.init {editor = settings.editor} 1,
    settings  = settings
  } 

-- UPDATE

type Msg
  = UpdateStatement Editor.Msg
  | UpdateAnswer    Editor.Msg
  | UpdateList      LList.Msg

update : Msg -> Model -> (Model, Cmd Msg)
update msg model = case msg of
  (UpdateStatement eMsg)  -> updateStatement eMsg model
  (UpdateAnswer    eMsg)  -> updateAnswer eMsg model
  (UpdateList      lMsg)  -> updateList lMsg model

updateStatement : Editor.Msg -> Model -> (Model, Cmd Msg)
updateStatement eMsg model
  = let (editor1, eMsg1) = Editor.update eMsg model.statement
    in  ({ model | statement = editor1 }, Cmd.map UpdateStatement eMsg1)

updateAnswer : Editor.Msg -> Model -> (Model, Cmd Msg)
updateAnswer eMsg model
  = let (editor1, eMsg1) = Editor.update eMsg model.answer
    in  ({ model | answer = editor1 }, Cmd.map UpdateAnswer eMsg1)

updateList : LList.Msg -> Model -> (Model, Cmd Msg)
updateList lMsg model
  = let (list1, lMsg1) = LList.update lMsg model.solutions
    in ({ model | solutions = list1}, Cmd.map UpdateList lMsg1)

-- VIEW

view : Model -> Html Msg
view model = Html.div [ Attr.class "container" ] [
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
      Html.label [Attr.class "form-label"] [
        Html.text "Решения"
      ],
      Html.map UpdateList <| LList.view model.solutions
    ],
    Html.button [ Ev.onClick <| UpdateList LList.AddEditor ] [
      Html.text "Добавить решение"
    ]
  ]
  