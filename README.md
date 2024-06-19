# elm-review-functional-typescript

Provides [`elm-review`](https://package.elm-lang.org/packages/jfmengels/elm-review/latest/) rules to REPLACEME.

## Provided rules

- [`FunctionalTypescript.NoUnionReturns`](https://package.elm-lang.org/packages/mateusfpleite/elm-review-functional-typescript/1.0.0/FunctionalTypescript-NoUnionReturns) - Reports REPLACEME.

## Configuration

```elm
module ReviewConfig exposing (config)

import FunctionalTypescript.NoUnionReturns
import Review.Rule exposing (Rule)

config : List Rule
config =
    [ FunctionalTypescript.NoUnionReturns.rule
    ]
```

## Try it out

You can try the example configuration above out by running the following command:

```bash
elm-review --template mateusfpleite/elm-review-functional-typescript/example
```
