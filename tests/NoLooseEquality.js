function alwaysReturnFirstIf(input) {
    if (input == 0) {
        return "Input is zero";
    } else if (input == "") {
        return "Input is an empty string";
    } else if (input == false) {
        return "Input is false";
    } else {
        return ("Input is something else");
    }
}
