module Translations.Translation exposing (..)

type alias Translation =
    { langname : String
    , langcode : String
    , challenges : String
    , scoreboard : String
    , play : String
    , solvedBy : Bool -> String -> String
    , inCategory : Bool -> String -> String
    }
