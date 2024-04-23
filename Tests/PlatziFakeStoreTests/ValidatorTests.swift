//
//  ValidatorTests.swift
//
//
//  Created by Илья Шаповалов on 23.04.2024.
//

import XCTest
@testable import Validator

final class ValidatorTests: XCTestCase {
    func test_validateEmail() {
        XCTAssertFalse(Validator.isValid(email: "baz"), "email must contains @")
        XCTAssertFalse(Validator.isValid(email: "@baz"), "@ cant't be first symbol")
        XCTAssertFalse(Validator.isValid(email: "baz@"), "@ cant,t be last symbol")
        XCTAssertFalse(Validator.isValid(email: "b@z"), "email should contains . after @")
        XCTAssertFalse(Validator.isValid(email: "baz@."), ". can't be last symbol")
        XCTAssertTrue(Validator.isValid(email: "baz@bar.foo"), "should be range between @ and .")
    }
}
