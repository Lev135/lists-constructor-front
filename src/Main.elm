module Main exposing (..)

import Html.Styled exposing (toUnstyled)
import Browser
import Html exposing(..)

import LatexList

documentView : (model -> Html msg) -> model -> Browser.Document msg
documentView view model = {
    title = "",
    body = [view model]
  }

main : Program () LatexList.Model LatexList.Msg
main =
    Browser.document
        { view = documentView <| LatexList.view >> toUnstyled
        , update = LatexList.update
        , init = LatexList.init
        , subscriptions = LatexList.subscriptions
        }
