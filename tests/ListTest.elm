module ListTest exposing (suite)

import Expect
import Fuzz
import List.Extra
import Test exposing (Test)


suite : Test
suite =
    Test.describe "List.Extra"
        [ Test.fuzz
            Fuzz.bool
            "reverse [b] = [b]"
            (\b ->
                Expect.equal
                    (List.Extra.reverse [ b ])
                    [ b ]
            )
        , Test.fuzz2
            (Fuzz.list Fuzz.bool)
            (Fuzz.list Fuzz.bool)
            "reverse (bs1 ++ bs2) = reverse bs2 ++ reverse bs1"
            (\bs1 bs2 ->
                Expect.equal
                    (List.Extra.reverse (bs1 ++ bs2))
                    (List.Extra.reverse bs2 ++ List.Extra.reverse bs1)
            )
        , Test.fuzz
            (Fuzz.list Fuzz.bool)
            "List.any identity list = any identity list"
            (\list ->
                Expect.equal
                    (List.any identity list)
                    (List.Extra.any identity list)
            )
        , Test.fuzz
            (Fuzz.list Fuzz.unit)
            "indexedMap (\n _ -> n) list = range 0 (length list - 1)"
            (\list ->
                Expect.equal
                    (List.Extra.indexedMap (\n _ -> n) list)
                    (List.range 0 (List.length list - 1))
            )
        ]
