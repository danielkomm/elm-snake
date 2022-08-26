module Main exposing (main)

import Area exposing (Area)
import Browser
import Browser.Events
import Color
import Data exposing (Data(..))
import Direction exposing (Direction(..))
import Highscore exposing (Highscore)
import Html exposing (Html, div, text)
import Html.Attributes exposing (style)
import Http
import Json.Decode as Decode exposing (Decoder)
import List.Extra
import List.NonEmpty exposing (NonEmpty(..))
import Point exposing (Point)
import Random
import Snake exposing (Snake)
import Svg exposing (Svg, rect, svg)
import Svg.Attributes exposing (fill, height, width, x, y)
import Time


init : ( Game, Cmd Msg )
init =
    ( Game (Running (Head (Point 6 7) [ Point 7 7, Point 8 7 ]) Direction.Down 200) Nothing (Highscore "Daniel" 0) Loading
    , Random.generate GeneratedFood (Point.generator areaSize)
    )


fieldSize : Int
fieldSize =
    15


areaSize : Area
areaSize =
    { width = 30, height = 30 }


type alias Game =
    { snake : SnakeModel, food : Maybe Point, score : Highscore, highscores : Data (List Highscore) }


type SnakeModel
    = Crashed CrashReason Snake
    | Running Snake Direction Float


type Msg
    = Tick
    | KeyInput (Maybe Key)
    | GeneratedFood Point
    | Response (Result Http.Error (List Highscore))


type Key
    = KeyDirection InputDirection
    | KeyR


type InputDirection
    = KeyUp
    | KeyDown
    | KeyLeft
    | KeyRight


type CrashReason
    = Collision
    | OutOfBounds



-- SVG drawings


pointToSvg : Color.Color -> Point -> Svg msg
pointToSvg color point =
    rect
        [ x (String.fromInt (point.x * fieldSize))
        , y (String.fromInt (point.y * fieldSize))
        , width (String.fromInt fieldSize)
        , height (String.fromInt fieldSize)
        , fill (Color.toString color)
        ]
        []


areaToSvg : Area -> Svg msg
areaToSvg area =
    rect
        [ x (String.fromInt 0)
        , y (String.fromInt 0)
        , width (String.fromInt (area.width * fieldSize))
        , height (String.fromInt (area.height * fieldSize))
        , fill (Color.toString Color.Lightgrey)
        ]
        []


snakeToSvg : Snake -> List (Svg Msg)
snakeToSvg (Head h t) =
    pointToSvg Color.Red h :: snakeToSvgHelper t


snakeToSvgHelper : List Point -> List (Svg Msg)
snakeToSvgHelper =
    List.Extra.indexedMap (\index -> pointToSvg (Color.HSL (10 * index) 100 40))


foodToSvg : Maybe Point -> Svg Msg
foodToSvg maybePoint =
    case maybePoint of
        Just point ->
            pointToSvg Color.Green point

        Nothing ->
            rect [] []



-- Key controls


toKeyHelper : String -> Maybe Key
toKeyHelper keyString =
    case keyString of
        "ArrowUp" ->
            Just (KeyDirection KeyUp)

        "ArrowDown" ->
            Just (KeyDirection KeyDown)

        "ArrowLeft" ->
            Just (KeyDirection KeyLeft)

        "ArrowRight" ->
            Just (KeyDirection KeyRight)

        "r" ->
            Just KeyR

        _ ->
            Nothing


keyDecoder : Decoder (Maybe Key)
keyDecoder =
    Decode.map toKeyHelper (Decode.field "key" Decode.string)


keyToDirection : InputDirection -> Direction
keyToDirection key =
    case key of
        KeyUp ->
            Up

        KeyDown ->
            Down

        KeyLeft ->
            Left

        KeyRight ->
            Right



-- HTTP Request


request : Cmd Msg
request =
    Http.get { url = "http://193.175.181.175/highscores", expect = Http.expectJson Response Highscore.decoder }



-- Draw HTML


drawHtmlForView : String -> Snake -> Maybe Point -> Highscore -> Html Msg
drawHtmlForView discription snakeState food score =
    div []
        [ div []
            [ svg
                [ style "width" (String.fromInt (areaSize.width * fieldSize))
                , style "height" (String.fromInt (areaSize.height * fieldSize))
                ]
                (areaToSvg areaSize :: foodToSvg food :: List.Extra.reverse (snakeToSvg snakeState))
            ]
        , div [] [ text discription, text (String.fromInt score.score) ]
        ]



-- View, Update and Main


view : Game -> Html Msg
view { snake, food, score, highscores } =
    case snake of
        Running snakeState _ _ ->
            drawHtmlForView "Your score: " snakeState food score

        Crashed Collision snakeState ->
            div []
                [ drawHtmlForView "Collision " snakeState food score
                , div [] [ Highscore.displayHighScores highscores ]
                ]

        Crashed OutOfBounds snakeState ->
            div []
                [ drawHtmlForView "Out of bounds! " snakeState food score
                , div [] [ Highscore.displayHighScores highscores ]
                ]


update : Msg -> Game -> ( Game, Cmd Msg )
update msg model =
    case model.snake of
        Running snake oldDir tick ->
            case msg of
                Tick ->
                    let
                        newSnake =
                            Snake.move oldDir snake
                    in
                    if Snake.hasCollision newSnake then
                        ( { model | snake = Crashed Collision newSnake }, request )

                    else if Snake.isOutOfBounds newSnake areaSize then
                        ( { model | snake = Crashed OutOfBounds newSnake }, request )

                    else if Snake.maybeFoundFood newSnake model.food then
                        ( { model
                            | snake = Running (Snake.extend snake) oldDir (max (tick - 10) 100)
                            , food = Nothing
                            , score = Highscore.updateScoreValue model.score
                          }
                        , Random.generate GeneratedFood (Point.generator areaSize)
                        )

                    else
                        ( { model | snake = Running newSnake oldDir tick }, Cmd.none )

                KeyInput input ->
                    case input of
                        Just key ->
                            case key of
                                KeyDirection keydir ->
                                    ( { model | snake = Running snake (keyToDirection keydir) tick }, Cmd.none )

                                KeyR ->
                                    init

                        Nothing ->
                            ( model, Cmd.none )

                GeneratedFood point ->
                    ( { model | food = Just point }, Cmd.none )

                Response response ->
                    ( { model | highscores = Data.fromResult response }, Cmd.none )

        Crashed _ _ ->
            case msg of
                Response response ->
                    ( { model | highscores = Data.fromResult response }, Cmd.none )

                _ ->
                    ( model, Cmd.none )


main : Program () Game Msg
main =
    Browser.element
        { init = \_ -> init
        , view = view
        , update = update
        , subscriptions =
            \model ->
                Sub.batch
                    [ case model.snake of
                        Running _ _ tick ->
                            Time.every tick (\_ -> Tick)

                        Crashed _ _ ->
                            Sub.none
                    , Sub.map KeyInput (Browser.Events.onKeyDown keyDecoder)
                    ]
        }
