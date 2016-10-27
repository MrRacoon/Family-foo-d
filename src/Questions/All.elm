module Questions.All exposing (everyQuestion)

import List
import String
import Questions.Content.Q00 as Q0

everyQuestion =
     List.map (String.split "`")
  <| List.concat
  <| List.map String.lines
  <| [ Q0.qs ]
