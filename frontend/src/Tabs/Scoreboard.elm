module Tabs.Scoreboard exposing (..)

import Html exposing (..)
import Material

import Translations exposing (..)


-- MODEL

type alias Model =
    { mdl : Material.Model
    , team : Maybe String
    }


model : Model
model =
    { mdl = Material.model
    , team = Nothing
    }


-- UPDATE

type Msg
    = Mdl (Material.Msg Msg)


update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        Mdl a ->
            Material.update Mdl a model


-- VIEW

view :
    (Msg -> msg)
    -> { m
       | scoreboard : Model
       , translation : Translation
       }
    -> Html msg
view lift model =
    text "scoreboard"
