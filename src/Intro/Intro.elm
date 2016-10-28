module Intro.Intro exposing (..)

import Html exposing (div, h1, h3, p, text)
import Html.Attributes exposing (class)
import Styling exposing (classIntro)

tip = "hot, steamy foo"

render _ =
  div [classIntro]
    [ h3 [] [ text "Welcom to" ]
    , h1 [] [ text "friendly-foo" ]
    , p  [] [ text tip ]
    ]
