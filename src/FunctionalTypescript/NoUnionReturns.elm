module FunctionalTypescript.NoUnionReturns exposing (rule)

{-| Report when a function don't return a single type. Allow null and undefined in union types.

@docs rule

-}

import Dict exposing (Dict)
import Elm.Syntax.Range as Range exposing (Range)
import List.Extra
import Maybe.Extra
import Regex
import Review.FilePattern as FilePattern
import Review.Rule as Rule exposing (Rule)
import String.Extra


{-| Reports when a function doesn't return a single type. Allows `null` and `undefined` in union types.

    config =
        [ FunctionalTypescript.NoUnionReturns.rule
        ]


## Fail

    function getId(user: User): string | number {
        return user.id;
    }

    function getId(user: User): string | number | null {
        return user.id;
    }


## Success

    function getId(user: User): string {
        return user.id;
    }

    function maybeGetId(user: User): string | null {
        return user.id;
    }


## When to enable this rule

This rule is useful for enforcing a more functional or Elm-like style in your TypeScript files. It allows union types with `null` or `undefined`, which is a common pattern in TypeScript to represent optional values. Custom types defined with union types are also permitted, as complex types often need to be represented as unions.


## Try it out

You can try this rule out by running the following command:

```bash
elm-review --template mateusfpleite/elm-review-functional-javascript/example --rules FunctionalTypescript.NoUnionReturns
```

-}
rule : Rule
rule =
    let
        allTypescriptFilesPattern =
            FilePattern.include "**/*.ts"

        nodeModulesPattern =
            FilePattern.exclude "node_modules/**/*"
    in
    Rule.newProjectRuleSchema "FunctionalTypeScript.NoUnionReturns" initialContext
        |> Rule.withExtraFilesProjectVisitor typescriptFilesVisitor [ allTypescriptFilesPattern, nodeModulesPattern ]
        |> Rule.fromProjectRuleSchema


type alias Context =
    {}


initialContext : Context
initialContext =
    {}


typescriptFilesVisitor : Dict String { fileKey : Rule.ExtraFileKey, content : String } -> Context -> ( List (Rule.Error scope), Context )
typescriptFilesVisitor files context =
    let
        forbiddenUnionTypes : List { fileKey : Rule.ExtraFileKey, unionTypes : List UnionType, rangeBuilder : String -> Range }
        forbiddenUnionTypes =
            files
                |> Dict.values
                |> List.map
                    (\file ->
                        { fileKey = file.fileKey, unionTypes = findForbiddenUnionTypes file.content, rangeBuilder = buildRange file.content }
                    )

        buildRange : String -> String -> Range
        buildRange fileContent line =
            findLineRow line fileContent
                |> Maybe.map (\row -> { start = { row = row, column = 1 }, end = { row = row + lineLength line, column = 1 } })
                |> Maybe.withDefault Range.empty
    in
    ( List.concatMap
        (\{ fileKey, unionTypes, rangeBuilder } ->
            List.map
                (\{ line, unionType } ->
                    Rule.errorForExtraFile
                        fileKey
                        { message = "This function returns a union type: " ++ unionType
                        , details = [ "To keep code reliability and consistency, functions should return single types" ]
                        }
                        (rangeBuilder
                            line
                        )
                )
                unionTypes
        )
        forbiddenUnionTypes
    , context
    )


type alias UnionType =
    { line : String
    , unionType : String
    }


findForbiddenUnionTypes : String -> List UnionType
findForbiddenUnionTypes content =
    let
        getLineAndUnionType : Regex.Match -> UnionType
        getLineAndUnionType match =
            { line = match.match, unionType = getUnionStr match.submatches }

        getUnionStr : List (Maybe String) -> String
        getUnionStr submatches =
            submatches
                |> Maybe.Extra.values
                |> List.Extra.getAt 1
                |> Maybe.andThen excludeUnionNullOrUndefined
                |> Maybe.withDefault ""

        excludeUnionNullOrUndefined : String -> Maybe String
        excludeUnionNullOrUndefined unionStr =
            let
                unionStrList =
                    String.split "|" unionStr

                hasExactlyTwoElements =
                    List.length unionStrList == 2

                hasNullOrUndefined list =
                    List.any (\x -> x == "null" || x == "undefined") list
            in
            if hasExactlyTwoElements && hasNullOrUndefined unionStrList then
                Nothing

            else
                Just unionStr
    in
    content
        |> Regex.find typeScriptReturnTypeSignatureRegex
        |> List.map getLineAndUnionType


findLineRow : String -> String -> Maybe Int
findLineRow currentLine content =
    String.lines content
        |> List.Extra.findIndex
            (\line ->
                let
                    areLinesEqual =
                        normalizeLine line == currentLine

                    currentLineContainsLine =
                        not (String.Extra.isBlank line) && String.startsWith line currentLine
                in
                areLinesEqual
                    || currentLineContainsLine
            )
        |> Maybe.map (\index -> index + 1)


lineLength : String -> Int
lineLength content =
    String.lines content
        |> List.length


typeScriptReturnTypeSignatureRegex : Regex.Regex
typeScriptReturnTypeSignatureRegex =
    -- (function\s+\w+\s*\([^)]*\)\s*:\s*|const\s+\w+\s*=\s*\([^)]*\)\s*:\s*|let\s+\w+\s*=\s*\([^)]*\)\s*:\s*|var\s+\w+\s*=\s*\([^)]*\)\s*:\s*|:\s*|type\s+\w+\s*=\s*\([^)]*\)\s*=>\s*)([a-zA-Z0-9_\[\]\|\s]+?\|[a-zA-Z0-9_\[\]\|\s]+)(?=\s*=>|\s*\{|\s*;|$)
    Regex.fromString "(function\\s+\\w+\\s*\\([^)]*\\)\\s*:\\s*|const\\s+\\w+\\s*=\\s*\\([^)]*\\)\\s*:\\s*|let\\s+\\w+\\s*=\\s*\\([^)]*\\)\\s*:\\s*|var\\s+\\w+\\s*=\\s*\\([^)]*\\)\\s*:\\s*|:\\s*|type\\s+\\w+\\s*=\\s*\\([^)]*\\)\\s*=>\\s*)([a-zA-Z0-9_\\[\\]\\|\\s]+?\\|[a-zA-Z0-9_\\[\\]\\|\\s]+)(?=\\s*=>|\\s*\\{|\\s*;|$)"
        |> Maybe.withDefault Regex.never


normalizeLine : String -> String
normalizeLine line =
    line
        |> Regex.find typeScriptReturnTypeSignatureRegex
        |> List.map (\match -> match.match)
        |> List.head
        |> Maybe.withDefault line
