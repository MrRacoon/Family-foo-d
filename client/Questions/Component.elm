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

view try giveUp next model =
  let q = model.question
  in div []
    [ h1 [] [ text q.question ]
    , h2 []
      [ if q.revealed
        then text q.answer
        else text <| map charMask q.answer ]
    , div []
      [ if q.revealed
        then button
          [ onClick next ]
          [ text "Next Question" ]
        else div []
          [ input
            [ type' "text"
            , placeholder "answer"
            , onInput try
            ] [ ]
          , button
            [ onClick giveUp ]
            [ text "Give Up" ] ] ] ]
