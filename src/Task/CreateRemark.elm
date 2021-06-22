module Task.CreateRemark exposing (Model, defaultModel, Msg, update, view)

import Html.Styled as Html exposing(Html)
import Html.Styled.Events as Ev
import Html.Styled.Attributes as Attr

type alias Model = {
    typeR     : String,
    label     : String,
    body      : String
  }

defaultModel : Model
defaultModel = {
    typeR = "",
    label = "",
    body  = ""
  }


type Msg
  = TypeChanged    String
  | LabelChanged   String
  | BodyChanged    String


update : Msg -> Model -> (Model, Cmd a)
update msg model = 
  let model1 = case msg of
                  (TypeChanged  str ) -> {model | typeR = str}
                  (LabelChanged str ) -> {model | label = str}
                  (BodyChanged  str ) -> {model | body  = str}
  in (model1, Cmd.none) 

view : String -> Model -> Html Msg
view id remark = Html.div [] [
    Html.div [ Attr.class "row" ] [
      Html.div [ Attr.class "remark-type-block" ] [
        Html.label [ 
          Attr.class "form-label"  
        ] [ Html.text "Тип" ],
        Html.input [ 
          Attr.class "remark-type-input", 
          Attr.type_ "text", 
          Ev.onInput TypeChanged, 
          Attr.value remark.typeR,
          Attr.id id
        ] []
      ],
      Html.div [ Attr.class "remark-label-block" ] [
        Html.label [ 
          Attr.class "form-label" 
        ] [ Html.text "Название" ],
        Html.input [ 
          Attr.class "remark-label-input", 
          Attr.type_ "text", 
          Ev.onInput LabelChanged, 
          Attr.value remark.label 
        ][]
      ]
    ],
    Html.div [] [
      Html.label [ Attr.class "form-label" ] [ Html.text "Body"],
      Html.textarea [ Attr.style "width" "100%", Ev.onInput BodyChanged, Attr.value remark.body  ] []
    ]
  ]
