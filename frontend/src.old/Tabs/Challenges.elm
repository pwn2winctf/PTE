module Tabs.Challenges exposing (..)

import Html exposing (..)
import Debug exposing (log)
import Material
import Material.Card as Card
import Material.Icon as Icon
import Material.Chip as Chip
import Material.Color as Color
import Material.Button as Button
import Material.Options as Options exposing (css)
import Material.Elevation as Elevation
import Material.Typography as Typography

import GModel exposing (..)


-- MODEL

type alias Model =
    { mdl : Material.Model
    , current : Maybe String
    , raised : Int
    }


model : Model
model =
    { mdl = Material.model
    , current = Nothing
    , raised = -1
    }


-- UPDATE

type Msg
    = Mdl (Material.Msg Msg)
    | Raise Int
    | Log String


update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        Mdl a ->
            Material.update Mdl a model

        Raise i ->
            ( { model | raised = i }, Cmd.none )

        Log a ->
            log a ( model, Cmd.none )


-- VIEW

white : Options.Property c m
white =
  Color.text Color.white

catopt =
    [ white
    , css "height" "24px"
    , css "min-width" "32px"
    , css "text-transform" "none"
    , css "padding" "0"
    , css "line-height" "24px"
    , css "font-weight" "unset"
    ]

card model i =
    Card.view
        [ css "width" "200px"
        , css "margin" "14px 7px 0 7px"
        , if model.raised == i then Elevation.e6 else Elevation.e2
        , Elevation.transition 250
        , Options.onMouseEnter (Raise i)
        , Options.onMouseLeave (Raise -1)
        , Color.background <| Color.color Color.Indigo Color.S400
        ]
        [ Card.title
            [ css "cursor" "pointer"
            ]
            [ Card.head [ white ] [ text "Challenge Title" ]
            ]
        , Card.text
            [ css "padding-top" "0"
            , css "cursor" "pointer"
            , white
            ]
            [ Options.div
                [ Typography.display3 ]
                [ Icon.view "star"
                    [ Icon.size48
                    , css "min-width" "48px"
                    , css "text-align" "center"
                    ]
                , text "150"
                ]
            , Options.div
                [ Typography.display1 ]
                [ Icon.view "done"
                    [ Icon.size24
                    , css "min-width" "48px"
                    , css "text-align" "center"
                    ]
                , text "12"
                ]
            ]
        , Card.actions
            [ Card.border
            , css "vertical-align" "center"
            , css "text-align" "right"
            , white
            ]
            [ Button.render Mdl [i,0] model.mdl catopt [text "rev"]
            , Button.render Mdl [i,1] model.mdl catopt [text "xpl"]
            ]
        ]

view : Model -> GModel -> Html Msg
view model g =
    Options.div
        []
        [ Options.div
            [ css "padding" "14px 14px 0px 14px"]
            [ Chip.span
                [ Chip.deleteIcon "cancel"
                , Chip.deleteClick (Log "deleteClick")
                , Options.onClick (Log "onClick")
                ]
                [ Chip.content []
                    [ text <| g.translation.solvedBy False "ELT" ]
                ]
            , Chip.span
                [ Chip.deleteIcon "cancel"
                , Chip.deleteClick (Log "deleteClick")
                , Options.onClick (Log "onClick")
                ]
                [ Chip.content []
                    [ text <| g.translation.solvedBy True "TheGoonies" ]
                ]
            , Chip.span
                [ Chip.deleteIcon "cancel"
                , Chip.deleteClick (Log "deleteClick")
                , Options.onClick (Log "onClick")
                ]
                [ Chip.content []
                    [ text <| g.translation.inCategory True "xpl" ]
                ]
            ]
        , Options.div
            [ css "padding-left" "7px"
            , css "padding-right" "7px"
            , css "display" "flex"
            , css "flex-flow" "row wrap"
            --, css "justify-content" "center"
            , css "justify-content" "flex-start"
            , css "align-items" "baseline"
            , css "flex" "1 1 auto"
            ]
            (List.range 0 5 |> List.map (card model))
        ]
