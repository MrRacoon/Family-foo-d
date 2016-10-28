module Questions.Component exposing (..)

import String exposing (map)
import Set exposing (Set, fromList, member)
import Html exposing (Html, div, h1, h2, h4, text, button, input)
import Html.Events exposing (onClick, onInput)
import Html.Attributes exposing (placeholder, type')

ignoreChars : Set Char
ignoreChars = fromList
  [ ' ' , '.' , ',' , '>' , '<' , '!' , '@' , '#' , '$' , '%' , '^'
  , '&' , '*' , '(' , ')' , '[' , ']' , '{' , '}' , '-' , '+' , '='
  , '_'
  ]

isIgnored  = flip member ignoreChars
charMask c = if isIgnored c then c else '*'

view try giveUp next model =
  let q = model.question
  in div []
    [ h4 [] [ text <| toString model.index ]
    , h1 [] [ text q.question ]
    , h2 [] [ if q.revealed then text q.answer else text <| map charMask q.answer ]
    , div []
      [ if q.revealed
        then button [onClick next] [ text "Next Question" ]
        else div []
          [ input [ type' "text" , placeholder "answer" , onInput try ] [ ]
          , button [onClick giveUp] [ text "Give Up" ]
          ]
      ]
    ]
