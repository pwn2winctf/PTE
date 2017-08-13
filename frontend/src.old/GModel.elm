module GModel exposing (..)

import Translations exposing (..)
import Settings exposing (..)


type alias GModel =
    { translation : Translation
    , settings : Settings
    }

gmodel : GModel
gmodel =
    { translation = defaultTranslation
    , settings = defaultSettings
    }
