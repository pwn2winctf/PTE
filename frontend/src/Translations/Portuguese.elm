module Translations.Portuguese exposing (..)

import Translations.Translation exposing (Translation)

translation : Translation
translation =
    { langname = "Português"
    , langcode = "pt"
    , challenges = "Problemas"
    , scoreboard = "Placar"
    , play = "Jogar"
    , solvedBy = \pol team -> case pol of
        True -> "Resolvido por " ++ team
        False -> "Não resolvido por " ++ team
    , inCategory = \pol cat -> case pol of
        True -> "Categoria " ++ cat
        False -> "Fora da categoria " ++ cat
    }
