module Main exposing (..)

import Debug exposing (log)
import Platform.Cmd exposing (Cmd)
import Platform.Sub exposing (Sub)
import Cmd.Extra exposing (message)
import Json.Encode as Encode

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
import Messaging as M

import Random
import WebSocket

socketString = "ws://localhost:8081"

type Page = IntroPage | QuestionPage

type Msg  = ShowIntro
          | ShowQuestion
          | TryAnswer String
          | GiveUp
          | NewIndex Int
          | GenerateNextIndex
          | NewMessage String

type alias Q =
  { question : String
  , answer : String
  , revealed : Bool
  }

initQuestion : Q
initQuestion = Q "Are you ready?" "yes" False

type alias Model =
  { page     : Page
  , question : Q
  }

init : Model
init = Model
  QuestionPage
  initQuestion

pickQuestion : Int -> List (List String) -> Q
pickQuestion ind qs =
  case head <| drop ind qs of
    Just [q, a] -> Q (toUpper q) (toLower a) False
    _ -> initQuestion

-- update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    -- Page navigation buttons
    ShowIntro    -> ({ model | page = IntroPage }, Cmd.none)
    ShowQuestion -> ({ model | page = QuestionPage }, Cmd.none)

    -- Random Question Gathering
    GenerateNextIndex ->
      let questionGen = Random.int 0 <| (length everyQuestion - 1)
      in (model, Random.generate NewIndex questionGen)
    NewIndex ind ->
      { model | question = pickQuestion ind everyQuestion } ! []

    -- Attempt to answer the question
    TryAnswer ans ->
      let question = model.question
      in if Question.answersMatch ans question.answer
        then
          { model | question = { question | revealed = True }} ! []
        else
          (model, WebSocket.send socketString <| M.submit "erik" ans)

    -- The User has had enough
    GiveUp ->
      let question = model.question
      in { model | question = { question | revealed = True }} ! []

    -- Sockets
    NewMessage str ->
      case M.parse (log "msg" str) of
        Ok (M.NewQuestion q a) ->
          ({ model | question = Q q a False }, Cmd.none)
        Ok (M.NoAction) ->
          (model, Cmd.none)
        Err err ->
          (model, Cmd.none)
        _ ->
          (model, Cmd.none)

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

subscriptions model =
  WebSocket.listen socketString NewMessage

main : Program Never
main = program
  { init   = (init, Cmd.none)
  , update = update
  , view   = view
  , subscriptions = subscriptions
  }
