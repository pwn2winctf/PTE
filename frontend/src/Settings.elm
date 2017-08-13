module Settings exposing (..)

import Http
import Json.Decode as Decode exposing (..)

import Ports


type alias Settings =
    { ctfName : String
    , repositoryHost : RepositoryHost
    , submissionsProject : String
    }


type RepositoryHost
    = GitHub
    | GitLab


defaultSettings : Settings
defaultSettings =
    { ctfName = "Loading..."
    , repositoryHost = GitHub
    , submissionsProject = ""
    }


getSettings : (Result Http.Error Settings -> msg) -> Cmd msg
getSettings lift =
    Http.send lift <| Http.get "settings.json" decodeSettings


update :
    Result Http.Error Settings
    -> { m | settings : Settings }
    -> ( { m | settings : Settings }, Cmd msg )
update result model =
    case result of
        Ok settings ->
            ( { model | settings = settings }
            , Ports.title settings.ctfName
            )
        Err _ ->
            ( model, Cmd.none )


decodeSettings : Decoder Settings
decodeSettings =
    Decode.map3 Settings
            (field "ctf_name" string)
            (field "repository_host" string
                |> andThen
                    (\tag -> case tag of
                        "GitHub" -> succeed GitHub
                        "GitLab" -> succeed GitLab
                        _ -> fail (tag
                            ++ " is not a recognized repository host")
                    )
            )
            (field "submissions_project" string)
