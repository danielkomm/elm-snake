module Highscore exposing (Highscore, decoder, displayHighScores, updateScoreValue)

import Data exposing (Data(..))
import Html exposing (Html, div, text)
import Http exposing (Error(..))
import Json.Decode as Decode exposing (Decoder)


type alias Highscore =
    { player : String, score : Int }


updateScoreValue : Highscore -> Highscore
updateScoreValue highscore =
    { highscore | score = highscore.score + 1 }


decoder : Decoder (List Highscore)
decoder =
    Decode.list (Decode.map2 Highscore (Decode.field "name" Decode.string) (Decode.field "score" Decode.int))


displayHighScores : Data (List Highscore) -> Html msg
displayHighScores data =
    case data of
        Loading ->
            text "Loading"

        Success val ->
            div [] (List.map (\element -> div [] [ text element.player, text (String.fromInt element.score) ]) val)

        Failure err ->
            case err of
                Timeout ->
                    text "Time out"

                NetworkError ->
                    text "Network Error"

                BadStatus status ->
                    text ("Bad Status " ++ String.fromInt status)

                BadUrl _ ->
                    text "Bad Url Error"

                BadBody _ ->
                    text "Bad Body Error"
