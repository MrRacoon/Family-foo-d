module Main exposing (..)

import Platform.Cmd exposing (Cmd)
import Platform.Sub exposing (Sub)
import Cmd.Extra exposing (message)

import String exposing (toLower, toUpper)
import List exposing (head, drop, length)

import Html exposing (..)
import Html.Lazy exposing (lazy)
import Html.App exposing (program)
import Html.Events exposing (..)

import Styling exposing (classMain)

import Component.Nav as Nav
import Intro.Intro as Intro
import Questions.Component as Question
import Questions.All exposing (everyQuestion)

import Random

questionGen = Random.int 0
  <| (\n -> n - 1)
  <| length everyQuestion


type Page = IntroPage | QuestionPage

type Msg  = ShowIntro
          | ShowQuestion
          | TryAnswer String
          | GiveUp
          | NewIndex Int
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
    Just [q, a] -> Q (toUpper q) (toLower a) False
    _ -> Q "No more! :(" "λ" False

type alias Model =
  { page     : Page
  , question : Q
  , index    : Int
  }

init : Model
init = Model QuestionPage initQuestion 0

-- update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    ShowIntro ->
      ({ model | page = IntroPage }, Cmd.none)
    ShowQuestion ->
      ({ model | page = QuestionPage }, Cmd.none)
    RetrieveQuestion ->
      { model
        | question = pickQuestion everyQuestion (model.index + 1)
        }
      ! []
    GenerateNextIndex ->
      (model, Random.generate NewIndex questionGen)
    NewIndex ind ->
      { model
        | index = ind
        , question = pickQuestion everyQuestion ind
        }
      ! []
    GiveUp ->
      let question = model.question
      in { model | question = { question | revealed = True }} ! []
    TryAnswer ans ->
      let question = model.question
      in if ans == model.question.answer
        then { model | question = { question | revealed = True }} ! []
        else (model, Cmd.none)


questionView : Model -> Html Msg
questionView = lazy <| Question.view TryAnswer GiveUp GenerateNextIndex

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
main = program
  { init   = (init, Cmd.none)
  , update = update
  , view   = view
  , subscriptions = always Sub.none
  }
