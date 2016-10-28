module Main exposing (..)

import Random
import List exposing (head, drop, length)

import Html exposing (Html, div, button, text, a)
import Html.Lazy exposing (lazy)
import Html.App exposing (beginnerProgram)

import Styling exposing (classMain)

import Component.Nav as Nav
import Intro.Intro as Intro
import Questions.Component as Question
import Questions.All exposing (everyQuestion)

type Page = IntroPage | QuestionPage

type Msg  = ShowIntro
          | ShowQuestion
          | TryAnswer String
          | GiveUp
          | GenerateNextIndex
          | RetrieveQuestion

type alias Q =
  { question : String
  , answer : String
  , revealed : Bool
  }

initQuestion : Q
initQuestion = Q
  "Are you ready?"
  "yes"
  False

pickQuestion : List (List String) -> Int -> Q
pickQuestion qs ind =
  case head <| drop ind qs of
    Just [q, a] -> Q q a False
    _ -> Q "No more! :(" "λ" False

type alias Model =
  { page     : Page
  , question : Q
  , index    : Int
  , randGen  : Random.Generator Int
  }

model : Model
model = Model
  QuestionPage
  initQuestion
  0
  (Random.int 0 <| length everyQuestion)


update : Msg -> Model -> Model
update msg model =
  case msg of
    ShowIntro ->
      { model | page = IntroPage }
    ShowQuestion ->
      { model | page = QuestionPage }
    RetrieveQuestion ->
      { model
        | question = pickQuestion everyQuestion (model.index + 1)
        , index    = model.index + 1
        }
    GenerateNextIndex -> model
    GiveUp ->
      let question = model.question
      in { model | question = { question | revealed = True }}
    TryAnswer ans ->
      let question = model.question
      in if ans == model.question.answer
        then { model | question = { question | revealed = True }}
        else model


questionView : Model -> Html Msg
questionView = lazy <| Question.view TryAnswer GiveUp RetrieveQuestion

navigation : Nav.Navigation Msg
navigation =
  [ ( "Home"     , ShowIntro    )
  , ( "Questions", ShowQuestion )
  ]

view : Model -> Html Msg
view model =
  div [classMain]
    [ Nav.render navigation
    , case model.page of
        IntroPage    -> Intro.render model
        QuestionPage -> questionView model
    ]

main : Program Never
main = beginnerProgram
  { model  = model
  , view   = view
  , update = update
  }
