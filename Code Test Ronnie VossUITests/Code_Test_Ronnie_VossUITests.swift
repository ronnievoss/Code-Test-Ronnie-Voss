//
//  Code_Test_Ronnie_VossUITests.swift
//  Code Test Ronnie VossUITests
//
//  Created by Ronnie Voss on 10/11/17.
//  Copyright © 2017 Ronnie Voss. All rights reserved.
//

import XCTest

class Code_Test_Ronnie_VossUITests: XCTestCase {
        
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testAddingContact() {
        
        let app = XCUIApplication()
        app.navigationBars["Contacts"].buttons["Add"].tap()
        
        let tablesQuery = app.tables
        tablesQuery.cells.containing(.staticText, identifier:"First Name").children(matching: .textField).element.typeText("John")
        
        let tablesQuery2 = tablesQuery
        tablesQuery2/*@START_MENU_TOKEN@*/.textFields["Last name"]/*[[".cells.textFields[\"Last name\"]",".textFields[\"Last name\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        tablesQuery.cells.containing(.staticText, identifier:"Last Name").children(matching: .textField).element.typeText("Doe")
        tablesQuery2/*@START_MENU_TOKEN@*/.textFields["Birthdate"]/*[[".cells.textFields[\"Birthdate\"]",".textFields[\"Birthdate\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        
        let datePickersQuery = app.datePickers
        datePickersQuery.pickerWheels["October"].swipeDown()
        datePickersQuery.pickerWheels["17"].swipeDown()
        datePickersQuery.pickerWheels["2017"].swipeDown()
        app.toolbars.buttons["Done"].tap()
        app.navigationBars["Add Contact"].buttons["Done"].tap()
        
        
        XCTAssertTrue(tablesQuery.staticTexts["John Doe"].exists)
    }
    
    func testDeletingContact() {
        
        let app = XCUIApplication()
        let editButton = app.navigationBars["Contacts"].buttons["Edit"]
        editButton.tap()
        
        let tablesQuery = app.tables
        tablesQuery.children(matching: .cell).element(boundBy: 1).buttons["Delete John Doe"]/*@START_MENU_TOKEN@*/.press(forDuration: 0.9);/*[[".tap()",".press(forDuration: 0.9);"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        
        let deleteButton = tablesQuery.buttons["Delete"]
        deleteButton.tap()
        
        XCTAssertFalse(tablesQuery.staticTexts["John Doe"].exists)
    }
    
}
