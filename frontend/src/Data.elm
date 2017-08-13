module Data exposing (..)

import Http
import Json.Decode as Decode exposing (..)
import Time exposing (..)
import Regex exposing (..)
import Debug exposing (log)

import Settings exposing (..)


refreshInterval = 2 * second


type alias Model =
    { test : ()
    }


model : Model
model =
    { test = ()
    }



type Msg
    = Tick Time
    | GetChallengeIndex (Result Http.Error (List String))
    | GetSubmissions (Result Http.Error (List Submission))


type alias Submission =
    { teamId : String
    , points : Int
    , challId : String
    }


update :
    (Msg -> msg)
    -> Msg
    -> { m
       | data : Model
       , settings : Settings
       }
    -> ( { m
         | data : Model
         , settings : Settings
         }
       , Cmd msg
       )
update lift msg model =
    case msg of
        Tick t ->
            let ver = t / refreshInterval |> truncate |> toString
                path = submissionsPath model
            in  ( model
                , Cmd.map lift <| Cmd.batch
                    [ getChallengeIndex ver
                    , case path of
                        Just p -> getSubmissions ver p
                        Nothing -> Cmd.none
                    ]
                )

        GetChallengeIndex (Ok challs) ->
            let x = log "GetChallengeIndex" challs
            in  ( model, Cmd.none )

        GetChallengeIndex (Err _) ->
            ( model, Cmd.none )

        GetSubmissions (Ok submissions) ->
            let x = log "GetSubmissions" submissions
            in  ( model, Cmd.none )

        GetSubmissions (Err _) ->
            ( model, Cmd.none )


getChallengeIndex : String -> Cmd Msg
getChallengeIndex ver =
    Http.send GetChallengeIndex
        <| Http.get ("challenges/index.json?_=" ++ ver)
        <| list string


getSubmissions : String -> String -> Cmd Msg
getSubmissions ver path =
    Http.send GetSubmissions
        <| Http.get (path ++ "/accepted-submissions.json?_=" ++ ver)
        <| decodeSubmissions


decodeSubmissions : Decoder (List Submission)
decodeSubmissions =
    list <| Decode.map3 Submission
        (field "team" string)
        (field "points" int)
        (field "chall" string)


submissionsPath : { m | settings : Settings } -> Maybe String
submissionsPath model =
    find (AtMost 1) (regex "/[^/]+$") model.settings.submissionsProject
        |> List.head
        |> Maybe.map (\r -> ".." ++ r.match)


subscriptions :
    (Msg -> msg)
    -> m
    -> Sub msg
subscriptions lift model =
    Tick >> lift |> every refreshInterval
