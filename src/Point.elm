module Point exposing (Point, generator, move)

import Area exposing (Area)
import Direction exposing (Direction(..))
import Random


type alias Point =
    { x : Int, y : Int }


move : Direction -> Point -> Point
move directions point =
    case directions of
        Up ->
            { point | y = point.y - 1 }

        Down ->
            { point | y = point.y + 1 }

        Left ->
            { point | x = point.x - 1 }

        Right ->
            { point | x = point.x + 1 }


generator : Area -> Random.Generator Point
generator area =
    Random.map2
        Point
        (Random.int 0 (area.height - 1))
        (Random.int 0 (area.width - 1))
