//
//  Fritz_Box_KitTests.swift
//  Fritz!Box KitTests
//
//  Created by Roman Gille on 25.12.17.
//  Copyright © 2017 Roman Gille. All rights reserved.
//

import XCTest
import AEXML
@testable import Fritz_Box_Kit

class Fritz_Box_KitTests: XCTestCase {
    
    var xmlData: Data!
    
    override func setUp() {
        super.setUp()
        
        if let path = Bundle(for: Fritz_Box_KitTests.self).path(forResource: "devices", ofType: "xml") {
            xmlData = try? Data(contentsOf: URL(fileURLWithPath: path))
        }
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        guard let xml = try? AEXMLDocument(xml: xmlData)
            else { XCTFail("No XML data"); return }
        
        XCTAssertEqual(xml.root.children.count, 3, "Device number count should be correct")
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
