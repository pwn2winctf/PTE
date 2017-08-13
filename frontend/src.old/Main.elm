module Main exposing (..)

import Http
import Html exposing (..)
import Array exposing (Array)
import Dict exposing (Dict)
import Material
import Material.Layout as Layout
import Material.Color as Color
import Material.Options as Options
import Material.Icon as Icon
import Material.Menu as Menu
import Material.Helpers exposing (lift)
import RouteHash exposing (HashUpdate)
import RouteUrl exposing (UrlChange, RouteUrlProgram)
import RouteUrl.Builder as Builder exposing (Builder)
import Navigation exposing (Location)

import Ports
import GModel exposing (..)
import Translations exposing (..)
import Settings exposing (..)
import Data
import Tabs.Challenges as Challenges
import Tabs.Scoreboard as Scoreboard
import Tabs.Play as Play


-- MODEL

type alias Model =
    { mdl : Material.Model
    , g : GModel
    , challenges : Challenges.Model
    , scoreboard : Scoreboard.Model
    , play : Play.Model
    , selectedTab : Int
    }


model : Model
model =
    { mdl = Material.model
    , g = gmodel
    , challenges = Challenges.model
    , scoreboard = Scoreboard.model
    , play = Play.model
    , selectedTab = 0
    }


type alias Tab =
    { url : String
    , icon : String
    , caption : Translation -> String
    , view : Model -> Html Msg
    }

tabs : Array Tab
tabs = Array.fromList
    [ { url = "challenges"
      , icon = "assignment"
      , caption = .challenges
      , view = \m -> Challenges.view m.challenges m.g |> Html.map ChallengesMsg
      }
    , { url = "scoreboard"
      , icon = "stars"
      , caption = .scoreboard
      , view = \m -> Scoreboard.view m.scoreboard m.g |> Html.map ScoreboardMsg
      }
    , { url = "play"
      , icon = "assignment_turned_in"
      , caption = .play
      , view = \m -> Play.view m.play m.g |> Html.map PlayMsg
      }
    ]

tabUrl2Index : Dict String Int
tabUrl2Index =
    tabs
    |> Array.indexedMap (\i tab -> (tab.url, i))
    |> Array.toList |> Dict.fromList


-- UPDATE

type Msg
    = Mdl (Material.Msg Msg)
    | LoadSettings (Result Http.Error Settings)
    | SelectTab Int
    | ChangeLanguage Language
    | ChallengesMsg Challenges.Msg
    | ScoreboardMsg Scoreboard.Msg
    | PlayMsg Play.Msg
    | DataMsg Data.Msg


update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    let
        g = model.g
    in case msg of
        Mdl a ->
            Material.update Mdl a model

        DataMsg a ->
            Data.update DataMsg a model

        SelectTab tab ->
            ( { model | selectedTab = tab}, Cmd.none )

        ChangeLanguage lang ->
            ( { model | g = { g | translation = translation lang } }, Cmd.none )

        LoadSettings (Ok settings) ->
            ( { model | g = { g | settings = settings } }
            , Ports.title settings.ctfName
            )

        LoadSettings (Err _) ->
            ( model, Cmd.none )

        -- messages routed to tabs
        ChallengesMsg a -> lift .challenges (\m x->{m|challenges=x}) ChallengesMsg Challenges.update a model
        ScoreboardMsg a -> lift .scoreboard (\m x->{m|scoreboard=x}) ScoreboardMsg Scoreboard.update a model
        PlayMsg a -> lift .play (\m x->{m|play=x}) PlayMsg Play.update a model


-- VIEW

view : Model -> Html Msg
view model =
    Layout.render Mdl model.mdl
    [ Layout.selectedTab model.selectedTab
    , Layout.onSelectTab SelectTab
    , Layout.fixedHeader
    , Layout.scrolling ]
    { header = viewHeader model
    , drawer = []
    , tabs = viewTabs model
    , main =
        Array.get model.selectedTab tabs
            |> Maybe.map (\tab -> [ tab.view model ])
            |> Maybe.withDefault [ text "tab missing from the tabs list" ]
    }


viewHeader : Model -> List (Html Msg)
viewHeader model =
    [ Layout.row
        [ darkBackgroud ]
        [ Layout.title [] [ text model.g.settings.ctfName ]
        , Layout.spacer
        , Menu.render Mdl [0] model.mdl
              [ Menu.icon "language"
              , Menu.bottomRight
              ]
              <| List.map (\lang ->
                    Menu.item
                        [ ChangeLanguage lang |> Menu.onSelect ]
                        [ translation lang |> .langname |> text ]
                ) languages
        ]
    ]


viewTabs : Model -> ( List (Html Msg), List (Options.Property c m) )
viewTabs model =
    ( tabs |> Array.map
        (\tab -> span []
            [ tab.icon |> Icon.i
            , tab.caption model.g.translation |> text
            ]
        )
      |> Array.toList
    , [ darkBackgroud ]
    )


darkBackgroud : Options.Property c m
darkBackgroud = Color.background (Color.color Color.BlueGrey Color.S900)


-- URL ROUTING

delta2hash : Model -> Model -> Maybe UrlChange
delta2hash previous current =
    Builder.builder
        |> Builder.replacePath
            [ Array.get current.selectedTab tabs
                |> Maybe.map .url
                |> Maybe.withDefault ""
            ]
        |> Builder.insertQuery "hl" current.g.translation.langcode
        |> Builder.toHashChange
        |> Just


hash2messages : Location -> List Msg
hash2messages location =
    let
        builder = Builder.fromHash location.href
        path = Builder.path builder
        query = Builder.query builder
        tabMsg = case path of
            first :: rest ->
                tabUrl2Index
                |> Dict.get first
                |> Maybe.map (\i -> [ SelectTab i ])
                |> Maybe.withDefault []
            _ -> []
        langMsg = query
            |> Dict.get "hl"
            |> Maybe.map (\l -> [ ChangeLanguage (language l) ])
            |> Maybe.withDefault []
    in tabMsg ++ langMsg


-- MAIN

main : RouteUrlProgram Never Model Msg
main =
    RouteUrl.program
        { delta2url = delta2hash
        , location2messages = hash2messages
        , init =
            ( model
            , Cmd.batch
                [ Layout.sub0 Mdl
                , Http.send LoadSettings getSettings
                ]
            )
        , update = update
        , view = view
        , subscriptions = \model ->
            Sub.batch
            [ Material.subscriptions Mdl model
            , Data.subscriptions DataMsg model.g
            ]
        }
