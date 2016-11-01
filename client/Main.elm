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
import Winner.Winner as Winner
import Questions.Component as Question

import Messaging as M

import Random
import WebSocket

socketString = "ws://localhost:8081"

type Page = IntroPage | QuestionPage | WinnerPage

type Msg  = ShowIntro
          | ShowQuestion
          | ShowWinner
          | TryAnswer String
          | NewMessage String

type alias Q =
  { question : String
  , answer : String
  }

initQuestion : Q
initQuestion = Q "Are you ready?" "yes"

type alias Model =
  { page     : Page
  , question : Q
  , winner : String
  }

init : Model
init = Model
  QuestionPage
  initQuestion
  ""

-- update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    -- Page navigation buttons
    ShowIntro    -> ({ model | page = IntroPage }, Cmd.none)
    ShowQuestion -> ({ model | page = QuestionPage }, Cmd.none)
    ShowWinner -> ({ model | page = WinnerPage }, Cmd.none)

    -- Attempt to answer the question
    TryAnswer ans ->
      (model, WebSocket.send socketString <| M.submit "erik" ans)

    -- Sockets
    NewMessage str ->
      case M.parse (log "msg" str) of
        Ok (M.NewQuestion q a) ->
          ({ model | question = Q q a }, message ShowQuestion)
        Ok (M.Answered name) ->
          ({ model | winner = name }, message ShowWinner)
        Ok (M.NoAction) ->
          (model, Cmd.none)
        Err err ->
          let e = log "error" err
          in (model, Cmd.none)

questionView : Model -> Html Msg
questionView = lazy <| Question.view TryAnswer

navigation : Nav.Navigation Msg
navigation =
  [ ( "Home"     , ShowIntro    )
  , ( "Questions", ShowQuestion )
  , ( "Last Winner", ShowWinner )
  ]

view : Model -> Html Msg
view model =
  div [classMain]
    [ Nav.render navigation
    , case model.page of
        IntroPage    -> Intro.render model
        QuestionPage -> questionView model
        WinnerPage   -> Winner.render model
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
