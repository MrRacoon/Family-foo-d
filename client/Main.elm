module Main exposing (..)

import Debug        exposing (log)
import Platform.Cmd exposing (Cmd)
import Cmd.Extra    exposing (message)
import Html         exposing (Html, div)
import Html.Lazy    exposing (lazy)
import Html.App     exposing (program)
import Styling      exposing (classMain)

import Component.Nav     as Nav
import Intro.Intro       as Intro
import Winner.Winner     as Winner
import Question.Question as Question

import Messaging as M
import WebSocket

socketString = "ws://192.168.1.150:8081"

type Page
  = IntroPage
  | QuestionPage
  | WinnerPage

type Msg
  = ShowIntro
  | ShowQuestion
  | ShowWinner
  | NickChange String
  | TryAnswer String
  | NewMessage String
  | VoteForNew

type alias Model =
  { page       : Page
  , nick       : String
  , question   : String
  , mask       : String
  , lastAnswer : String
  , winner     : String
  , votes      : List String
  , voted      : Bool
  }

init : Model
init = Model QuestionPage "nobody" "" "" "" "" [] False

-- update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    -- Page navigation buttons
    ShowIntro ->
      ({ model | page = IntroPage }, Cmd.none)
    ShowQuestion ->
      ({ model | page = QuestionPage }, Cmd.none)
    ShowWinner ->
      ({ model | page = WinnerPage }, Cmd.none)

    -- Attempt to answer the question
    TryAnswer ans ->
      (model, WebSocket.send socketString <| M.submit model.nick ans)

    VoteForNew ->
      { model | voted = True } ! [WebSocket.send socketString <| M.vote model.nick]

    NickChange n ->
      ({ model | nick = n }, Cmd.none)

    -- Sockets
    NewMessage str ->
      case M.parse (log "msg" str) of
        Ok (M.NewQuestion q m) ->
          { model
          | question = q
          , mask = m
          , votes = []
          , voted = False
          } ! [message ShowQuestion]
        Ok (M.Answered n l) ->
          { model | winner = n, lastAnswer = l } ! [message ShowWinner]
        Ok (M.Votes ps) ->
          { model | votes = ps } ! []
        Ok _ ->
          (model, Cmd.none)
        Err err ->
          let e = log "error" err
          in (model, Cmd.none)

view : Model -> Html Msg
view model =
  div [classMain]
    [ Nav.view
      [ ( "Home"        , ShowIntro    )
      , ( "Questions"   , ShowQuestion )
      , ( "Last Winner" , ShowWinner )
      ]
    , case model.page of
        IntroPage    -> lazy (Intro.view NickChange) model
        QuestionPage -> lazy (Question.view TryAnswer VoteForNew) model
        WinnerPage   -> lazy Winner.view model
    ]

subscriptions model =
  WebSocket.listen socketString NewMessage

main : Program Never
main = program
  { init          = (init, Cmd.none)
  , update        = update
  , view          = view
  , subscriptions = subscriptions
  }
