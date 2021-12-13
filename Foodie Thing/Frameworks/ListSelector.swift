//
//  ListSelector.swift
//  TC Icon Selector
//
//  Created by Tadreik Campbell on 1/22/21.
//

import UIKit

open class ListSelector: UIViewController {
    
    private let regularHeaderElementKind = "regular-header-element-kind"
    
    private enum Section: String, CaseIterable {
        case main = "Alternate Icons"
    }
    
    private var collectionView: UICollectionView!
    
    private var dataSource: UICollectionViewDiffableDataSource<Section, Icon>!
    
    public var icons: [Icon] = [] {
        didSet {
            configureHierarchy()
            configureDataSource()
            newSnap()
        }
    }
    
    private func newSnap() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Icon>()
        snapshot.appendSections([.main])
        snapshot.appendItems(icons, toSection: .main)
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
    
    private func configureHierarchy() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.backgroundColor = .systemBackground
        view.addSubview(collectionView)
        collectionView.delegate = self
    }
}

// MARK: - CollectionView Datasource
extension ListSelector {
    private func configureDataSource() {
        collectionView.register(ListIconCell.self, forCellWithReuseIdentifier: ListIconCell.reuseIdentifier)
        collectionView.register(IconHeaderView.self, forSupplementaryViewOfKind: regularHeaderElementKind, withReuseIdentifier: IconHeaderView.reuseIdentifier)
        dataSource = UICollectionViewDiffableDataSource<Section, Icon>(collectionView: collectionView, cellProvider: { (collectionView, indexPath, icon) -> UICollectionViewCell? in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ListIconCell.reuseIdentifier, for: indexPath) as! ListIconCell
            cell.image.image = UIImage(named: icon.image)
            cell.label.text = icon.name
            return cell
        })
        
        dataSource.supplementaryViewProvider = { (collectionView: UICollectionView, kind: String, indexPath: IndexPath) -> UICollectionReusableView? in
            let supplementaryView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: IconHeaderView.reuseIdentifier, for: indexPath) as? IconHeaderView
            supplementaryView?.label.text = Section.allCases[indexPath.section].rawValue
            return supplementaryView
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        changeIcon(to: dataSource.itemIdentifier(for: indexPath)!.image)
    }
}

