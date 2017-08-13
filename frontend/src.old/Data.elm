module Data exposing (..)

import Time exposing (..)

import Settings exposing (..)


type Msg
    = Tick Time


update lift msg model =
    ( model, Cmd.none )


subscriptions :
    (Msg -> m)
    -> { g | settings : Settings }
    -> Sub m
subscriptions lift g =
    every second (Tick >> lift)
