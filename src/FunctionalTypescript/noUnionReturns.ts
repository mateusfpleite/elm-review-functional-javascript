// simple ts calculator

type Operator = "+" | "-" | "*" | "/";

function nameToOperator(name: string): "+" | "-" | "*" | "/" | null {
    switch (name) {
        case "add":
            return "+";
        case "subtract":
            return "-";
        case "multiply":
            return "*";
        case "divide":
            return "/";
        default:
            return null;
    }
}

type Calculator = (a: number, b: number, op: Operator) => string | number;

const calculator: Calculator = (a, b, op) => {
    switch (op) {
        case "+":
            return a + b;
        case "-":
            return a - b;
        case "*":
            return a * b;
        case "/":
            return b === 0 ? "cannot divide by zero" : a / b;
    }
};

// functional calculator that always returns same type

type FunctionalCalculator = (
    a: number,
    b: number,
    op: Operator
) => number | string;

const functionalCalculator: FunctionalCalculator = (a, b, op) => {
    switch (op) {
        case "+":
            return a + b;
        case "-":
            return a - b;
        case "*":
            return a * b;
        case "/":
            return b === 0 ? Infinity : a / b;
    }
};

// inline type signature

const inlineCalculator = (
    a: number,
    b: number,
    op: Operator
): number | string => {
    switch (op) {
        case "+":
            return a + b;
        case "-":
            return a - b;
        case "*":
            return a * b;
        case "/":
            return b == 0 ? Infinity : a / b;
    }
};

function declaredCalculator(
    a: number,
    b: number,
    op: Operator
): number | string {
    switch (op) {
        case "+":
            return a + b;
        case "-":
            return a - b;
        case "*":
            return a * b;
        case "/":
            return b == 0 ? Infinity : a / b;
    }
}

(a: number, b: number, op: Operator): number | string => {
    switch (op) {
        case "+":
            return a + b;
        case "-":
            return a - b;
        case "*":
            return a * b;
        case "/":
            return b == 0 ? Infinity : a / b;
    }
};

// inside let

let letCalculator = (a: number, b: number, op: Operator): number | string => {
    switch (op) {
        case "+":
            return a + b;
        case "-":
            return a - b;
        case "*":
            return a * b;
        case "/":
            return b == 0 ? Infinity : a / b;
    }
};

// inside var

var varCalculator = (a: number, b: number, op: Operator): number | string => {
    switch (op) {
        case "+":
            return a + b;
        case "-":
            return a - b;
        case "*":
            return a * b;
        case "/":
            return b == 0 ? Infinity : a / b;
    }
};
