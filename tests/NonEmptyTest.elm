module NonEmptyTest exposing (suite)

import Expect
import Fuzz
import List.NonEmpty as NonEmpty exposing (NonEmpty(..))
import Test exposing (Test)


suite : Test
suite =
    Test.describe "List.NonEmpty"
        [ Test.fuzz2
            nelistFuzzer
            Fuzz.bool
            "last (snoc nelist b) = b"
            (\nelist b ->
                Expect.equal
                    (NonEmpty.last (NonEmpty.snoc nelist b))
                    b
            )
        , Test.fuzz2
            nelistFuzzer
            Fuzz.bool
            "removeLast (snoc nelist b) = toList nelist"
            (\nelist b ->
                Expect.equal
                    (NonEmpty.removeLast (NonEmpty.snoc nelist b))
                    (toList nelist)
            )
        ]


nelistFuzzer : Fuzz.Fuzzer (NonEmpty Bool)
nelistFuzzer =
    Fuzz.map2 Head Fuzz.bool (Fuzz.list Fuzz.bool)


toList : NonEmpty a -> List a
toList (Head x xs) =
    x :: xs
