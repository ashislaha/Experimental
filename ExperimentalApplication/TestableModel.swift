//
//  TestableModel.swift
//  ExperimentalApplication
//
//  Created by Ashis Laha on 22/08/21.
//

import Foundation

class TestableModel {
	
	public func addNumber(_ a: Int, _ b: Int) -> Int { return a + b }
	
	public func asyncGoogleServerHit(completionBlock: @escaping (Bool) -> Void) {
		
		let url = URL(string: "https://www.google.com")!
		let sessionDataTask = URLSession.shared.dataTask(with: url) { data, response, error in
			
			if error != nil {
				completionBlock(false)
			}
			
			guard let response = response as? HTTPURLResponse else {
				completionBlock(false)
				return
			}
			
			if response.statusCode == 200 || response.statusCode == 201 {
				// success
				completionBlock(true)
			} else {
				// failure
				completionBlock(false)
			}
		}
		sessionDataTask.resume()
	}
	
}
