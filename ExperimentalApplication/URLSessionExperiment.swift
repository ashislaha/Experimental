//
//  URLSessionExperiment.swift
//  ExperimentalApplication
//
//  Created by Ashis Laha on 22/08/21.
//

import Foundation
import UIKit

/// In this file, we will create a tiny network layer and explore more on URLSession

class NetworkLayer: NSObject {
	
	
	/// https://developer.apple.com/documentation/foundation/urlsession
	// with session you create a task which can upload data to server or download data from server.
	// URLSession provides 4 types of task
	
	// 1. Data task which sends and receives data from server
	// 2. Upload task which are similar to data task but used for upload and supports background uploads while app is not running
	// 3. download task retrieves the data in the form of file and supports background download
	// 4. websocket tasks exchange the messages over TCP and TLS
	
	// URLSessionDelegate handles authentication challenges, data become available for caching.
	// URLSessionConfiguration
	
	var dataTask: URLSessionDataTask?
	
	func getData(urlRequest: URLRequest,
				 successBlock: ((Data) -> Void)?,
				 failureBlock: ((Error?) -> Void)?) {
		
		// There are 3 types of sesion configuration --> 1. default 2. ephemeral 3. background
		// 1. default -- it saves cache, credentials and cookies storage into disk (file system)
		// 2. ephemeral (short-lived) -- it saves cache, credentials and cookies storage into memory.
		// 3. background(with id) -- upload and download happens in background even if the app is terminated or suspended.
		
		// Session Configuration has Cookies storage, URL credential storage, URL cache etc. We can configure them as per need.
		// we can set up time-out value, http request headers, cache policy etc.
		let sessionConfiguration = URLSessionConfiguration.default
		
		// now we created a background session configuration, we need to handle it App Delegate
		// when a OS daemon launches the app in background and handled the downloaded data.
		let backgroundSessionConfiguration = URLSessionConfiguration.background(withIdentifier: "experimental")
		
		//sessionConfiguration.httpCookieStorage
		//sessionConfiguration.urlCredentialStorage
		//sessionConfiguration.urlCache
		

		let session = URLSession(configuration: sessionConfiguration, delegate: self, delegateQueue: OperationQueue())
		
		
		// Session can create multiple tasks (URLSessionTask <-- abstract class) and we can cancel, resume, suspend a task.
		
		// Session task type:
		// 1. URLSessionDataTask: (GET request to retrieve the data from servers to memory)
		// 2. URLSessionUploadTask: (POST/PUT -- this is used to upload a file from disk to server)
		// 3. URLSessionDownloadTask: (GET -- to download a file from server to a temporary file location)
		
		// URLSession returns the value via completion hanlder and via delegates. In completion hanlder,
		// we get error or final data whereas in delegate we can get intermediate updates.
		
		dataTask?.cancel()
		dataTask = session.dataTask(with: urlRequest) { data, response, error in
			
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
		
		dataTask?.resume()
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
		
		print("download completed to location \(location)")
		
		// you should move this file from this location to a document directory location (inside a sandbox)
		// genrally this location belongs to a temporary directory and can be cleaned up soon.
		
		let fileManager = FileManager.default
		if fileManager.fileExists(atPath: location.absoluteString) {
			if let documentDirectoryURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {
				do {
					try fileManager.moveItem(at: documentDirectoryURL, to: location)
				} catch let error {
					print("file transfer error: \(error.localizedDescription)")
				}
			}
		}
	}
	
	func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
		
		let percentage = (Double(bytesWritten)/Double(totalBytesExpectedToWrite)) * 100.0
		print("total --> \(totalBytesExpectedToWrite), received --> \(bytesWritten), percentage = \(percentage)")
	}
	
	// Background execution
	func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
		
		if let appDelegate = UIApplication.shared.delegate as? AppDelegate,
		   let completionHandler = appDelegate.backgroundExecutionCompletionHandler {
			
			DispatchQueue.main.async {
				appDelegate.backgroundExecutionCompletionHandler = nil
				completionHandler()
			}
		}
	}
}

