module Utils.ListEditor exposing (Info, init, Msg(..), update, view)

import Html.Styled as Html exposing(Html)
import Html.Styled.Events as Ev
import Html.Styled.Attributes as Attr

import Array as A exposing (Array)
import Array.Extra as A

import Accessibility.Key as AccessKey

import Task
import Browser.Dom

-- MODEL

type alias Info elModel elMsg = {
    contId     : String,
    initVal    : elModel,
    updateFunc : elMsg -> elModel -> (elModel, Cmd elMsg),
    viewFunc   : String -> elModel -> Html elMsg,
    elName     : String
  }

init : Info elModel elMsg -> Int -> Array elModel
init info count = A.repeat count info.initVal

-- UPDATE

type Msg elMsg
  = ElMsg Int elMsg
  | AddElement
  | RemoveElement Int
  | FocusError String
  | Focused 

update : Info elModel elMsg -> Msg elMsg -> Array elModel -> (Array elModel, Cmd (Msg elMsg))
update info msg = case msg of
  (ElMsg i elMsg)   -> updateElement info i elMsg
  AddElement        -> addElement info
  (RemoveElement i) -> removeElement i
  (FocusError id)   -> Debug.todo <| "Не удаётся установить фокус на элемент: " ++ id
  Focused           -> \m -> (m, Cmd.none)


updateElement : Info elModel elMsg -> Int -> elMsg -> Array elModel -> (Array elModel, Cmd (Msg elMsg))
updateElement info i elMsg model = case A.get i model of
   (Just el) -> let (el1, elMsg1) = info.updateFunc elMsg el
                in (
                  A.set i el1 model,
                  Cmd.map (ElMsg i) elMsg1 
                )
   Nothing   -> Debug.log  ("Incorrect element index : " ++ String.fromInt i)
                (model, Cmd.none)

addElement : Info elModel elMsg -> Array elModel -> (Array elModel, Cmd (Msg elMsg))
addElement info model
 = let elId = genElId info.contId <| A.length model
    in (A.push info.initVal model, focusOn elId)

removeElement : Int -> Array elModel -> (Array elModel, Cmd (Msg elMsg))
removeElement i model = (A.removeAt i model, Cmd.none)

focusOn : String -> Cmd (Msg elMsg)
focusOn id
  = let helper r = case r of
                    (Err _) -> (FocusError id)
                    _       -> Focused
    in Task.attempt helper <| Browser.Dom.focus id

-- VIEW

view : Info elModel elMsg -> Array elModel -> Html (Msg elMsg)
view info model = Html.div [] [
    case A.length model of
      0 -> viewEmpty
      1 -> case A.get 0 model of
                (Just el) -> viewOne info el
                Nothing   -> Html.div [] []
      _ -> viewMany info model
    , Html.button [ Ev.onClick AddElement ] [
      Html.text <| "Добавить " ++ info.elName
    ]
  ]

viewEmpty : Html msg
viewEmpty = Html.label [ Attr.class "row" ] [Html.text "(пока что их нет)"]

viewOne : Info elModel elMsg -> elModel -> Html (Msg elMsg)
viewOne info = addRemoveButton 0 << elView info 0

viewMany : Info elModel elMsg -> Array elModel -> Html (Msg elMsg)
viewMany info = Html.div []
  << A.toList 
  << A.map (\m -> Html.fieldset [][ m ])
  << A.indexedMap addRemoveButton 
  << A.indexedMap (elView info) 

addRemoveButton : Int -> Html (Msg elMsg) -> Html (Msg elMsg)
addRemoveButton i m = Html.div [ Attr.class "row" ] [
    Html.button [
        Attr.class "remove-button",
        Ev.onClick <| RemoveElement i,
        Attr.fromUnstyled <| AccessKey.tabbable False 
      ] [ Html.text "X"],
    Html.div [ Attr.class "removable-block" ] [m]
  ]

elView : Info elModel elMsg -> Int -> elModel -> Html (Msg elMsg)
elView info i = Html.map (ElMsg i) << (info.viewFunc <| genElId info.contId i)

genElId : String -> Int -> String
genElId contId i = contId ++ "-element-" ++ String.fromInt i
