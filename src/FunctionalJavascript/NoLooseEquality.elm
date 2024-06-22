module FunctionalJavascript.NoLooseEquality exposing (rule)

{-|

@docs rule

-}

import Dict exposing (Dict)
import Elm.Syntax.Expression exposing (Expression)
import Elm.Syntax.Node as Node exposing (Node)
import Elm.Syntax.Range as Range exposing (Range)
import Review.FilePattern as FilePattern
import Review.Rule as Rule exposing (Rule)


{-| Reports uses of loose equality operators `==` and `!=`.

    config =
        [ FunctionalJavascript.NoLooseEquality.rule
        ]


## Fail

    function compare(a, b) {
        return a == b;
        }
    function compare(a, b) {
        return a != b;
        }


## Success

    function compare(a, b) {
        return a === b;
        }
    function compare(a, b) {
        return a !== b;
        }


## Try it out

You can try this rule out by running the following command:

```bash
elm-review --template mateusfpleite/elm-review-functional-javascript/example --rules NoLooseEquality
```

-}
rule : Rule
rule =
    let
        dependenciesPatterns =
            [ FilePattern.excludeDirectory "node_modules/", FilePattern.excludeDirectory "elm-stuff/" ]

        allJsAndTsFilesPattern =
            [ FilePattern.include "**/*.js", FilePattern.include "**/*.ts" ]

        allPatterns =
            dependenciesPatterns ++ allJsAndTsFilesPattern
    in
    Rule.newProjectRuleSchema "NoLooseEquality" initialProjectContext
        |> Rule.withExtraFilesProjectVisitor moduleVisitor allPatterns
        |> Rule.fromProjectRuleSchema


type alias ProjectContext =
    {}


type alias ModuleContext =
    {}


moduleVisitor : Dict String { fileKey : Rule.ExtraFileKey, content : String } -> ProjectContext -> ( List (Rule.Error scope), ProjectContext )
moduleVisitor files context =
    let
        looseEqualityOperators : List { fileKey : Rule.ExtraFileKey, lineData : List { line : String, lineIndex : Int } }
        looseEqualityOperators =
            files
                |> Dict.values
                |> List.map
                    (\file ->
                        { fileKey = file.fileKey, lineData = findlooseEqualityOperatorsLineIndex file.content }
                    )

        rangeBuilder : Int -> String -> Range
        rangeBuilder lineIndex line =
            let
                row =
                    lineIndex + 1

                columnEnd =
                    1 + String.length line
            in
            { start = { row = row, column = 1 }, end = { row = row, column = columnEnd } }
    in
    ( List.concatMap
        (\{ fileKey, lineData } ->
            List.map
                (\{ line, lineIndex } ->
                    Rule.errorForExtraFile
                        fileKey
                        { message = "Loose equality operator found"
                        , details = [ "Use strict equality operator instead" ]
                        }
                        (rangeBuilder
                            lineIndex
                            line
                        )
                )
                lineData
        )
        looseEqualityOperators
    , context
    )


findlooseEqualityOperatorsLineIndex : String -> List { line : String, lineIndex : Int }
findlooseEqualityOperatorsLineIndex content =
    content
        |> String.lines
        |> List.indexedMap
            (\lineIndex line ->
                line
                    |> String.words
                    |> List.filterMap
                        (\word ->
                            if word == "==" || word == "!=" then
                                Just { line = line, lineIndex = lineIndex }

                            else
                                Nothing
                        )
            )
        |> List.concat


initialProjectContext : ProjectContext
initialProjectContext =
    {}


fromProjectToModule : Rule.ContextCreator ProjectContext ModuleContext
fromProjectToModule =
    Rule.initContextCreator
        (\projectContext ->
            {}
        )


fromModuleToProject : Rule.ContextCreator ModuleContext ProjectContext
fromModuleToProject =
    Rule.initContextCreator
        (\moduleContext ->
            {}
        )


foldProjectContexts : ProjectContext -> ProjectContext -> ProjectContext
foldProjectContexts new previous =
    {}


expressionVisitor : Node Expression -> ModuleContext -> ( List (Rule.Error {}), ModuleContext )
expressionVisitor node context =
    case Node.value node of
        _ ->
            ( [], context )
