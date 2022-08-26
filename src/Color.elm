module Color exposing (Color(..), toString)


type Color
    = Red
    | Lightgrey
    | Green
      -- HSL benötigt 3 Params für die jeweiligen Werte
    | HSL Int Int Int


toString : Color -> String
toString color =
    case color of
        Red ->
            "red"

        Green ->
            "green"

        Lightgrey ->
            "lightgrey"

        HSL h s l ->
            "hsl(" ++ String.fromInt h ++ "," ++ String.fromInt s ++ "%," ++ String.fromInt l ++ "%)"
