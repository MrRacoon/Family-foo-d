module Component.Nav exposing (..)

import List exposing (map)
import Html exposing (Html, div, button, text)
import Html.Events exposing (onClick)
import Html.Attributes exposing (class)
import Styling as Style

type alias Button a = (String, a)
type alias Navigation a = List (Button a)

makeButton : (String, a) -> Html a
makeButton (t, e) =
  button [Style.classNavButton, Style.navigationButton, onClick e] [text t]

render : Navigation a -> Html a
render config =
  div [Style.navigation]
    <| map makeButton config
