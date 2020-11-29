//
//  SettingsViewController.swift
//  Foodie Thing
//
//  Created by Tadreik Campbell on 6/30/19.
//  Copyright © 2019 Tadreik Campbell. All rights reserved.

import UIKit

final class IconPickerViewController: UIViewController {
    
    enum Section: String, CaseIterable {
        case main = "Alternate Icons"
    }
    
    struct Icon: Hashable {
        let name: String!
        let image: String!
        let id = UUID()
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(id)
        }
    }
    
    var collectionView: UICollectionView!
    
    var dataSource: UICollectionViewDiffableDataSource<Section, Icon>!

    var icons = [
        Icon(name: "Current", image: "1 Classic"),
        Icon(name: "Mango", image: "2 Mango"),
        Icon(name: "Tropics", image: "3 Tropics"),
        Icon(name: "Purple", image: "4 Purple"),
        Icon(name: "Coral", image: "5 Coral"),
        Icon(name: "Berry", image: "6 Berry"),
        Icon(name: "Deep", image: "7 Deep"),
        Icon(name: "Gray", image: "8 Gray"),
        Icon(name: "Classic Pink", image: "9 Classic Pink"),
        Icon(name: "Lights Out", image: "10 Lights Out")
    ]
    

    override func viewDidLoad() {
        super.viewDidLoad()
        configureHierarchy()
        configureDataSource()
        newSnap()
    }
    
    func newSnap() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Icon>()
        snapshot.appendSections([.main])
        snapshot.appendItems(icons, toSection: .main)
        dataSource.apply(snapshot, animatingDifferences: false)
    }
    
    func changeIcon(to iconName: String) {
        guard UIApplication.shared.supportsAlternateIcons else {
            return
        }
        UIApplication.shared.setAlternateIconName(iconName, completionHandler: { (error) in
            if let error = error {
                log.debug("App icon failed to change due to \(error.localizedDescription)")
            } else {
                log.debug("App icon changed successfully")
            }
        })
    }
    
}

// MARK: - CollectionView Delegate
extension IconPickerViewController: UICollectionViewDelegate {
    func createLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout(sectionProvider: {
            (sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            let contentSize = layoutEnvironment.container.effectiveContentSize
            let columns = contentSize.width > 800 ? 2 : 1
            
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(70))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: columns)
            group.interItemSpacing = .fixed(10)
            let section = NSCollectionLayoutSection(group: group)
            section.orthogonalScrollingBehavior = .none
            section.interGroupSpacing = CGFloat(10)
            section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 20)
            return section
        })
        return layout
    }
    
    func configureHierarchy() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.backgroundColor = .systemBackground
        view.addSubview(collectionView)
        collectionView.delegate = self
    }
}

// MARK: - CollectionView Datasource
extension IconPickerViewController {
    func configureDataSource() {
        collectionView.register(IconCell.self, forCellWithReuseIdentifier: IconCell.reuseIdentifier)
        collectionView.register(IconHeaderView.self, forSupplementaryViewOfKind: regularHeaderElementKind, withReuseIdentifier: IconHeaderView.reuseIdentifier)
        dataSource = UICollectionViewDiffableDataSource<Section, Icon>(collectionView: collectionView, cellProvider: { (collectionView, indexPath, icon) -> UICollectionViewCell? in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: IconCell.reuseIdentifier, for: indexPath) as! IconCell
            cell.image.image = UIImage(named: icon.image)
            cell.label.text = icon.name
            return cell
        })
        
        dataSource.supplementaryViewProvider = { (collectionView: UICollectionView, kind: String, indexPath: IndexPath) -> UICollectionReusableView? in
            let supplementaryView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: IconHeaderView.reuseIdentifier, for: indexPath) as? IconHeaderView
            supplementaryView?.label.text = "Alternate Icons"
            return supplementaryView
            
        }
        
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if pref.bool(forKey: "SwitchState") == true {
            let selection = UISelectionFeedbackGenerator()
            selection.selectionChanged()
        }
        changeIcon(to: (dataSource.itemIdentifier(for: indexPath)?.name)!)
    }
}
