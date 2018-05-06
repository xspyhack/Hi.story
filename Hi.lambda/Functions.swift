//
//  Functions.swift
//  Hi.story
//
//  Created by bl4ckra1sond3tre on 03/07/2017.
//  Copyright © 2017 bl4ckra1sond3tre. All rights reserved.
//

import Foundation

/**
 Identity function
 
 - parameter a: A value
 
 - returns: The parameter `a`
 */
public func id<A>(_ a: A) -> A {
    return a
}

/**
 Constant function
 
 - parameter a: A value
 
 - returns: The parameter `a` no matter what it is fed.
 */
public func const<A, B>(_ a: A) -> (B) -> A {
    return { _ in a }
}

/**
 Compose two endomorphisms in left to right order, (f <> g)(x) = g(f(x)) = x |> f |> g.
 Note that this operation is the monoid operation on the set of functions `(A) -> A`.
 
 - parameter f: A function.
 - parameter g: A function.
 
 - returns: A function that is the composition of `f` and `g`.
 */
public func <> <A> (f: @escaping (A) -> A, g: @escaping (A) -> A) -> ((A) -> A) {
    return { g(f($0)) }
}

/**
 Composes two functions in left to right order, (f >>> g)(x) = g(f(x))
 
 - parameter f: A function.
 - parameter g: A function.
 
 - returns: A function that is the composition of `f` and `g`.
 */
public func >>> <A, B, C> (f: @escaping (A) -> B, g: @escaping (B) -> C) -> (A) -> C {
    return { g(f($0)) }
}

/**
 Composes two functions in right to left order, (f <<< g)(x) = f(g(x))
 
 - parameter g: A function
 - parameter f: A function
 
 - returns: A function that is the composition of `f` and `g`.
 */
public func <<< <A, B, C> (g: @escaping (B) -> C, f: @escaping (A) -> B) -> (A) -> C {
    return { g(f($0)) }
}
