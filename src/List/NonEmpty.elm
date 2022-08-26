module List.NonEmpty exposing (NonEmpty(..), headMethod, last, removeLast, snoc)

import List.Extra as List


type NonEmpty a
    = Head a (List a)


snoc : NonEmpty a -> a -> NonEmpty a
snoc (Head head sBody) lastElem =
    Head head (List.snoc sBody lastElem)


last : NonEmpty a -> a
last (Head head sBody) =
    case sBody of
        [] ->
            head

        firstElem :: lastElem ->
            last (Head firstElem lastElem)


removeLast : NonEmpty a -> List a
removeLast (Head head sBody) =
    case sBody of
        [] ->
            []

        firstElem :: lastElem ->
            head :: removeLast (Head firstElem lastElem)


headMethod : NonEmpty a -> a
headMethod (Head firstElem _) =
    firstElem
