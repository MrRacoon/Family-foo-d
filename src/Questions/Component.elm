module Questions.Component exposing (..)

import Html exposing (Html, div, h1, h3, h4, text, button, input)
import Html.Events exposing (onClick, onInput)
import Html.Attributes exposing (placeholder, type')

view try model =
  let q = model.question
  in div []
    [ h1 []
      [ text q.question ]
    , h3 []
      [ if q.revealed
        then text q.answer
        else text ""
      ]
    , h4 []
      [ text <| toString q.timer ]
    , input
      [ type' "text"
      , placeholder "answer"
      , onInput try
      ]
      [ ]
    , button []
      [ text "Next Question" ]
    ]
