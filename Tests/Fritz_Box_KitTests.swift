//
//  Fritz_Box_KitTests.swift
//  Fritz!Box KitTests
//
//  Created by Roman Gille on 25.12.17.
//  Copyright © 2017 Roman Gille. All rights reserved.
//

import XCTest
import AEXML
@testable import FritzBoxKit

class MappingTests: XCTestCase {
    
    var xmlData: Data!
    
    override func setUp() {
        super.setUp()
        
        if let path = Bundle(for: MappingTests.self).path(forResource: "devices", ofType: "xml") {
            xmlData = try? Data(contentsOf: URL(fileURLWithPath: path))
        }
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testObjectMapping() {
        guard let xml = try? AEXMLDocument(xml: xmlData)
            else { XCTFail("No XML data"); return }
        
        XCTAssertEqual(xml.root.children.count, 4, "Device number count should be correct")
        
        let mappedDevices = xml.root.children
            .compactMap{ $0.xmlCompact }
            .compactMap{ FritzBox.SmartHomeDevice(XMLString: $0) }
        
        XCTAssertEqual(mappedDevices.count, xml.root.children.count, "Mapped Device number count should match")
        
        for (index, device) in mappedDevices.enumerated() {
            
            if let radiatorRegulator = device.hkr {
                XCTAssertEqual(device.temperature?.celsius, radiatorRegulator.current, "Measured temperatures schould match")
            }
            
            switch index {
            case 1: // Radiator regulator.
                XCTAssertEqual(device.displayName, "Kinderzimmer", "Display name should match.")
                XCTAssertEqual(device.temperature?.celsius, 22, "Temp. should match.")
                XCTAssertEqual(device.temperature?.offset, 0, "Temp. should match.")
                XCTAssertEqual(device.features, [.temperatureSensor, .radiatorRegulator], "Features should match")
                
                XCTAssertEqual(device.hkr?.current, 22, "Temp. should match.")
                XCTAssertEqual(device.hkr?.target, 24, "Temp. should match.")
                XCTAssertEqual(device.hkr?.low, 16, "Temp. should match.")
                XCTAssertEqual(device.hkr?.high, 24, "Temp. should match.")
                
                XCTAssertEqual(device.hkr?.locked, true, "Value should be true.")
                XCTAssertEqual(device.hkr?.lockedByDevice, nil, "Value should be missing")
                XCTAssertEqual(device.hkr?.error, .movementProblem, "Error code should match.")
                XCTAssertEqual(device.hkr?.batteryLow, true, "Value should match.")
                
            case 2: // Radiator regulator.
                XCTAssertEqual(device.displayName, "Küche", "Display name should match.")
                XCTAssertEqual(device.temperature?.celsius, 23, "Temp. should match.")
                XCTAssertEqual(device.temperature?.offset, 0, "Temp. should match.")
                XCTAssertEqual(device.features, [.temperatureSensor, .radiatorRegulator], "Features should match")
                
                XCTAssertEqual(device.hkr?.current, 23, "Temp. should match.")
                XCTAssertEqual(device.hkr?.target, 24, "Temp. should match.")
                XCTAssertEqual(device.hkr?.low, 16, "Temp. should match.")
                XCTAssertEqual(device.hkr?.high, 24, "Temp. should match.")
                
                XCTAssertEqual(device.hkr?.locked, nil, "Value should be missing")
                XCTAssertEqual(device.hkr?.lockedByDevice, true, "Value should be true.")
                XCTAssertEqual(device.hkr?.error, .adjusting, "Error code should match.")
                XCTAssertEqual(device.hkr?.batteryLow, false, "Value should match.")
                
            case 3: // Power switch.
                XCTAssertEqual(device.productName, "FRITZ!DECT 200", "Product name should match.")
                XCTAssertEqual(device.displayName, "Steckdose", "Display name should match.")
                XCTAssertEqual(device.features, [.temperatureSensor, .powerSwitch, .energySensor], "Features should match")
                
                XCTAssertEqual(device.temperature?.celsius, 28.5, "Temp. should match.")
                XCTAssertEqual(device.temperature?.offset, 0, "Offset should match.")
                
                XCTAssertEqual(device.powerSwitch?.state, true, "State should match.")
                XCTAssertEqual(device.powerSwitch?.mode, FritzBox.PowerSwitch.Mode.auto, "Mode should be auto.")
                XCTAssertEqual(device.powerSwitch?.lockedBySoftware, false, "Value should be present and false.")
                XCTAssertEqual(device.powerSwitch?.lockedByDevice, true, "Should be true.")

                XCTAssertNotNil(device.powerMeter, "Powermeter should exist")
                XCTAssertEqual(device.powerMeter?.energy, 5.419, "Energy should match")
                
            default: // First element in the list.
                XCTAssertEqual(device.displayName, "Wohnzimmer", "Display name should match.")
                XCTAssertEqual(device.temperature?.celsius, 24.5, "Temp. should match.")
                XCTAssertEqual(device.temperature?.offset, -20, "Temp. should match.")
                XCTAssertEqual(device.features, [.temperatureSensor, .radiatorRegulator], "Features should match")
                
                XCTAssertEqual(device.hkr?.current, 24.5, "Temp. should match.")
                XCTAssertEqual(device.hkr?.target, 24, "Temp. should match.")
                XCTAssertEqual(device.hkr?.low, 16, "Temp. should match.")
                XCTAssertEqual(device.hkr?.high, 24, "Temp. should match.")
                
                XCTAssertEqual(device.hkr?.locked, false, "Value should be present and false.")
                XCTAssertEqual(device.hkr?.lockedByDevice, false, "Value should be present and false.")
                XCTAssertEqual(device.hkr?.error, .noError, "Error code should match.")
                XCTAssertEqual(device.hkr?.batteryLow, false, "Value should match.")
            }
        }
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
