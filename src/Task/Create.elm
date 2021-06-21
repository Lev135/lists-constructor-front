module Task.Create exposing (Settings, defaultSettings, Model, init, Msg(..), update, view)

import Html.Styled as Html exposing(Html)
import Html.Styled.Events as Ev
import Html.Styled.Attributes as Attr

import Latex.LatexEditor as Editor
import Latex.LatexList as LList

import Array as A exposing (Array)
import Array.Extra as A
import Task
import Browser.Dom

import Accessibility.Key as AccessKey
import Shortcut
-- MODEL

type alias Settings = {
    editor : Editor.Settings
  }

defaultSettings : Settings
defaultSettings = {
    editor = Editor.defaultSettings
  }

type alias RemarkModel = {
    typeR     : String,
    label     : String,
    body      : String
  }

defaultRemarkModel : RemarkModel
defaultRemarkModel = {
    typeR = "",
    label = "",
    body  = ""
  }

type alias Model = {
    statement : Editor.Model,
    answer    : Editor.Model,
    solutions : LList.Model,
    remarks   : Array RemarkModel,

    settings  : Settings
  }

init : Settings -> Model
init settings = {
    statement = Editor.init settings.editor,
    answer    = Editor.init settings.editor,
    solutions = LList.init {editor = settings.editor} 1,
    remarks   = A.empty,
    settings  = settings
  } 

-- UPDATE

type Msg
  = UpdateStatement Editor.Msg
  | UpdateAnswer    Editor.Msg
  | UpdateSolutions LList.Msg
  | AddRemark
  | RemoveRemark    Int
  | RTypeChanged    Int String
  | RLabelChanged   Int String
  | RBodyChanged    Int String
  | CtrlS
  | NoMsg

update : Msg -> Model -> (Model, Cmd Msg)
update msg model = case msg of
  (UpdateStatement eMsg)  -> updateStatement eMsg model
  (UpdateAnswer    eMsg)  -> updateAnswer eMsg model
  (UpdateSolutions lMsg)  -> updateSolutions lMsg model
  AddRemark               -> (addRemark model, focusOn <| remarkTypeInputId <| A.length model.remarks)
  (RemoveRemark  i     )  -> (removeRemark i model, Cmd.none)
  (RTypeChanged  i str )  -> (updateRemark i (updateRType  str) model, Cmd.none)
  (RLabelChanged i str )  -> (updateRemark i (updateRLabel str) model, Cmd.none)
  (RBodyChanged  i str )  -> (updateRemark i (updateRBody  str) model, Cmd.none)
  CtrlS                   -> Debug.todo "Tab to next node on Ctrl+S"
  NoMsg                   -> (model, Cmd.none)

focusOn : String -> Cmd Msg
focusOn id = Task.attempt (\_ -> NoMsg) (Browser.Dom.focus <| id)

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

addRemark : Model -> Model
addRemark model =  { model | remarks =  A.push defaultRemarkModel model.remarks }

removeRemark : Int -> Model -> Model
removeRemark i model = { model | remarks = A.removeAt i model.remarks}

updateRemark : Int -> (RemarkModel -> RemarkModel) -> Model -> Model
updateRemark i f model = { model | remarks = A.update i f model.remarks }

updateRType : String -> RemarkModel -> RemarkModel
updateRType str remark = { remark | typeR = str }
updateRLabel : String -> RemarkModel -> RemarkModel
updateRLabel str remark = { remark | label = str }
updateRBody : String -> RemarkModel -> RemarkModel
updateRBody str remark = { remark | body = str }
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
        viewRemarks model.remarks,
        Html.button [ Ev.onClick AddRemark ] [
          Html.text "Добавить примичание"
        ]
      ]
    ]
  ]
  
viewRemarks : Array RemarkModel -> Html Msg
viewRemarks remarks 
  = if A.length remarks == 1
    then case A.get 0 remarks of
      (Just remark) -> viewRemark 0 remark
      Nothing       -> Html.div [] [] 
    else viewRemarksImpl remarks

viewRemarksImpl : Array RemarkModel -> Html Msg
viewRemarksImpl = Html.div [] << A.toList << A.map (\m -> Html.fieldset[][m]) << A.indexedMap viewRemark 

viewRemark : Int -> RemarkModel -> Html Msg
viewRemark i remark = Html.div [] [
    Html.div [ Attr.class "row" ] [
      Html.div [ Attr.class "remark-type-block" ] [
        Html.label [ 
          Attr.class "form-label"  
        ] [ Html.text "Тип" ],
        Html.input [ 
          Attr.class "remark-type-input", 
          Attr.type_ "text", 
          Ev.onInput (RTypeChanged  i), 
          Attr.value remark.typeR,
          Attr.id <| remarkTypeInputId i
        ] []
      ],
      Html.div [ Attr.class "remark-label-block" ] [
        Html.label [ 
          Attr.class "form-label" 
        ] [ Html.text "Название" ],
        Html.input [ 
          Attr.class "remark-label-input", 
          Attr.type_ "text", 
          Ev.onInput (RLabelChanged i), 
          Attr.value remark.label 
        ][]
      ],
      Html.button [
        Attr.class "remove-button",
        Ev.onClick <| RemoveRemark i,
        Attr.fromUnstyled <| AccessKey.tabbable False 
      ] [ Html.text "X"]      
    ],
    Html.div [] [
      Html.label [ Attr.class "form-label" ] [ Html.text "Body"],
      Html.textarea [ Attr.style "width" "100%", Ev.onInput (RBodyChanged  i), Attr.value remark.body  ] []
    ]
  ]

remarkTypeInputId : Int -> String
remarkTypeInputId i = "remark-label-" ++ String.fromInt i