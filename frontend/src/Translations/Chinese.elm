module Translations.Chinese exposing (..)

import Translations.Translation exposing (Translation)

translation : Translation
translation =
    { langname = "中文"
    , langcode = "zh"
    , challenges = "问题"
    , scoreboard = "记分牌"
    , play = "竞争"
    , solvedBy = \pol team -> case pol of
        True -> "被" ++ team ++ "解决"
        False -> "没有被" ++ team ++ "解决"
    , inCategory = \pol cat -> case pol of
        True -> "於類別" ++ cat
        False -> "不在類別" ++ cat
    }
