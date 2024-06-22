module NoLooseEqualityTest exposing (all)

import FunctionalJavascript.NoLooseEquality exposing (rule)
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
                    { path = "NoLooseEquality.js"
                    , source = src
                    }
    in
    describe "NoLooseEquality"
        [ test "should report an error when using loose equality" <|
            \() ->
                """module ModuleA exposing (a)
a = 1"""
                    |> Review.Test.runWithProjectData (project src1) rule
                    |> Review.Test.expect
                        [ Review.Test.extraFileErrors "NoLooseEquality.js"
                            ([ under1a, under1b, under1c ]
                                |> List.map
                                    (\under ->
                                        Review.Test.error
                                            { message = "Loose equality operator found"
                                            , details = [ "Use strict equality operator instead" ]
                                            , under = under
                                            }
                                    )
                            )
                        ]
        , test "should not report an error when using strict equality" <|
            \() ->
                """module ModuleA exposing (a)
a = 1"""
                    |> Review.Test.runWithProjectData (project src2) rule
                    |> Review.Test.expectNoErrors
        ]


src1 : String
src1 =
    """function alwaysReturnFirstIf(input) {
    if (input == 0) {
        return "Input is zero";
    } else if (input == "") {
        return "Input is an empty string";
    } else if (input == false) {
        return "Input is false";
    } else {
        return ("Input is something else");
    }
}"""


under1a : String
under1a =
    """    if (input == 0) {"""


under1b : String
under1b =
    """    } else if (input == "") {"""


under1c : String
under1c =
    """    } else if (input == false) {"""


src2 : String
src2 =
    """function alwaysReturnFirstIf(input) {
    if (input === 0) {
        return "Input is zero";
    } else if (input === "") {
        return "Input is an empty string";
    } else if (input === false) {
        return "Input is false";
    } else {
        return ("Input is something else");
    }
}"""
