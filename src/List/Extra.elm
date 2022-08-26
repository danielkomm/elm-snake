module List.Extra exposing (any, indexedMap, reverse, snoc)


snoc : List a -> a -> List a
snoc list lastElem =
    case list of
        [] ->
            [ lastElem ]

        p :: ps ->
            p :: snoc ps lastElem


reverse : List a -> List a
reverse list =
    case list of
        [] ->
            []

        p :: ps ->
            snoc (reverse ps) p


indexedMap : (Int -> a -> b) -> List a -> List b
indexedMap f =
    let
        toIndex index list =
            case list of
                [] ->
                    []

                p :: ps ->
                    f index p :: toIndex (index + 1) ps
    in
    toIndex 0


any : (a -> Bool) -> List a -> Bool
any func list =
    case list of
        [] ->
            False

        p :: ps ->
            func p || any func ps
