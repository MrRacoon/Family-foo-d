module Questions.Component exposing (..)

import String exposing (map)
import Html exposing (Html, div, h1, h3, h4, text, button, input)
import Html.Events exposing (onClick, onInput)
import Html.Attributes exposing (placeholder, type')

charMask c = case c of
  ' '  -> ' '
  '.'  -> '.'
  ','  -> ','
  '\'' -> '\''
  '"'  -> '"'
  _    -> '*'

view try giveUp next model =
  let q = model.question
  in div []
    [ h1 [] [ text q.question ]
    , h3 [] [ if q.revealed then text q.answer else text <| map charMask q.answer ]
    , input [ type' "text" , placeholder "answer" , onInput try ] [ ]
    , div []
      [ if q.revealed
        then button [onClick next] [ text "Next Question" ]
        else button [onClick giveUp] [ text "Give Up" ]
      ]
    ]
