module Winner.Winner exposing (..)

import Html exposing (div, h1, h3, p, text)
import Styling exposing (classWinner)

render model =
  div [classWinner]
    [ h3 [] [ text "We have a winner!" ]
    , h1 [] [ text model.winner ]
    , p [] [ text ("Answer: " ++ model.answer)]
    ]
