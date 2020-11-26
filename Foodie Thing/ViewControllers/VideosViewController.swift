//
//  VideosViewController.swift
//  Foodie Thing
//
//  Created by Tadreik Campbell on 6/19/20.
//  Copyright © 2020 Tadreik Campbell. All rights reserved.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth
import AVKit

class VideosViewController: UIViewController, UICollectionViewDelegate {
    
    enum Section: CaseIterable {
        case main
    }
    
    var dataSource: UICollectionViewDiffableDataSource<Section, Post>!
    
    var collectionView: UICollectionView!
    
    var videos = [Post]()
    
    var db: Firestore!
    
    var user: User! {
        didSet {
            if user.following!.isNotEmpty {
                addVideosFromFollowing()
            }
        }
    }
    
    var currentUser: String?
    
    var mediaHeight: CGFloat!
    
    var mediaWidth: CGFloat!
    
    let defaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureHierarchy()
        configureDataSource()
        configureRefreshControl()
        addFTVideos()
        addVideos()
    }
    
    func sortVideos() {
        videos = videos.sorted { (lhs: Post, rhs: Post) -> Bool in
            return lhs.dateCreated!.dateValue() > rhs.dateCreated!.dateValue()
        }
    }
    
    func addFTVideos() {
        db = Firestore.firestore()
        db.collection("videos").whereField("isVideo", isEqualTo: true).getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    let docRef = self.db.collection("videos").document(document.documentID)
                    docRef.getDocument { (document, _) in
                        if let video = document.flatMap({
                            $0.data().flatMap({ (data) in
                                return Post(dictionary: data)
                            })
                        }) {
                            self.videos.append(video)
                            
                        } else {
                            print("Document does not exist")
                        }
                        self.newSnap()
                    }
                }
            }
        }
    }
    
    func addVideos() {
        db = Firestore.firestore()
        db.collection("posts").whereField("isVideo", isEqualTo: true).getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    let docRef = self.db.collection("posts").document(document.documentID)
                    docRef.getDocument { (document, _) in
                        if let video = document.flatMap({
                            $0.data().flatMap({ (data) in
                                return Post(dictionary: data)
                            })
                        }) {
                            self.videos.append(video)
                            
                        } else {
                            print("Document does not exist")
                        }
                        self.newSnap()
                    }
                }
            }
        }
    }
    
    func addVideosFromFollowing() {
        db = Firestore.firestore()
        for docID in user.following! {
            db.collection("users").document(docID).collection("posts").whereField("isVideo", isEqualTo: true).getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    for document in querySnapshot!.documents {
                        let docRef = self.db.collection("posts").document(document.documentID)
                        docRef.getDocument { (document, _) in
                            if let post = document.flatMap({
                                $0.data().flatMap({ (data) in
                                    return Post(dictionary: data)
                                })
                            }) {
                                self.videos.append(post)
                            } else {
                                print("Document does not exist")
                            }
                            self.newSnap()
                        }
                    }
                }
            }
        }
    }
    
    func configureRefreshControl () {
        collectionView.refreshControl = UIRefreshControl()
        collectionView.refreshControl?.addTarget(self, action: #selector(handleRefreshControl), for: .valueChanged)
        collectionView.alwaysBounceVertical = true
        collectionView.refreshControl?.tintColor = UIColor(named: "FT Theme")
    }
    
    @objc func handleRefreshControl() {
        newSnap()
        DispatchQueue.main.async {
            self.collectionView.refreshControl?.endRefreshing()
        }
    }
    
    func newSnap() {
        sortVideos()
        var snapshot = NSDiffableDataSourceSnapshot<Section, Post>()
        snapshot.appendSections([.main])
        snapshot.appendItems(videos)
        dataSource.apply(snapshot, animatingDifferences: true)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let item = dataSource.itemIdentifier(for: indexPath)
        let videoVC = storyboard.instantiateViewController(withIdentifier: "videoPostVC") as! VideoPostViewController
        videoVC.video = item
        videoVC.aspectRatio = getVideoResolution(url: item!.videourl!)
        self.show(videoVC, sender: self)
    }
    
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let item = self.dataSource.itemIdentifier(for: indexPath)!
        let videoMenuConfig = UIContextMenuConfiguration(identifier: nil, previewProvider: nil){ action in
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
                self.db.collection("reports").document(item.docID!).setData(postData, merge: true)
            }
            
            return UIMenu(title: "", image: nil, identifier: nil, children: [report])
        }
        return videoMenuConfig
    }
    
    func createLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout(sectionProvider: {
            (sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            let contentSize = layoutEnvironment.container.effectiveContentSize
            let columns = contentSize.width > 800 ? 3 : 2
            
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            let groupSize = contentSize.width > 800 ? NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalWidth(0.3)) : NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalWidth(0.5))
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
        collectionView.backgroundColor = .systemBackground
        view.addSubview(collectionView)
        collectionView.delegate = self
    }
    
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
                    .transition(.fade(0.3)),
                    .cacheOriginalImage
                ])
            return cell
        })
    }
    
}
