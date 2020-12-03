//
//  PhotosViewController.swift
//  Foodie Thing
//
//  Created by Tadreik Campbell on 6/25/20.
//  Copyright © 2020 Tadreik Campbell. All rights reserved.
//


import UIKit

final class PhotosViewController: PostViewController {
    
    var posts = [Post]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureHierarchy()
        configureDataSource()
        configureRefreshControl()
        addPosts(to: &posts, from: .followingPhotosOnly)
        DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
            if self.collectionView.isCollectionEmpty() {
                self.collectionView.setEmptyMessage("Follow some chefs and their content will show up here")
            }
        }
    }
    
    func newSnap() {
        sortPosts(&posts)
        var snapshot = NSDiffableDataSourceSnapshot<Section, Post>()
        snapshot.appendSections([.main])
        snapshot.appendItems(posts)
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    func configureRefreshControl () {
        collectionView.refreshControl = UIRefreshControl()
        collectionView.refreshControl?.addTarget(self, action: #selector(handleRefreshControl), for: .valueChanged)
        collectionView.alwaysBounceVertical = true
        collectionView.refreshControl?.tintColor = UIColor(named: "FT Theme")
    }
    
    @objc func handleRefreshControl() {
        posts.removeAll()
        addPosts(to: &posts, from: .followingPhotosOnly)
        DispatchQueue.main.async {
            self.collectionView.refreshControl?.endRefreshing()
        }
    }
    
}

// MARK: - CollectionView Delegate
extension PhotosViewController: UICollectionViewDelegate {
    func createLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout(sectionProvider: {
            (sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            let contentSize = layoutEnvironment.container.effectiveContentSize
            let columns = contentSize.width > 800 ? 4 : 2
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            let groupSize = contentSize.width > 800 ? NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalWidth(0.25)) : NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalWidth(0.5))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: columns)
            group.interItemSpacing = .fixed(10)
            let section = NSCollectionLayoutSection(group: group)
            section.orthogonalScrollingBehavior = .none
            section.interGroupSpacing = CGFloat(10)
            section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
            return section
        })
        return layout
    }
    
    func configureHierarchy() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.showsVerticalScrollIndicator = false
        collectionView.backgroundColor = .systemBackground
        view.addSubview(collectionView)
        collectionView.delegate = self
    }
}

// MARK: - CollectionView Datasource
extension PhotosViewController {
    func configureDataSource() {
        collectionView.register(PostCell.self, forCellWithReuseIdentifier: PostCell.reuseIdentifier)
        dataSource = UICollectionViewDiffableDataSource<Section, Post>(collectionView: collectionView, cellProvider: { (collectionView, indexPath, post) -> UICollectionViewCell? in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PostCell.reuseIdentifier, for: indexPath) as? PostCell
            cell?.post = post
            let processor = DownsamplingImageProcessor(size: (cell?.frame.size)!)
            cell?.image.kf.indicatorType = .activity
            cell?.image.kf.setImage(
                with: URL(string: post.imageurl!),
                placeholder: UIImage(named: "gradient"),
                options: [
                    .processor(processor),
                    .scaleFactor(UIScreen.main.scale),
                    .transition(.fade(0.7)),
                    .cacheOriginalImage
                ])
            return cell
        })
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let item = dataSource.itemIdentifier(for: indexPath)
        let photoVC = storyboard.instantiateViewController(withIdentifier: "photoPostVC") as! PhotoPostViewController
        photoVC.photo = item
        self.show(photoVC, sender: self)
    }
}

// MARK: - Context Mneu for cells
extension PhotosViewController {
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let item = dataSource.itemIdentifier(for: indexPath)!
        let photoMenuConfig = UIContextMenuConfiguration(identifier: nil, previewProvider: nil){ action in
            let report = UIAction(title: "Report", image: UIImage(systemName: "exclamationmark.bubble.fill")) {_ in
                let postData: [String: Any] = [
                    "dateCreated": item.dateCreated!,
                    "videourl": item.videourl!,
                    "imageurl": item.imageurl!,
                    "caption": item.caption!,
                    "tags": item.tags!,
                    "docID": item.docID!,
                    "userDocID": item.userDocID!,
                    "isVideo": item.isVideo!,
                    "storageRef": item.storageRef!
                ]
                db.collection("reports").document(item.docID!).setData(postData, merge: true)
            }
            return UIMenu(title: "", image: nil, identifier: nil, children: [report])
        }
        return photoMenuConfig
    }
}

