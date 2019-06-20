import SPMUtility

do {
    let parser = ArgumentParser(commandName: "Compiler", usage: "filename [--output binary_name]", overview: "Compiler takes a C file and compiles it. By default the executable will have the same file name as the input but you can specify another one ")
    let input = parser.add(option: "--output", shortName: "-o", kind: String.self, usage: "Executable file name", completion: .filename)
    let filename = parser.add(positional: "filename", kind: String.self)

    let args = Array(CommandLine.arguments.dropFirst())
    let result = try parser.parse(args)

    guard let codeFile = result.get(filename) else {
        throw ArgumentParserError.expectedArguments(parser, ["filename"])
    }

    print("Compiling \(codeFile) …")

    if let wordsFilename = result.get(input) {
        print("Using \(wordsFilename) as the output binary file name.")
    } else {
        print("Using \(codeFile.dropLast(2)) as the output binary file name.")
    }
} catch ArgumentParserError.expectedValue(let value) {
    print("Missing value for argument \(value).")
} catch ArgumentParserError.expectedArguments(let parser, let stringArray) {
    print("Missing arguments: \(stringArray.joined()).")
} catch {
    print(error.localizedDescription)
}

