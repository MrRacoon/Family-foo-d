module Question.Question exposing (..)

import String exposing (map, toLower, filter)
import Set exposing (Set, fromList, member)
import Html exposing (Html, div, h1, h2, h4, text, button, input)
import Html.Events exposing (onClick, onInput)
import Html.Attributes exposing (placeholder, type')

ignoreChars : Set Char
ignoreChars = fromList
  [ ' ', '.', ',', '>', '<', '!', '@', '#', '$' , '%', '^', '&', '*', '(', ')'
  , '[', ']', '{', '}', '-', '+', '=' ,'_', ':', ';', '?', '/', '|', '`', '~'
  , '\\'
  ]

ignored : Char -> Bool
ignored = flip member ignoreChars

charMask : Char -> Char
charMask c = if ignored c then c else '*'

sanatize : String -> String
sanatize str = toLower <| filter (not << ignored) str

answersMatch : String -> String -> Bool
answersMatch a b = sanatize a == sanatize b

view try model =
  div []
    [ h1 [] [ text model.question ]
    , h4 [] [ text model.mask ]
    , div []
      [ div []
        [ input [ type' "text" , placeholder "answer" , onInput try ] [ ]
        ]
      ]
    ]
