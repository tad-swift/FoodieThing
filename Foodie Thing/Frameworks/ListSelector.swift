//
//  ListSelector.swift
//  TC Icon Selector
//
//  Created by Tadreik Campbell on 1/22/21.
//

import UIKit

public class ListSelector: UIViewController {
    
    private let regularHeaderElementKind = "regular-header-element-kind"
    
    public var sections: [String] = ["Alternate Icons"]
    
    public lazy var collectionView: UICollectionView = {
        let v = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
        v.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        v.backgroundColor = .systemBackground
        v.delegate = self
        return v
    }()
    
    private var dataSource: UICollectionViewDiffableDataSource<String, Icon>!
    
    public var icons: [Icon] = [] {
        didSet {
            configureDataSource()
            newSnap()
        }
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(collectionView)
    }
    
    private func newSnap() {
        var snapshot = NSDiffableDataSourceSnapshot<String, Icon>()
        snapshot.appendSections(sections)
        for section in sections {
            snapshot.appendItems(icons.filter { $0.section == section }, toSection: section)
        }
        dataSource.apply(snapshot, animatingDifferences: false)
    }
    
    private func changeIcon(to iconName: String) {
        guard UIApplication.shared.supportsAlternateIcons else {
            print("App icon change not supported")
            return
        }
        UIApplication.shared.setAlternateIconName(iconName, completionHandler: { error in
            if let error = error {
                print("App icon failed to change due to \(error.localizedDescription)")
            } else {
                print("App icon changed successfully")
            }
        })
    }
    
}

// MARK: - CollectionView Delegate
extension ListSelector: UICollectionViewDelegate {
    private func createLayout() -> UICollectionViewLayout {
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
            let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(44))
            let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: self.regularHeaderElementKind, alignment: .topLeading)
            section.boundarySupplementaryItems = [sectionHeader]
            return section
        })
        return layout
    }
}

// MARK: - CollectionView Datasource
extension ListSelector {
    private func configureDataSource() {
        let iconcell = UICollectionView.CellRegistration<ListIconCell, Icon> { cell, _, icon in
            cell.image.image = UIImage(named: icon.image)
            cell.label.text = icon.name
        }
        let header = UICollectionView.SupplementaryRegistration<IconHeaderView>(elementKind: regularHeaderElementKind) { view, _, indexPath in
            view.label.text = self.sections[indexPath.section]
        }
        
        dataSource = UICollectionViewDiffableDataSource<String, Icon>(collectionView: collectionView, cellProvider: { (collectionView, indexPath, icon) -> UICollectionViewCell? in
            return collectionView.dequeueConfiguredReusableCell(using: iconcell, for: indexPath, item: icon)
        })
        
        dataSource.supplementaryViewProvider = { (collectionView: UICollectionView, kind: String, indexPath: IndexPath) -> UICollectionReusableView? in
            return collectionView.dequeueConfiguredReusableSupplementary(using: header, for: indexPath)
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        changeIcon(to: dataSource.itemIdentifier(for: indexPath)!.image)
    }
}

