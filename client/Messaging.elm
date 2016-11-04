module Messaging exposing (..)
import Json.Encode as E
import Json.Decode as D
import Debug exposing (log)

type alias Attempt =
  { name   : String , answer : String }

submit name answer
  = E.encode 0 <|E.object [("name", E.string name), ("answer", E.string answer)]

type Action
  = NewQuestion String String
  | Answered String String
  | NoAction

decodeNewQuestion =
  D.object2 NewQuestion (D.at ["question"] D.string) (D.at ["mask"] D.string)

decodeAnswered =
  D.object2 Answered (D.at ["name"] D.string) (D.at ["answer"] D.string)

type Msg = Msg String String

decodeMsg =
  D.object2 Msg (D.at ["type"] D.string) (D.at ["payload"] D.string)

decodeType =
  D.at ["type"] D.string

decodePayload dec =
  D.decodeString (D.at ["payload"] dec)

parse : String -> Result String Action
parse message =
  let t = D.decodeString decodeType message
  in case (log "t" t) of
    Ok "new" -> decodePayload decodeNewQuestion message
    Ok "answered" -> decodePayload decodeAnswered message
    _ -> Ok NoAction
