module Questions.All exposing (everyQuestion)

import List
import String
import Questions.Content.Q00 as Q0

import Debug exposing (log)

everyQuestion = [ Q0.qs ]
  |> List.map String.lines
  |> List.concat
  |> List.map (String.split "`")
