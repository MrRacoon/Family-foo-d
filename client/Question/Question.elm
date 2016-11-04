module Question.Question exposing (view)

import List exposing (map)
import Html exposing (Html, div, h1, h4, text, button, input, ul, li)
import Html.Events exposing (onClick, onInput)
import Html.Attributes exposing (placeholder, type')

listName n = li [] [ text n ]

view try vote model =
  div []
    [ h1 [] [ text model.question ]
    , h4 [] [ text model.mask ]
    , div []
      [ div []
        [ input [ type' "text" , placeholder "answer" , onInput try ] [ ]
        ]
      , div []
        (if model.voted
          then
            [ h4 [] [ text "Voted: "]
            , ul [] ( map listName model.votes )
            ]
          else
            [ button [ onClick vote ] [ text "vote for new question" ]
            ]
        )
      ]
    ]
