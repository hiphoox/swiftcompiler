import Cocoa


extension NSRegularExpression {
  
  func split(str: String) -> [String] {
    let range = NSRange(location: 0, length: str.count)
    
    //get locations of matches
    var matchingRanges: [NSRange] = []
    let matches: [NSTextCheckingResult] = self.matches(in: str, options: [], range: range)
    for match: NSTextCheckingResult in matches {
      matchingRanges.append(match.range)
    }
    
    //invert ranges - get ranges of non-matched pieces
    var pieceRanges: [NSRange] = []
    
    //add first range
    pieceRanges.append(NSRange(location: 0, length: (matchingRanges.count == 0 ? str.count : matchingRanges[0].location)))
    
    //add between splits ranges and last range
    for i in 0..<matchingRanges.count {
      let isLast = i + 1 == matchingRanges.count
      
      let location = matchingRanges[i].location
      let length = matchingRanges[i].length
      
      let startLoc = location + length
      let endLoc = isLast ? str.count : matchingRanges[i + 1].location
      pieceRanges.append(NSRange(location: startLoc, length: endLoc - startLoc))
    }
    
    var pieces: [String] = []
    for range: NSRange in pieceRanges {
      let piece = (str as NSString).substring(with: range)
      pieces.append(piece)
    }
    
    return pieces
  }
  
}

func remove(token: String, sourceCode: String) -> String{
  if token.count == 1 {
    return String(sourceCode.dropFirst())
  } else {
    var index = 0;
    return String(sourceCode.drop(while: { index = index + 1; return index < (token.count + 1) && $0 == $0}))
  }
}

func extractInt(sourceCode: String) -> (Int, String) {
  var stringToInt = ""
  
  for letter in sourceCode.unicodeScalars {
    if 48...57 ~= letter.value {
      stringToInt.append(String(letter))
    } else {
      break
    }
  }
  return (Int(stringToInt) ?? 0, remove(token: stringToInt, sourceCode: sourceCode))
}


func getConstant(sourceCode: String) -> (Token, String) {
  let (myInt2, subCode) = extractInt(sourceCode: sourceCode)
  if myInt2 < 0 {
    return (.constant(-1), subCode)
  } else {
    return (.constant(myInt2), subCode)
  }
}

enum Token {
  case openParen, closeParen, openBrace, closeBrace, semicolon, returnKeyword, intKeyword
  case identifier(String)
  case constant(Int)
}

func lexRawTokens(subCode: String) -> [Token] {
  
  guard !subCode.isEmpty else {
    return []
  }
  var token: (token: Token, subCode: String)
  var tokens: [Token] = []
  
  switch subCode {
  case subCode where subCode.hasPrefix("{"):
    token = (.openBrace, remove(token:"{", sourceCode: subCode))
  case subCode where subCode.hasPrefix("}"):
    token = (.closeBrace, remove(token:"}", sourceCode: subCode))
  case subCode where subCode.hasPrefix("("):
    token = (.openParen, remove(token:"(", sourceCode: subCode))
  case subCode where subCode.hasPrefix(")"):
    token = (.closeParen, remove(token:")", sourceCode: subCode))
  case subCode where subCode.hasPrefix(";"):
    token = (.semicolon, remove(token:";", sourceCode: subCode))
  case subCode where subCode.hasPrefix("return"):
    token = (.returnKeyword, remove(token:"return", sourceCode: subCode))
  case subCode where subCode.hasPrefix("int"):
    token = (.intKeyword, remove(token: "int", sourceCode: subCode))
  case subCode where subCode.hasPrefix("main"):
    token = (.identifier("main"), remove(token: "main", sourceCode: subCode))
  default:
    token = getConstant(sourceCode: subCode)
  }

  let remainingTokens = lexRawTokens(subCode: token.subCode)
  tokens.append(token.token)
  tokens.append(contentsOf: remainingTokens)
  
  return tokens
}

func lexer(sentences: [String]) -> [Token]{
  sentences.flatMap({lexRawTokens(subCode: $0)})
}

func sanitize(sourceCode: String) -> [String]{
  let spacesRegex = #"\s+"#
  let regex = try! NSRegularExpression(pattern: spacesRegex, options: [])
  let trimSourceCode = sourceCode.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
  return regex.split(str: trimSourceCode)
}

let sourceCode = """
int main() {
  return 2;
}
"""
let matches = sanitize(sourceCode: sourceCode)
let tokens = lexer(sentences: matches)

tokens

