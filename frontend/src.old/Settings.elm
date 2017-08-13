module Settings exposing (..)

import Http
import Json.Decode as Decode exposing (..)


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
    { ctfName = "Loading settings.json..."
    , repositoryHost = GitHub
    , submissionsProject = "group/CTFsubmissions"
    }


getSettings : Http.Request Settings
getSettings =
    Http.get "settings.json" decodeSettings


decodeSettings : Decoder Settings
decodeSettings =
    Decode.map3 Settings
        (field "ctf_name" string)
        (field "repository_host" string
            |> andThen decodeRepositoryHost)
        (field "submissions_project" string)


decodeRepositoryHost : String -> Decoder RepositoryHost
decodeRepositoryHost tag = case tag of
    "GitHub" -> succeed GitHub
    "GitLab" -> succeed GitLab
    _ -> fail (tag ++ " is not a recognized repository host")
