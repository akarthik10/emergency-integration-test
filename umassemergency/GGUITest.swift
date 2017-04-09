//
//  GGUITest.swift
//  UMassEmergency
//
//  Created by Karthik A on 3/31/17.
//  Copyright © 2017 University of Massachusetts. All rights reserved.
//

import XCTest

extension XCUIElement {
    /**
     Removes any current text in the field before typing in the new value
     - Parameter text: the text to enter into the field
     */
    func clearAndEnterText(text: String) -> Void {
        guard let stringValue = self.value as? String else {
            XCTFail("Tried to clear and enter text into a non string value")
            return
        }
        
        self.tap()
        
        let deleteString = stringValue.characters.map { _ in XCUIKeyboardKeyDelete }.joined(separator: "")
        
        self.typeText(deleteString)
        self.typeText(text)
    }
}

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
        
        
        
        app.navigationBars["UMass Emergency"].buttons["info"].tap()
        app.navigationBars["About 1.0 (24)"].buttons["Normal"].tap()
        
        let tablesQuery2 = app.tables
        let tablesQuery = tablesQuery2
        tablesQuery.staticTexts["Developer Settings"].tap()
        tablesQuery.staticTexts["GNS"].tap()
        
        let textField = tablesQuery2.cells.containing(.button, identifier:"Done").children(matching: .textField).element
        textField.tap()
        
        textField.clearAndEnterText(text: "24303")
        
        let textField2 = tablesQuery2.children(matching: .cell).element(boundBy: 8).children(matching: .textField).element
        textField2.tap()
        textField2.clearAndEnterText(text: "http://localhost:8000/backend")
        tablesQuery.buttons["Done"].tap()
        
        let textField3 = tablesQuery2.children(matching: .cell).element(boundBy: 6).children(matching: .textField).element
        textField3.tap()
        textField3.clearAndEnterText(text: "localhost")
        tablesQuery2.staticTexts["GNS Host"].tap()
        tablesQuery.staticTexts["Reload GNS Data"].tap()
        

        app.navigationBars["GNS Status"].buttons["Developer Settings"].tap()
        app.navigationBars["Developer Settings"].buttons["About 1.0 (24)"].tap()
        app.navigationBars["About 1.0 (24)"].buttons["Done"].tap()
        
        
        
        
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
