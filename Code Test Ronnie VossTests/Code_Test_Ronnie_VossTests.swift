//
//  Code_Test_Ronnie_VossTests.swift
//  Code Test Ronnie VossTests
//
//  Created by Ronnie Voss on 10/11/17.
//  Copyright © 2017 Ronnie Voss. All rights reserved.
//

import XCTest
import CoreData
@testable import Contacts

class Code_Test_Ronnie_VossTests: XCTestCase {
    
    let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testLastInitial() {
        let contact = Contact(context: context)
        contact.firstName = "John"
        contact.lastName = "Doe"
        
        XCTAssertEqual(contact.lastInitial, "D")
    }
    
    func testLastInitialUppercase() {
        let contact = Contact(context: context)
        contact.firstName = "John"
        contact.lastName = "lowercase"
        
        XCTAssertEqual(contact.lastInitial, "L")
    }
    
    func testLastInitialIfNil() {
        let contact = Contact(context: context)
        contact.firstName = "John"
        contact.lastName = nil
        
        XCTAssertEqual(contact.lastInitial, "")
    }
    
    func testAddressFormatting() {
        let address = Address(context: context)
        XCTAssertEqual(address.formattedAddress, "")
        
        address.addressLine1 = "1234 Street"
        XCTAssertEqual(address.formattedAddress, "1234 Street")
        
        address.city = "Fort Worth"
        XCTAssertEqual(address.formattedAddress, "1234 Street\nFort Worth")
        
        address.state = "TX"
        XCTAssertEqual(address.formattedAddress, "1234 Street\nFort Worth, TX")
        
        address.zipcode = "90210"
        XCTAssertEqual(address.formattedAddress, "1234 Street\nFort Worth, TX 90210")
        
        address.addressLine2 = "Apt 1234"
        XCTAssertEqual(address.formattedAddress, "1234 Street\nApt 1234\nFort Worth, TX 90210")
    }
    
}
