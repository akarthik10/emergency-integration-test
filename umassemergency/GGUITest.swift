//
//  GGUITest.swift
//  UMassEmergency
//
//  Created by Karthik A on 3/31/17.
//  Copyright © 2017 University of Massachusetts. All rights reserved.
//

import XCTest

class GGUITest: XCTestCase {
        
    let app = XCUIApplication()
    
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        app.launch()
        
        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        app.buttons["location"].tap();
        
        let goLabel = app.otherElements["My Location"]
        //XCTAssertTrue(goLabel.exists)
        let exists = NSPredicate(format: "exists == true")
        expectation(for: exists, evaluatedWith: goLabel, handler: nil)
        
        
        app.buttons["location"].tap()
        waitForExpectations(timeout: 10, handler: nil)
        XCTAssert(goLabel.exists)
        
        let goLabel2 = app.otherElements["Test notification"]
        expectation(for: exists, evaluatedWith: goLabel2, handler: nil)
        
        app.maps.element.pinch(withScale: 0.05, velocity: -0.05)
        
        //app.buttons["location"].tap()
        waitForExpectations(timeout: 1200, handler: nil)
        XCTAssert(goLabel2.exists)
        
        app.buttons["list"].tap()
        
        
    }
    
}
