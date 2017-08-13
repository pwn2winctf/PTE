module Tabs.Play exposing (..)

import Html exposing (..)
import Material

import GModel exposing (..)


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

view : Model -> GModel -> Html Msg
view model g =
    text "instructions..."
