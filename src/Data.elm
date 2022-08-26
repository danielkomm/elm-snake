module Data exposing (Data(..), fromResult)

import Http


type Data value
    = Loading
    | Failure Http.Error
    | Success value


fromResult : Result Http.Error a -> Data a
fromResult result =
    case result of
        Ok val ->
            Success val

        Err err ->
            Failure err
