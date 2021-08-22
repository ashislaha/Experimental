//
//  URLSessionExperiment.swift
//  ExperimentalApplication
//
//  Created by Ashis Laha on 22/08/21.
//

import Foundation

/// In this file, we will create a tiny network layer and explore more on URLSession

class NetworkLayer: NSObject {
	
	
	// https://developer.apple.com/documentation/foundation/urlsession
	// with session you create a task which can upload data to server or download data from server.
	// URLSession provides 4 types of task
	// 1. Data task which sends and receives data from server
	// 2. Upload task which are similar to data task but used for upload and supports background uploads while app is not running
	// 3. download task retrieves the data in the form of file and supports background download
	// 4. websocket tasks exchange the messages over TCP and TLS
	
	// URLSessionDelegate handles authentication challenges, data become available for caching.
	
	func getData(urlRequest: URLRequest,
				 successBlock: ((Data) -> Void)?,
				 failureBlock: ((Error?) -> Void)?) {
		
		
		let sessionConfiguration = URLSessionConfiguration.default
		let session = URLSession(configuration: sessionConfiguration, delegate: self, delegateQueue: OperationQueue())
		
		let task = session.dataTask(with: urlRequest) { data, response, error in
			
			if let error = error {
				failureBlock?(error)
			}
			
			if let response = response as? HTTPURLResponse,
			   response.statusCode == 200 || response.statusCode == 201,
			   let data = data {
				successBlock?(data)
			} else {
				failureBlock?(error)
			}
		}
		task.resume()
	}
}

// Protocol inheritance like below
// URLSessionDelegate
// URLSessionTaskDelegate: URLSessionDelegate

// URLSessionDataDelegate: URLSessionTaskDelegate
// URLSessionDownloadDelegate: URLSessionTaskDelegate
// URLSessionStreamDelegate: URLSessionTaskDelegate
// URLSessionWebSocketDelegate: URLSessionTaskDelegate

extension NetworkLayer: URLSessionDownloadDelegate {
	
	func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
		print("download completed")
	}
	
	func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
		
		let percentage = (Double(bytesWritten)/Double(totalBytesExpectedToWrite)) * 100.0
		print("total --> \(totalBytesExpectedToWrite), received --> \(bytesWritten), percentage = \(percentage)")
	}
}

