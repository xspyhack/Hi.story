//
//  Operators.swift
//  Hi.story
//
//  Created by bl4ckra1sond3tre on 03/07/2017.
//  Copyright © 2017 bl4ckra1sond3tre. All rights reserved.
//

import Foundation

precedencegroup MonadicPrecedence {
    associativity: left
    higherThan: AssignmentPrecedence
    lowerThan: LogicalDisjunctionPrecedence
}

precedencegroup AlternativePrecedence {
    associativity: left
    higherThan: LogicalConjunctionPrecedence
    lowerThan: ComparisonPrecedence
}

precedencegroup ApplicativePrecedence {
    associativity: left
    higherThan: AlternativePrecedence
    lowerThan: NilCoalescingPrecedence
}

precedencegroup ApplicativeSequencePrecedence {
    associativity: left
    higherThan: ApplicativePrecedence
    lowerThan: NilCoalescingPrecedence
}

precedencegroup CompositionPrecedence {
    associativity: right
    higherThan: ApplicativePrecedence
}

//: choice
infix operator <|> : AlternativePrecedence

//: map
infix operator <^> : ApplicativePrecedence

//: apply
infix operator <*> : ApplicativePrecedence

//: flatMap
infix operator >>- : MonadicPrecedence

//: concat
infix operator <> : CompositionPrecedence

//: compose forward operator
infix operator >>> : CompositionPrecedence

//: compose backward operator
infix operator <<< : CompositionPrecedence
