module Main exposing (..)

import Html exposing (Html, div, text)
import Html.App exposing (beginnerProgram)
import Intro.Intro as Intro

type alias Timer = String
type alias Model = { time : Timer }

type Msg = AskQuestion
         | WaitForTheAnswer
         | TallyTheScore

update msg model =
  case msg of
    _ -> model

view model = Intro.render model

main = beginnerProgram
  { model  = Model ""
  , view   = view
  , update = update
  }
