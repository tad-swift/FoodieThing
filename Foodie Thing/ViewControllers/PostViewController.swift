//
//  PostViewController.swift
//  Foodie Thing
//
//  Created by Tadreik Campbell on 12/3/20.
//

import UIKit
import Firebase
import Stevia


class PostViewController: UIViewController {
    
    enum Section: CaseIterable {
        case main
    }
    
    enum PostsCollectionType: CaseIterable {
        case singleUserAll,
             followingVideosOnly,
             followingPhotosOnly
    }
    
    var dataSource: UICollectionViewDiffableDataSource<Section, Post>!
    
    var collectionView: UICollectionView!
    
    var query: Query!
    
    var documents = [QueryDocumentSnapshot]()
    
    var users = [User]()
    
    /**
     Grabs `Post` objects from Firestore
     - Parameters:
     - list: The array the post objects will be added to.
     - userDocID: Firestore document ID of the user object
     - collectionType: The type of posts to load
     */
    func addPosts(to list: UnsafeMutablePointer<[Post]>, from collectionType: PostsCollectionType, userDocID: String = "", completion: @escaping () -> (Void)) {
        func newSnap() {
            //sortPosts(&list.pointee)
            var snapshot = NSDiffableDataSourceSnapshot<Section, Post>()
            snapshot.appendSections([.main])
            snapshot.appendItems(list.pointee)
            dataSource.apply(snapshot, animatingDifferences: true)
        }
        let view = UIView(frame: CGRect(x: 0, y: 0, width: collectionView.bounds.width, height: collectionView.bounds.height))
        let indicator = UIActivityIndicatorView()
        let loadingLabel = UILabel()
        indicator.style = .large
        indicator.startAnimating()
        loadingLabel.numberOfLines = 0
        loadingLabel.font = .systemFont(ofSize: 15)
        loadingLabel.textColor = .systemGray
        view.sv([indicator, loadingLabel])
        indicator.centerInContainer()
        loadingLabel.centerInContainer()
        collectionView.backgroundView = view
        
        switch collectionType {
            case .followingVideosOnly:
                if myUser.following.isNotEmpty {
                    for docID in myUser.following {
                        query = db.collection("users").document(docID).collection("posts")
                            .order(by: "dateCreated", descending: true).whereField("isVideo", isEqualTo: true)
                            .limit(to: 16)
                        query.getDocuments() { (querySnapshot, err) in
                            if let err = err {
                                log.debug("Error getting documents: \(err as NSObject)")
                                self.collectionView.setEmptyMessage("There was an error loading the posts")
                                completion()
                            } else {
                                for doc in querySnapshot!.documents {
                                    let postItem = try! doc.data(as: Post.self)!
                                    list.pointee.append(postItem)
                                    self.documents += [doc]
                                    newSnap()
                                }
                                self.collectionView.backgroundView = nil
                                completion()
                            }
                        }
                    }
                }
                
            case .singleUserAll:
                query.getDocuments() { (querySnapshot, err) in
                    if let err = err {
                        log.debug("Error getting documents: \(err as NSObject)")
                        self.collectionView.setEmptyMessage("There was an error loading the posts")
                        completion()
                    } else {
                        for doc in querySnapshot!.documents {
                            let postItem = try! doc.data(as: Post.self)!
                            list.pointee.append(postItem)
                            self.documents += [doc]
                            newSnap()
                        }
                        self.collectionView.backgroundView = nil
                        completion()
                    }
                }
            case .followingPhotosOnly:
                if myUser.following.isNotEmpty  {
                    for docID in myUser.following {
                        query = db.collection("users").document(docID).collection("posts")
                            .order(by: "dateCreated", descending: true).whereField("isVideo", isEqualTo: false)
                            .limit(to: 16)
                        query.getDocuments() { (querySnapshot, err) in
                            if let err = err {
                                log.debug("Error getting documents: \(err as NSObject)")
                                self.collectionView.setEmptyMessage("There was an error loading the posts")
                                completion()
                            } else {
                                for doc in querySnapshot!.documents {
                                    let postItem = try! doc.data(as: Post.self)
                                    list.pointee.append(postItem!)
                                    self.documents += [doc]
                                    newSnap()
                                }
                                self.collectionView.backgroundView = nil
                                completion()
                            }
                        }
                    }
                }
        }
        
    }
    
    /**
     Grabs the next set of`Post` objects from Firestore.
     - Important: `addPosts()` must be used before this function
     - Parameters:
     - list: The array the post objects will be added to
     - userDocID: Firestore document ID of the user object
     - collectionType: The type of posts to load
     */
    func paginate(to list: UnsafeMutablePointer<[Post]>, from collectionType: PostsCollectionType, userDocID: String = "") {
        query = query.start(afterDocument: documents.last!).limit(to: 16)
        addPosts(to: &list.pointee, from: collectionType, userDocID: userDocID, completion: {})
    }
    
}


