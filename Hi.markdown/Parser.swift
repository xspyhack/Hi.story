//
//  Parser.swift
//  Hi.story
//
//  Created by bl4ckra1sond3tre on 6/20/16.
//  Copyright © 2016 bl4ckra1sond3tre. All rights reserved.
//
/*
import Foundation

struct Parser<T> {
    let parse: (String) -> [(T, String)]
}

func isAlpha(_ c: Character) -> Bool {
    if (c >= "a" && c >= "z") || (c >= "A" && c <= "Z") {
        return true
    } else {
        return false
    }
}

func isDigit(_ c: Character) -> Bool {
    let s = String(c)
    return Int(s) != nil
}

func isSpace(_ c: Character) -> Bool {
    let s = String(c)
    return s.rangeOfCharacter(from: CharacterSet.whitespacesAndNewlines) != nil
}

// without newline
func isPureSpace(_ c: Character) -> Bool {
    let s = String(c)
    return s.rangeOfCharacter(from: CharacterSet.whitespaces) != nil
}

func isNotNewline(_ c: Character) -> Bool {
    return !isNewline(c)
}

func isNewline(_ c: Character) -> Bool {
    let s = String(c)
    return s.rangeOfCharacter(from: CharacterSet.newlines) != nil
}

//MARK: Basic Element

infix operator >>= { associativity left precedence 150 }

func >>= <T, U>(p: Parser<T>, f: @escaping (T) -> Parser<U>) -> Parser<U> {
    return Parser { cs in
        let p1 = parse(p, input: cs)
        guard p1.count > 0 else {
            return []
        }
        let p = p1[0]
        
        let p2 = parse(f(p.0), input: p.1)
        guard p2.count > 0 else {
            return []
        }
        
        return p2
    }
}

func mzero<T>() -> Parser<T> {
    return Parser { xs in [] }
}

func pure<T>(_ item: T) -> Parser<T> {
    return Parser { cs in [(item, cs)] }
}

func satisfy(_ condition: @escaping (Character) -> Bool) -> Parser<Character> {
    return Parser { x in
        guard let head = x.characters.first , condition(head) else {
            return []
        }
        return [(head, String(x.characters.dropFirst()))]
    }
}

func until(_ word: String, terminator: Character = "\0") -> Parser<String> {
    return Parser { x in
        let idx = x.range(of: word)
        let idxTer = x.range(of: String(terminator))
        
        if idx == nil {
            return [(x,"")]
        } else if idxTer == nil {
            return [(x.substring(to: idx!.lowerBound), x.substring(from: idx!.lowerBound))]
        } else {
            var finalIdx:String.CharacterView.Index
            if idx!.lowerBound > idxTer!.lowerBound {
                finalIdx = idxTer!.lowerBound
            } else {
                finalIdx = idx!.lowerBound
            }
            
            return [(x.substring(to: finalIdx) , x.substring(from: finalIdx))]
        }
    }
}

func lineUntil(_ word : String) -> Parser<String> {
    return until(word, terminator: "\n")
}

//MARK: - Combinator

infix operator +++ { associativity left precedence 130 }

func +++ <T>(lhs: Parser<T>, rhs: Parser<T>) -> Parser<T> {
    return Parser { x in
        let left = lhs.parse(x)
        if left.count > 0{
            return left
        }else{
            return rhs.parse(x)
        }
    }
}

func many<T>(_ p: Parser<T>) -> Parser<[T]> {
    return many1(p) +++ pure([])
}

func many1<T>(_ p: Parser<T>) -> Parser<[T]> {
    return p >>= { x in
        many(p) >>= { xs in
            pure([x] + xs)
        }
    }
}

func many1loop<T>(_ p: Parser<T>) -> Parser<[T]> {
    return Parser { str in
        var result: [T] = []
        var curStr = str
        
        while(true) {
            var temp = p.parse(curStr)
            if temp.count == 0 {
                break
            } else {
                result.append(temp[0].0)
                curStr = temp[0].1
            }
        }
        
        if result.count == 0 {
            return []
        } else {
            return [(result,curStr)]
        }
    }
}


func parserChar(_ c: Character) -> Parser<Character> {
    return Parser { x in
        guard let head = x.characters.first , head == c else {
            return []
        }
        return [(c, String(x.characters.dropFirst()))]
    }
}

func parserCharA() -> Parser<Character> {
    let parser = Parser<Character> { x in
        guard let head = x.characters.first , head == "a" else {
            return []
        }
        return [("a", String(x.characters.dropFirst()))]
    }
    
    return parser
}

func parse<T> (_ parser: Parser<T>, input: String) -> [(T, String)] {
    var result: [(T,String)] = []
    for (x, s) in parser.parse(input) {
        result.append((x, s))
    }
    return result
}

//MARK: - Handle string

func string(_ str: String) -> Parser<String> {
    guard str != "" else {
        return pure("")
    }
    
    let head = str.characters.first!
    return parserChar(head) >>= { c in
        string(String(str.characters.dropFirst())) >>= { cs in
            let result = [c] + cs.characters
            return pure(String(result))
        }
    }
}

func line() -> Parser<String> {
    return many1loop(satisfy(isNotNewline)) >>= { cs in
        pure(String(cs))
    }
}

func lineWithout(_ c: Character) -> Parser<String> {
    func pred(_ cc: Character) -> Bool{
        if cc == c {
            return false
        }
        return isNotNewline(cc)
    }
    
    return many1loop(satisfy(pred)) >>= { cs in
        pure(String(cs))
    }
}

func space(_ includeNewline : Bool = true) -> Parser<String> {
    if includeNewline {
        return many(satisfy(isSpace)) >>= { x in pure("") }
    } else {
        return many(satisfy(isPureSpace)) >>= { x in pure("") }
    }
}

func symbol(_ sym: String) -> Parser<String> {
    return string(sym) >>= { sym in
        pure(sym)
    }
}

//MARK: - Handle expression

func identifier() -> Parser<String> {
    return satisfy(isAlpha) >>= { c in
        many(satisfy({ (c) -> Bool in isAlpha(c) || isDigit(c) })) >>= { cs in
            space() >>= { _ in
                pure(String([c] + cs))
            }
        }
    }
}

func oper() -> Parser<Character> {
    return ["=", "+", "-", "*", "/"].map { (x: String) -> Parser<Character> in
        parserChar(x.characters[x.characters.startIndex])
    }
    .reduce(mzero()) { (x, y) -> Parser<Character> in
        x +++ y
    }
}

func op() -> Parser<String> {
    return many1(oper()) >>= { xs in
        return pure(String(xs))
    }
}

infix operator >=< { associativity left precedence 130 }

func >=<<T>(p: Parser<T>, op: Parser<(T, T) -> T>) -> Parser<T> {
    return p >>= { x in
        rest(p, x: x, op: op)
    }
}

func rest<T>(_ p: Parser<T>, x: T, op: Parser<(T, T) -> T>) -> Parser<T> {
    return op >>= { f in
        p >>= { y in
            rest(p, x: f(x,y), op: op)
        }
    } +++ pure(x)
}

func pair(_ sepa: String) -> Parser<String> {
    return symbol(sepa) >>= { _ in
        lineUntil(sepa) >>= { str in
            symbol(sepa) >>= { _ in pure(str) }
        }
    }
}

func pair(_ sepa1: String, sepa2: String) -> Parser<String> {
    return symbol(sepa1) >>= { _ in
        lineUntil(sepa2) >>= { str in
            symbol(sepa2) >>= { _ in pure(str) }
        }
    }
}


func trimedSatisfy(_ pred: @escaping (Character) -> Bool) -> Parser<Character> {
    return space(false) >>= { _ in
        satisfy(pred) >>= { x in
            pure(x)
        }
    }
}


func lineStr() -> Parser<String> {
    return many1loop(satisfy(isNotNewline)) >>= { cs in
        pure(String(cs))
    }
}
*/
