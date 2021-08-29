//
//  CollectionViewController.swift
//  ExperimentalApplication
//
//  Created by Ashis Laha on 21/08/21.
//

import UIKit

enum LayoutType: Int {
	case verticalMixture = 0
	case horizontalHalfImages = 1
}

class CollectionViewController: UICollectionViewController {
	
	public var dataSource = ["a", "b", "c", "d"]
	public var sections: [LayoutType] = [.verticalMixture, .horizontalHalfImages]
	
	init() {
		super.init(collectionViewLayout: compositionalLayout)
	}
	
	private let model = TestableModel()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		collectionView.backgroundColor = .white
		collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
		collectionView.register(UICollectionReusableView.self, forSupplementaryViewOfKind: "header", withReuseIdentifier: "header")
		
		testing()
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	private let compositionalLayout: UICollectionViewCompositionalLayout = {
	
		let contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2)
		
		// If we want to return different layout for different section, we can do that
		let layout = UICollectionViewCompositionalLayout { sectionIndex, layoutEnvironment in
			
			if sectionIndex == LayoutType.verticalMixture.rawValue {
				
				// type-1
				// full width and height = 2/3 of its width  HORIZONTALLY
				let itemSize = NSCollectionLayoutSize(widthDimension: NSCollectionLayoutDimension.fractionalWidth(1),
													  heightDimension: .fractionalWidth(2/3))
				let fullItem = NSCollectionLayoutItem(layoutSize: itemSize)
				fullItem.contentInsets = contentInsets
				
				let fullWidthGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
																heightDimension: .fractionalWidth(2/3))
				let fullWidthGroup = NSCollectionLayoutGroup.horizontal(layoutSize: fullWidthGroupSize,
																		subitems: [fullItem])
				
				
				// type-2
				// 2/3 width of single photo and 1/3 of two photos
				let type2MainItemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(2/3),
															   heightDimension: .fractionalHeight(1.0))
				let type2MainItem = NSCollectionLayoutItem(layoutSize: type2MainItemSize)
				type2MainItem.contentInsets = contentInsets
				
				
				
				// trailing group contains 2 images VERTICALLY
				let type2PairItemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
															   heightDimension: .fractionalHeight(1/2))
				let type2PairItem = NSCollectionLayoutItem(layoutSize: type2PairItemSize)
				type2PairItem.contentInsets = contentInsets
				
				let trailingGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1/3),
															   heightDimension: .fractionalHeight(1))
				let trailingGroup = NSCollectionLayoutGroup.vertical(layoutSize: trailingGroupSize, subitem: type2PairItem, count: 2)
				
				
				
				// mainWithPairGroup HORIZONTALLY
				let mainWithPairGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
																   heightDimension: .fractionalWidth(2/3))
				let mainWithPairGroup = NSCollectionLayoutGroup.horizontal(layoutSize: mainWithPairGroupSize,
																		   subitems: [type2MainItem, trailingGroup])
				
				
				// final nested group VERTICALLY
				let finalGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
															heightDimension: .fractionalWidth(2)) // double of width
				let finalGroup = NSCollectionLayoutGroup.vertical(layoutSize: finalGroupSize,
																  subitems: [fullWidthGroup, mainWithPairGroup])
				
				
				// set supplementry view
				let headerViewSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
															heightDimension: NSCollectionLayoutDimension.absolute(40))
				let headerView = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerViewSize,
																			 elementKind: "header",
																			 alignment: .top)
				
				
				let section = NSCollectionLayoutSection(group: finalGroup)
				section.boundarySupplementaryItems = [headerView]
				
				return section
				
			} else {
				
				// Horizontal scrollable section
				// half width and height = 2/3 of its width  HORIZONTALLY
				let itemSize = NSCollectionLayoutSize(widthDimension: NSCollectionLayoutDimension.fractionalWidth(1/2),
													  heightDimension: .fractionalWidth(1/2))
				let halfItem = NSCollectionLayoutItem(layoutSize: itemSize)
				halfItem.contentInsets = contentInsets
				
				let halfItemGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
																heightDimension: .fractionalWidth(2/3))
				let halfItemGroup = NSCollectionLayoutGroup.horizontal(layoutSize: halfItemGroupSize,
																		subitems: [halfItem])
				
				
				let section = NSCollectionLayoutSection(group: halfItemGroup)
				section.orthogonalScrollingBehavior = .groupPaging
				
				
				// set supplementry view
				let headerViewSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
															heightDimension: NSCollectionLayoutDimension.absolute(40))
				let headerView = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerViewSize,
																			 elementKind: "header",
																			 alignment: .top)
				section.boundarySupplementaryItems = [headerView]
				
				return section
				
			}
		}
			
		return layout
	}()
	
	
	// data source
	override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return dataSource.count
	}
	
	override func numberOfSections(in collectionView: UICollectionView) -> Int {
		return sections.count
	}
	
	override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
		cell.backgroundColor = (indexPath.row % 2 == 0) ? .brown : .green
		return cell
	}
	
	override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {

		let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "header", for: indexPath)
		view.backgroundColor = .yellow
		let label = UILabel()
		label.textAlignment = .center
		label.text = "Header \(indexPath.section) section"
		label.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(label)
		NSLayoutConstraint.activate([
			label.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			label.trailingAnchor.constraint(equalTo: view.trailingAnchor),
			label.bottomAnchor.constraint(equalTo: view.bottomAnchor),
			label.topAnchor.constraint(equalTo: view.topAnchor)
		])
		return view

	}
	
}

// MARK:- Testing on Memory Management, navigationBar, navigationItem etc.

extension CollectionViewController {
	
	private func testing() {
		navigaitonBarAndNavigationItemTesting()
		let _ = ExceptionHandling()
	}
	
	private func navigaitonBarAndNavigationItemTesting() {
		navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: nil)
		navigationItem.title = "Testing"
		
		navigationController?.navigationBar.barTintColor = .white
		
		// as navigation bar is managed by navigation controller, we cannot push a new navigation item directly to navigation bar.
		// Instead of that we can update the controller navigation item.
		
		let newNavigationItem = UINavigationItem(title: "New Item")
		newNavigationItem.leftBarButtonItems = [
			UIBarButtonItem(barButtonSystemItem: .bookmarks, target: self, action: nil),
			UIBarButtonItem(barButtonSystemItem: .camera, target: self, action: nil),
		]
		newNavigationItem.rightBarButtonItems = [
			UIBarButtonItem(title: "M1", style: .plain, target: self, action: #selector(openRedGreenFlow)),
			UIBarButtonItem(title: "M2", style: .plain, target: self, action: #selector(showTable)),
			
		]
		
		navigationItem.leftBarButtonItems = newNavigationItem.leftBarButtonItems
		navigationItem.rightBarButtonItems = newNavigationItem.rightBarButtonItems
		navigationItem.prompt = "This is a prompt"
	}
	
	
	@objc private func openRedGreenFlow() {
		let redVC = RedViewcontroller()
		navigationController?.pushViewController(redVC, animated: true)
	}
	
	@objc private func showTable() {
		let table = TableContainerController()
		navigationController?.pushViewController(table, animated: true)
	}
	
}
