module Questions.Component exposing (..)

import String exposing (map, toLower, filter)
import Set exposing (Set, fromList, member)
import Html exposing (Html, div, h1, h2, h4, text, button, input)
import Html.Events exposing (onClick, onInput)
import Html.Attributes exposing (placeholder, type')

ignoreChars : Set Char
ignoreChars = fromList
  [ ' ', '.', ',', '>', '<', '!', '@', '#', '$' , '%', '^', '&', '*', '(', ')'
  , '[', ']', '{', '}', '-', '+', '=' , '_', ':', ';', '?', '/', '\\', '|', '`'
  , '~'
  ]

ignored    = flip member ignoreChars
charMask c = if ignored c then c else '*'

sanatize str = toLower <| filter (not << ignored) str
answersMatch a b = sanatize a == sanatize b

view try model =
  let q = model.question
  in div []
    [ h1 [] [ text q.question ]
    , h2 []
      [ text <| map charMask q.answer ]
    , div []
      [ div []
        [ input [ type' "text" , placeholder "answer" , onInput try ] [ ]
        ]
      ]
    ]
