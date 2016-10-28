module Questions.All exposing (everyQuestion)

import List exposing (map, concatMap)
import String exposing (lines, split)
import Questions.Content.Q00 as Q0

parse = map (split "`") << concatMap lines

everyQuestion = parse
  [ Q0.qs ]
