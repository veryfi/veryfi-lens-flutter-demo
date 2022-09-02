//
//  veryfi_wrapper_tests.swift
//  veryfi_wrapper_tests
//
//  Created by sgiraldog.
//

import XCTest
@testable import veryfi
import VeryfiLens

class veryfi_wrapper_tests: XCTestCase {
    
    func testUIColorHexString() {
        let black = UIColor(hexString: "#000000")
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        
        black.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        XCTAssert(red == 0)
        XCTAssert(green == 0)
        XCTAssert(blue == 0)
        XCTAssert(alpha == 1)
    }
    
    func testCredentials(){
        let credentials = VeryfiLensCredentials.init(dictionary: MockData.credentials)
        
        XCTAssertNotNil(credentials)
        XCTAssert(credentials.apiKey == "apiKey")
        XCTAssert(credentials.username == "username")
        XCTAssert(credentials.clientId == "123")
        XCTAssert(credentials.url == "endpointUrl")
    }
    
    func testSettings(){
        let settings = VeryfiLensSettings.init(dictionary: MockData.settings)
        
        XCTAssertNotNil(settings)
        XCTAssert(settings?.blurDetectionIsOn == false)
        XCTAssert(settings?.emailCCDomain == "@veryfi.com")
        XCTAssert(settings?.originalImageMaxSizeInMB == Float(2.0))
        XCTAssertNotNil(settings?.docDetectFillUIColor)
        XCTAssert(settings?.dataExtractionEngine.rawValue == 0)
    }
    
}
