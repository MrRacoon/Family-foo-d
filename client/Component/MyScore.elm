module Component.MyScore exposing (view)

import Html exposing (div, h1, h2, hr, input, text)
import Html.Attributes exposing (placeholder)
import Html.Events exposing (onInput)
import Styling exposing (classIntro)

type Msg = NameChange

view nickChange model =
  div [classIntro]
    [ h1 [] [ text model.nick ]
    , h2 [] [ text <| toString model.points ]
    , hr [] []
    , input [ placeholder "new nickname", onInput nickChange ] []
    ]
