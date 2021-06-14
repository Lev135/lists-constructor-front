port module MTask exposing (Form, Msg, update, view, init)

import Html as Html exposing(Html)
import Html.Attributes as Attr
import Html.Events as Ev

import Array as A exposing (Array)
import Array.Extra as A
import Maybe exposing (withDefault)

-- Model
type alias LatexString = String

type Msg
  = EnteredStatement String
  | EnteredSolution Int String
  | AddSolution
  | SolutionFocused Int

type alias SolutionForm = {
    body : LatexString,
    ready : Bool
  }

defaultSolution = {
    body = "",
    ready = False  
  }

type alias Form = {
    statement : LatexString,
    solutions : Array SolutionForm
  }

defaultForm = {
    statement = "",
    solutions = A.repeat 1 defaultSolution
  }
-- Init

init : () -> (Form, Cmd a)
init _ = (defaultForm, Cmd.none)

-- UPDATE

solutionReady : Array SolutionForm -> Int -> Bool
solutionReady solutions i = 
  case A.get i solutions of
    Just sol -> sol.ready
    Nothing  -> False

update : Msg -> Form -> (Form, Cmd Msg)
update msg model = 
  case msg of
    EnteredStatement  str -> ({ model | statement = str },
                                Cmd.none) 
    EnteredSolution i str -> ({ model | solutions = A.update i (\s -> { s | body = str}) model.solutions}, 
                                Cmd.none)
    AddSolution           -> ({ model | solutions = A.push defaultSolution model.solutions},
                                Cmd.none )
    SolutionFocused i     -> if not <| solutionReady model.solutions i 
                             then ({ model | solutions = A.update i (\s -> { s | ready = True }) model.solutions },
                                     sendMessage <| solutionId i)
                             else (model, Cmd.none)

-- PORTS

port sendMessage : String -> Cmd msg
port messageReceiver : (String -> msg) -> Sub msg

-- VIEW

view : Form -> Html Msg
view = viewForm 


statementFieldSet : Form -> Html Msg
statementFieldSet form = 
  Html.fieldset [] <| [
    Html.text "Условие задачи ",
    Html.textarea [
      Attr.id "Statement",
--        Attr.class "",
      Attr.placeholder "Условие задачи",
      Ev.onInput EnteredStatement,
      Attr.value form.statement
    ] []
  ]

ordinals : Array String
ordinals = A.fromList ["Первое", "Второе", "Третье", "Четвёртое", "Пятое"]

getSolutionMsg : Int -> String
getSolutionMsg i = case A.get i ordinals of
   Just str -> str ++ " решение задачи "
   Nothing -> "Error"

solutionId : Int -> String
solutionId i = "Solution-" ++ String.fromInt i
solutionFieldSet : Int -> SolutionForm -> Html Msg
solutionFieldSet i form =
  Html.fieldset [] [
    Html.text <| getSolutionMsg i,
    Html.textarea [    
      Attr.id <| solutionId i,
      Attr.placeholder "Решение задачи",
      Ev.onInput <| EnteredSolution i,
      Attr.value form.body,
      Ev.onFocus <| SolutionFocused i
    ] []
  ]


viewForm : Form -> Html Msg
viewForm form = 
  Html.div [] [
    Html.div [ Attr.class "div-form" ](
      [
        statementFieldSet form
      ]
      ++ (A.toList <| A.indexedMap solutionFieldSet form.solutions)
      ++ [
        Html.button [
          Attr.class "button-add", 
          Ev.onClick AddSolution, 
          Attr.disabled <| A.length form.solutions == 5
        ] [ Html.text "Добавить решение" ],
        Html.button [
          Attr.class "button-submit"
        ][ Html.text "Создать задачу" ]
      ]
    ),
    Html.div [] [
      Html.text "Compiled something"
    ]
  ]
  
