module Translations.English exposing (..)

import Translations.Translation exposing (Translation)

translation : Translation
translation =
    { langname = "English"
    , langcode = "en"
    , challenges = "Challenges"
    , scoreboard = "Scoreboard"
    , play = "Play"
    , solvedBy = \pol team -> case pol of
        True -> "Solved by " ++ team
        False -> "Not solved by " ++ team
    , inCategory = \pol cat -> case pol of
        True -> "In category " ++ cat
        False -> "Not in category " ++ cat
    }
