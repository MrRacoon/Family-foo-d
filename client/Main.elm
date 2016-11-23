module Main exposing (..)

import Debug        exposing (log)
import Platform.Cmd exposing (Cmd)
import Cmd.Extra    exposing (message)
import Html         exposing (Html, div)
import Html.Lazy    exposing (lazy)
import Html.App     exposing (program)
import Styling      exposing (classMain)

import Component.All exposing ( nav, myScore, question, winner )

import Messaging as M
import WebSocket

socketString = "ws://127.0.0.1:8081"

type Page
  = MyScorePage
  | QuestionPage
  | WinnerPage

type Msg
  = ShowMyScore
  | ShowQuestion
  | ShowWinner
  | NickChange String
  | TryAnswer String
  | NewMessage String
  | GetPoints

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
  , points     : Int
  }

init : Model
init = Model QuestionPage "nobody" "" "" "" "" [] False 0

-- update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    -- Page navigation buttons
    ShowMyScore ->
      { model | page = MyScorePage } ! [message GetPoints]
    ShowQuestion ->
      ({ model | page = QuestionPage }, Cmd.none)
    ShowWinner ->
      ({ model | page = WinnerPage }, Cmd.none)

    -- Attempt to answer the question
    TryAnswer ans ->
      model ! [WebSocket.send socketString <| M.submit model.nick ans]

    VoteForNew ->
      { model | voted = True } ! [WebSocket.send socketString <| M.vote model.nick]

    NickChange n ->
      ({ model | nick = n }, Cmd.none)

    GetPoints ->
      model ! [WebSocket.send socketString <| M.getPoints model.nick]

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
        Ok (M.Points pts) ->
          { model | points = pts } ! []
        Ok _ ->
          (model, Cmd.none)
        Err err ->
          let e = log "error" err
          in (model, Cmd.none)

view : Model -> Html Msg
view model =
  div [classMain]
    [ nav
      [ ( "MyScore"     , ShowMyScore    )
      , ( "Questions"   , ShowQuestion )
      , ( "Last Winner" , ShowWinner )
      ]
    , case model.page of
        MyScorePage  -> lazy (myScore NickChange) model
        QuestionPage -> lazy (question TryAnswer VoteForNew) model
        WinnerPage   -> lazy winner model
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
