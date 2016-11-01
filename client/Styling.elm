module Styling exposing (..)

import Html.Attributes exposing (style, class)
import Style exposing (..)

classMain = class ""

classNavButton = class ""

navigation = style
  [ display flex'
  ]

navigationButton = style
  [ flex "1"
  , height "75px"
  , width "75px"
  , backgroundColor "#f5f5f5"
  , textAlign center
  , verticalAlign center
  ]

classIntro = class ""
classWinner = class ""
