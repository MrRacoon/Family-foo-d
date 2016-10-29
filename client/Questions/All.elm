module Questions.All exposing (everyQuestion)

import List exposing (map, concatMap)
import String exposing (lines, split)
import Questions.Content.Q00 as Q0
import Questions.Content.Q01 as Q1
import Questions.Content.Q02 as Q2
import Questions.Content.Q03 as Q3

parse = map (split "`") << concatMap lines

everyQuestion = parse
  [ Q0.qs
  , Q1.qs
  , Q2.qs
  , Q3.qs
  ]
