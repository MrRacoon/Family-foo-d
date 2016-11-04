module Intro.Intro exposing (..)

import Html exposing (div, h1, h3, h4, p, input, text)
import Html.Attributes exposing (placeholder)
import Html.Events exposing (onInput)
import Styling exposing (classIntro)

type Msg = NameChange

tip = "hot, steamy foo"

render nickChange model =
  div [classIntro]
    [ h3 [] [ text "Welcom to" ]
    , h1 [] [ text "friendly-foo" ]
    , div []
      [ h4 [] [ text "Enter your nickname" ]
      , input [ placeholder "nickname", onInput nickChange ] [] ]
    , p  [] [ text tip ]
    ]
