//
//  ExperimentalApplicationTests.swift
//  ExperimentalApplicationTests
//
//  Created by Ashis Laha on 21/08/21.
//

import XCTest
@testable import ExperimentalApplication

class ExperimentalApplicationTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
		let model = TestableModel()
		
        self.measure {
            // Put the code you want to measure the time of here.
			let sum = model.addNumber(10,20)
			print(sum)
        }
    }

}

extension ExperimentalApplicationTests {
	
	func testAddNumber() {
		let model = TestableModel()
		let sum = model.addNumber(10,20)
		let isCorrect = sum == 30
		XCTAssertTrue(isCorrect)
		
		let add2 = model.addNumber(2, 3)
		XCTAssertEqual(add2, 5, "Both are not equal")
		
	}
	
	func testGoogleServerHit() {		
		
		let promise = expectation(description: "status code: 200")
		let model = TestableModel()
		model.asyncGoogleServerHit { isSuccess in
			if isSuccess {
				promise.fulfill()
			} else {
				XCTFail("Error")
			}
		}
		
		/*
		let promise = expectation(description: "status code: 200")
		let url = URL(string: "https://www.google.com")!
		
		let dataTask = URLSession.shared.dataTask(with: url) { data, response, error in
			if error != nil {
				XCTFail("Error: \(error?.localizedDescription ?? "")")
			}
			
			if let response = response as? HTTPURLResponse {
				if response.statusCode == 200 {
					promise.fulfill()
					
				} else {
					XCTFail("status code: \(response.statusCode)")
				}
			}
		}
		dataTask.resume()
		*/
		
		wait(for: [promise], timeout: 3.0)
	}
}
