//
//  ImprovingAppPerformanceExperiment.swift
//  ExperimentalApplication
//
//  Created by Ashis Laha on 23/08/21.
//

import UIKit

// Memory manageement - retain cycle through object holding, closure,






// discuss how table view datasource and delegate is solved. table view should be weak in a view controller
// check how to observe leaks -- memory allocation, xcode --> edit scheme --> memory stack trace

// EXAMPLE - 2
class TableContainerController: UIViewController {
	
	var dataSource: [String] = ["Bangalore", "Hyderabad", "Mumbai"]
	
	var tableView: UITableView! {
		didSet {
			tableView.delegate = self
			tableView.dataSource = self
			tableView.backgroundColor = .brown
		}
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		title = "Testing with Table View"
		
		tableView = UITableView(frame: view.bounds, style: .plain)
		view.addSubview(tableView)
		tableView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
		tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
		
		tableView.rowHeight = UITableView.automaticDimension
		tableView.estimatedRowHeight = 44
	}
	
	deinit {
		print("deallocating controller")
	}
}

extension TableContainerController: UITableViewDelegate, UITableViewDataSource {
	
	func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return dataSource.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
		
		var defaultContentConfiguration = cell.defaultContentConfiguration()
		defaultContentConfiguration.text = dataSource[indexPath.row]
		cell.contentConfiguration = defaultContentConfiguration
		
		return cell
	}
}
