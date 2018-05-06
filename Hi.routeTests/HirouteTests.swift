//
//  HirouteTests.swift
//  HirouteTests
//
//  Created by bl4ckra1sond3tre on 18/03/2018.
//  Copyright © 2018 bl4ckra1sond3tre. All rights reserved.
//

import XCTest
@testable import Hiroute

class HirouteTests: XCTestCase {
    
    enum Navigation {
        enum Feed {
            case list
            case feed(id: String)
            case add
        }
        
        enum Matter {
            case list
            case matter(id: String)
            case add
        }
        
        enum Storybook {
            case list
            case story(id: String)
        }
        
        case feed(Feed)
        
        case matter(Matter)
        
        case storybook(Storybook)
        
        case settings
    }
    
    let baseURL = "https://www.blessingsoft.com"
    
    override func setUp() {
        super.setUp()
        
        Router.shared.hosts = ["www.blessingsoft.com", "www.blessingsoftware.com"]
        Router.shared.schemes = ["hi", "history", "story"]
        
        let settings = Route("/settings")
        let feeds = Route("/feed")
        let feed = Route("/feed/:id")
        let matter = Route("/matter/:id")
        
        Array([settings, feeds, feed, matter]).forEach {
            Router.add($0)
        }
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
        let url = URL(string: "https://www.blessingsoft.com/feed")!
        XCTAssertEqual(Router.canRoute(url), true)
        
        let url1 = URL(string: "/feed")!
        XCTAssertEqual(Router.canRoute(url1), false)
        
        let url2 = URL(string: "hi://feed")!
        XCTAssertEqual(Router.canRoute(url2), true)
    }
    
    func testMatch() {
        let url = URL(string: baseURL + "/feed/233")!
        XCTAssertEqual(Router.match(url)!, .object(["id": .string("233")]))
        
        let url1 = URL(string: baseURL + "/feeds/233")!
        XCTAssertNil(Router.match(url1))
    }
    
    func testRoute() {
        let expectation = XCTestExpectation(description: "Route handler")
        
        let url = URL(string: "hi://route/233")!
        
        let route = Route("/route/:id") { params in
            XCTAssert(params == .object(["id": .string("233")]))
            
            expectation.fulfill()
        }
        
        Router.add(route)
        Router.route(url)
        
        wait(for: [expectation], timeout: 10.0)
    }
    
    func testRouteWithParams() {
        let expectation = XCTestExpectation(description: "Route handler")
        
        let url = URL(string: "hi://route/233")!
        
        let route = Route("/route/:id") { params in
            XCTAssert(params == .object(["id": .string("233"), "query": .string("query")]))
            
            expectation.fulfill()
        }
        Router.add(route)
        Router.route(url, withParams: .object(["query": .string("query")]))
        
        wait(for: [expectation], timeout: 12.0)
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
            
            Router.route(URL(string: "hi://feed")!, withParams: .object(["query": .string("query")]))
        }
    }
    
}
