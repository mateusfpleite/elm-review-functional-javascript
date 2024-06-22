# elm-review-functional-javascript

Provides [`elm-review`](https://package.elm-lang.org/packages/jfmengels/elm-review/latest/) rules to enforce functional style in javascript/typescript.

## Provided rules

- [`FunctionalJavascript.NoLooseEquality`](https://package.elm-lang.org/packages/mateusfpleite/elm-review-functional-javascript/1.0.0/NoLooseEquality) - Reports uses of `==` and `!==` in javascript and typescript files.
- [`FunctionalTypescript.NoUnionReturns`](https://package.elm-lang.org/packages/mateusfpleite/elm-review-functional-javascript/1.0.0/FunctionalTypescript-NoUnionReturns) - Reports functions that return union types.

## Configuration

```elm
module ReviewConfig exposing (config)

import FunctionalTypescript.NoUnionReturns
import FunctionalJavascript.NoLooseEquality
import Review.Rule exposing (Rule)

config : List Rule
config =
    [ FunctionalTypescript.NoUnionReturns.rule
    , FunctionalJavascript.NoLooseEquality.rule
    ]
```

## Try it out

You can try the example configuration above out by running the following command:

```bash
elm-review --template mateusfpleite/elm-review-functional-javascript/example
```
