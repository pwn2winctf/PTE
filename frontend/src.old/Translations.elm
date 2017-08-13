module Translations exposing (..)

import Dict exposing (Dict)
import Translations.Translation as Translation
import Translations.English as English
import Translations.Portuguese as Portuguese
import Translations.Chinese as Chinese

type alias Translation = Translation.Translation

type Language
    = English
    | Portuguese
    | Chinese

languages : List Language
languages =
    [ English
    , Portuguese
    , Chinese
    ]

defaultLanguage : Language
defaultLanguage = English

defaultTranslation : Translation
defaultTranslation = translation defaultLanguage

translation : Language -> Translation
translation lang =
    case lang of
        English -> English.translation
        Portuguese -> Portuguese.translation
        Chinese -> Chinese.translation

langcode2language : Dict String Language
langcode2language =
    languages
    |> List.map (\lang -> (translation lang |> .langcode, lang))
    |> Dict.fromList

language : String -> Language
language langcode =
    langcode2language
    |> Dict.get langcode
    |> Maybe.withDefault defaultLanguage
