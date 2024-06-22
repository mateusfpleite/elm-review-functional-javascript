module FunctionalTypescript.NoUnionReturnsTest exposing (all)

import FunctionalTypescript.NoUnionReturns exposing (rule)
import Review.Project as Project exposing (Project)
import Review.Test
import Test exposing (Test, describe, test)


all : Test
all =
    let
        project : String -> Project
        project src =
            Project.new
                |> Project.addExtraFile
                    { path = "NoUnionReturns.ts"
                    , source = src
                    }
    in
    describe "FunctionalTypescript.NoUnionReturns"
        [ test "should not report an error when there are no union returns" <|
            \() ->
                """module A exposing (..)
a = 1"""
                    |> Review.Test.runWithProjectData (project src1) rule
                    |> Review.Test.expectNoErrors
        , test "should report an error when a function returns a union type" <|
            \() ->
                """module A exposing (..)
a = 1"""
                    |> Review.Test.runWithProjectData (project src2) rule
                    |> Review.Test.expect
                        [ Review.Test.extraFileErrors "NoUnionReturns.ts"
                            [ Review.Test.error
                                { message = "This function returns a union type: string | number"
                                , details = [ "To keep code reliability and consistency, functions should return single types" ]
                                , under = under2
                                }
                                |> Review.Test.atExactly { start = { row = 4, column = 1 }, end = { row = 5, column = 1 } }
                            ]
                        ]
        ]


src1 : String
src1 =
    """function getId(user: User): number {
    return user.id;
    }"""


src2 : String
src2 =
    """function getId(user: User): number {
    return user.id;
    }
type Calculator = (a: number, b: number, op: Operator) => string | number;"""


under2 : String
under2 =
    """type Calculator = (a: number, b: number, op: Operator) => string | number;
"""
