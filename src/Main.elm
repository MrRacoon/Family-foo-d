module Main exposing (..)

import Debug exposing (log)

import Html exposing (Html, div, button, text, a)
import Html.Lazy exposing (lazy)
import Html.App exposing (beginnerProgram)
import Html.Events exposing (onClick)

import String exposing (split)
import List exposing (head, drop)
import Intro.Intro as Intro
import Questions.Component as Question
import Questions.All exposing (everyQuestion)

type Page = IntroPage | QuestionPage

type Msg  = ShowIntro
          | ShowQuestion
          | TryAnswer String
          | GiveUp
          | NextQuestion

type alias Q =
  { question : String
  , answer : String
  , revealed : Bool
  }

initQuestion = Q
  "who"
  "me"
  False

pickQuestion : List (List String) -> Int -> Q
pickQuestion qs ind =
  case head <| drop ind qs of
    Just [q, a] -> Q q a False
    Nothing -> Q "yarp" "pixie" False
    _ -> Q "yarp" "pixie" False

type alias Model =
  { page     : Page
  , question : Q
  , index    : Int
  }

model : Model
model = Model QuestionPage initQuestion 0

update : Msg -> Model -> Model
update msg model =
  case msg of
    ShowIntro ->
      { model | page = IntroPage }
    ShowQuestion ->
      { model | page = QuestionPage }
    NextQuestion ->
      { model
        | question = pickQuestion everyQuestion (model.index + 1)
        , index    = model.index + 1
        }
    GiveUp ->
      let question = model.question
      in { model | question = { question | revealed = True }}
    TryAnswer ans ->
      let question = model.question
      in if ans == model.question.answer
        then { model | question = { question | revealed = True }}
        else model

questionView = Question.view TryAnswer GiveUp NextQuestion

view : Model -> Html Msg
view model =
  case model.page of
    QuestionPage -> app <| lazy questionView <| model
    _            -> app <| Intro.render model

app page =
  let buttonStyles =
    []
  in div []
    [ div [onClick ShowIntro] [text "main"]
    , div [onClick ShowQuestion] [text "trivia"]
    , page
    ]

main = beginnerProgram
  { model  = model
  , view   = view
  , update = update
  }
