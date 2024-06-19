module FunctionalTypescript.NoUnionReturnsTest exposing (all)

import FunctionalTypescript.NoUnionReturns exposing (rule)
import Review.Test
import Test exposing (Test, describe, test)


all : Test
all =
    describe "FunctionalTypescript.NoUnionReturns"
        [ test "should not report an error when REPLACEME" <|
            \() ->
                """module A exposing (..)
a = 1
"""
                    |> Review.Test.run rule
                    |> Review.Test.expectNoErrors
        , test "should report an error when REPLACEME" <|
            \() ->
                """module A exposing (..)
a = 1
"""
                    |> Review.Test.run rule
                    |> Review.Test.expectErrors
                        [ Review.Test.error
                            { message = "REPLACEME"
                            , details = [ "REPLACEME" ]
                            , under = "REPLACEME"
                            }
                        ]
        ]