module Main exposing (..)

import Html exposing (Html, div, text)
import Html.App exposing (beginnerProgram)
import Intro.Intro as Intro
import Questions.Component as Question
import Questions.All exposing (everyQuestion)

type Page = IntroPage | QuestionPage

type Msg  = ShowIntro
          | ShowQuestion
          | TryAnswer String

type alias Q =
  { question : String
  , answer : String
  , revealed : Bool
  , timer : Int
  }

type alias Model =
  { page     : Page
  , question : Q
  }

model = Model QuestionPage

update msg model =
  case msg of
    ShowIntro ->
      { model | page = IntroPage }
    ShowQuestion ->
      { model | page = QuestionPage }
    TryAnswer ans ->
      let question = model.question
      in if ans == model.question.answer
        then { model | question = { question | revealed = True }}
        else model

view model =
  case model.page of
    QuestionPage -> Question.view TryAnswer model
    _            -> Intro.render model

main = beginnerProgram
  { model  = model
  , view   = view
  , update = update
  }
