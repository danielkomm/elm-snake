module Snake exposing (Snake, extend, hasCollision, isOutOfBounds, maybeFoundFood, move)

import Area exposing (Area)
import Direction exposing (Direction)
import List.Extra
import List.NonEmpty exposing (NonEmpty(..))
import Point exposing (Point)


type alias Snake =
    NonEmpty Point


move : Direction -> Snake -> Snake
move direction snake =
    Head (Point.move direction (List.NonEmpty.headMethod snake)) (List.NonEmpty.removeLast snake)


extend : Snake -> Snake
extend snake =
    List.NonEmpty.snoc snake (List.NonEmpty.last snake)


isOutOfBounds : Snake -> Area -> Bool
isOutOfBounds (Head head _) area =
    head.x >= area.width || head.y >= area.height || head.x < 0 || head.y < 0


hasCollision : Snake -> Bool
hasCollision (Head head tail) =
    List.Extra.any ((==) head) tail


maybeFoundFood : Snake -> Maybe Point -> Bool
maybeFoundFood (Head head _) maybeFood =
    case maybeFood of
        Just food ->
            head == food

        Nothing ->
            False
