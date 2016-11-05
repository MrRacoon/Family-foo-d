module Component.Winner exposing (view)

import Html exposing (div, h1, h3, p, text)
import Styling exposing (classWinner)

view model =
  div [ classWinner ]
    [ h3 [] [ text "We have a winner!" ]
    , h1 [] [ text model.winner ]
    , p  [] [ text ("Answer: " ++ model.lastAnswer) ]
    ]
