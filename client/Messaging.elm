module Messaging exposing (parse, submit, vote, getPoints, Msg(..))
import Json.Encode as E
import Json.Decode as D

decodeType    = D.at ["type"] D.string
decodePayload = D.at ["payload"] D.string

type Msg
  = Attempt String String
  | NewQuestion String String
  | Answered String String
  | Votes (List String)
  | Unknown String
  | Points Int
  | NoAction

decodeNewQuestion =
  D.object2
    NewQuestion
    (D.at ["payload", "question"] D.string)
    (D.at ["payload", "mask"] D.string)

decodeAnswered =
  D.object2
    Answered
    (D.at ["payload", "name"] D.string)
    (D.at ["payload", "answer"] D.string)

decodeVotes =
  D.object1
    Votes
    (D.at ["payload", "participants"] (D.list D.string))

decodePoints =
  D.object1
    Points
    (D.at ["payload", "points"] D.int)

-- parse : String -> Result String Action
parse message =
  let t = D.decodeString decodeType message
  in case t of
    Ok "new"      -> D.decodeString decodeNewQuestion message
    Ok "answered" -> D.decodeString decodeAnswered message
    Ok "votes"    -> D.decodeString decodeVotes message
    Ok "points"   -> D.decodeString decodePoints message
    _             -> Ok <| Unknown message

submit name answer
  = E.encode 0 <|E.object [("name", E.string name), ("answer", E.string answer)]

vote nick
  = E.encode 0 <|E.object [("vote", E.string nick)]

getPoints nick
  = E.encode 0 <|E.object [("points", E.string nick)]
