module Tabs.Play exposing (..)

import Html exposing (..)
import Material

import Translations exposing (..)
import Settings exposing (..)


-- MODEL

type alias Model =
    { mdl : Material.Model
    }


model : Model
model =
    { mdl = Material.model
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
       | play : Model
       , translation : Translation
       }
    -> Html msg
view lift model =
    text "instructions..."
