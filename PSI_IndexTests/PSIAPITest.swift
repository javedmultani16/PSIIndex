//
//  PSIAPITest.swift
//  PSI_IndexTests
//
//  Created by javedmultani16 on 19/11/19.
//  Copyright © 2019 Javed Multani. All rights reserved.
//

import XCTest
@testable import PSI_Index

class PSIAPITest: XCTestCase {
    func testAPIWorking() {
        var expectation: XCTestExpectation? = self.expectation(description: "success")
        APIHelper().getPSIData { (data) in
            if data == nil {
                XCTFail("Fail")
                expectation?.fulfill()
            } else {
                if let _ = data?["region_metadata"] as? [[String: Any]] {
                    XCTAssertTrue(true)
                    XCTAssertNotNil("success")
                    expectation?.fulfill()
                    expectation = nil
                } else {
                    XCTFail("Fail")
                    expectation?.fulfill()
                }
            }
        }
        self.waitForExpectations(timeout: 10) //TIME OUT
    }
    
    
}
