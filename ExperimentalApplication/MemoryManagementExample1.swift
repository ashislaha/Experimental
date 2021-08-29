//
//  MemoryManagementExample1.swift
//  ExperimentalApplication
//
//  Created by Ashis Laha on 29/08/21.
//

import UIKit

class RedViewcontroller: UIViewController {
	
	private lazy var greenVC: GreenViewcontroller = {
		
		let controller = GreenViewcontroller()
		controller.backClosure = { [weak self] in
			self?.updateTitle("RedVC - coming from Green VC")
		}
		return controller
	}()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		updateTitle("RedVC is initialisd first time")
		view.backgroundColor = .red
		
		navigationItem.rightBarButtonItem = UIBarButtonItem(title: "green",
															style: .plain,
															target: self,
															action: #selector(openGreen))
	}

	@objc private func openGreen() {
		
		navigationController?.pushViewController(greenVC, animated: true)
	}
	
	private func updateTitle(_ message: String) {
		title = message
	}
	
	deinit {
		print("deallocating Red ViewController")
	}
}

class GreenViewcontroller: UIViewController {
	
	public var backClosure: (() -> Void)?
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		title = "Green View"
		view.backgroundColor = .green
		
		navigationItem.leftBarButtonItem = UIBarButtonItem(title: "back",
														   style: .plain,
														   target: self,
														   action: #selector(backButtonTappd))
	}
	
	@objc private func backButtonTappd() {
		backClosure?()
		navigationController?.popViewController(animated: true)
	}
	
	deinit {
		print("deallocating green view")
	}
}
