//
//  PostViewController.swift
//  Foodie Thing
//
//  Created by Tadreik Campbell on 12/3/20.
//

import UIKit


class PostViewController: UIViewController {
    
    enum Section: CaseIterable {
        case main
    }
    
    enum PostsCollectionType: CaseIterable {
        case singleUserVideosOnly,
             singleUserPhotosOnly,
             singleUserAll,
             followingVideosOnly,
             followingPhotosOnly,
             followingAll
    }
    
    var dataSource: UICollectionViewDiffableDataSource<Section, Post>!
    
    var collectionView: UICollectionView!
    
    /**
     Grabs `Post` objects from Firestore
     - Parameters:
        - list: The array the post objects will be added to.
        - userDocID: Firestore document ID of the user object
        - collectionType: The type of posts to load
        - collectionView: The collectionView the function will do operations on.
        - dataSource: The datasource `UICollectionViewDiffableDataSource` of the collectionView.
     */
    func addPosts(to list: UnsafeMutablePointer<[Post]>, from collectionType: PostsCollectionType, userDocID: String = "") {
        func newSnap() {
            self.sortPosts(&list.pointee)
            var snapshot = NSDiffableDataSourceSnapshot<Section, Post>()
            snapshot.appendSections([.main])
            snapshot.appendItems(list.pointee)
            dataSource.apply(snapshot, animatingDifferences: true)
        }
        let indicator = UIActivityIndicatorView()
        indicator.style = .large
        collectionView.backgroundView = indicator
        indicator.startAnimating()
        switch collectionType {
        case .followingVideosOnly:
            if myUser.following!.isNotEmpty || myUser.following != nil {
                for docID in myUser.following! {
                    db.collection("users").document(docID).collection("posts").whereField("isVideo", isEqualTo: true).getDocuments() { (querySnapshot, err) in
                        if let err = err {
                            self.collectionView.setEmptyMessage("There was an error loading the posts")
                            log.debug("Error getting documents: \(err as NSObject)")
                        } else {
                            for document in querySnapshot!.documents {
                                let docRef = db.collection("users").document(docID).collection("posts").document(document.documentID)
                                docRef.getDocument { (document, _) in
                                    if let post = document.flatMap({
                                        $0.data().flatMap({ (data) in
                                            return Post(dictionary: data)
                                        })
                                    }) {
                                        list.pointee.append(post)
                                    } else {
                                        log.debug("Document does not exist")
                                    }
                                    self.collectionView.backgroundView = nil
                                    newSnap()
                                }
                            }
                        }
                    }
                }
            }
        
        case .singleUserVideosOnly:
            db.collection("users").document(userDocID).collection("posts").whereField("isVideo", isEqualTo: true).getDocuments() { (querySnapshot, err) in
                if let err = err {
                    self.collectionView.setEmptyMessage("There was an error loading this user's posts")
                    log.debug("Error getting documents: \(err as NSObject)")
                } else {
                    for document in querySnapshot!.documents {
                        let docRef = db.collection("users").document(userDocID).collection("posts").document(document.documentID)
                        docRef.getDocument { (document, _) in
                            if let post = document.flatMap({
                                $0.data().flatMap({ (data) in
                                    return Post(dictionary: data)
                                })
                            }) {
                                list.pointee.append(post)
                            } else {
                                log.debug("Document does not exist")
                            }
                            self.collectionView.backgroundView = nil
                            newSnap()
                        }
                    }
                }
            }
        case .singleUserPhotosOnly:
            db.collection("users").document(userDocID).collection("posts").whereField("isVideo", isEqualTo: false).getDocuments() { (querySnapshot, err) in
                if let err = err {
                    self.collectionView.setEmptyMessage("There was an error loading this user's posts")
                    log.debug("Error getting documents: \(err as NSObject)")
                } else {
                    for document in querySnapshot!.documents {
                        let docRef = db.collection("users").document(userDocID).collection("posts").document(document.documentID)
                        docRef.getDocument { (document, _) in
                            if let post = document.flatMap({
                                $0.data().flatMap({ (data) in
                                    return Post(dictionary: data)
                                })
                            }) {
                                list.pointee.append(post)
                            } else {
                                log.debug("Document does not exist")
                            }
                            self.collectionView.backgroundView = nil
                            newSnap()
                        }
                    }
                }
            }
        case .singleUserAll:
            db.collection("users").document(userDocID).collection("posts").getDocuments() { (querySnapshot, err) in
                if let err = err {
                    self.collectionView.setEmptyMessage("There was an error loading this user's posts")
                    log.debug("Error getting documents: \(err as NSObject)")
                } else {
                    for document in querySnapshot!.documents {
                        let docRef = db.collection("users").document(userDocID).collection("posts").document(document.documentID)
                        docRef.getDocument { (document, _) in
                            if let post = document.flatMap({
                                $0.data().flatMap({ (data) in
                                    return Post(dictionary: data)
                                })
                            }) {
                                list.pointee.append(post)
                            } else {
                                log.debug("Document does not exist")
                            }
                            self.collectionView.backgroundView = nil
                            newSnap()
                        }
                    }
                }
            }
        case .followingPhotosOnly:
            if myUser.following!.isNotEmpty || myUser.following != nil {
                for docID in myUser.following! {
                    db.collection("users").document(docID).collection("posts").whereField("isVideo", isEqualTo: false).getDocuments() { (querySnapshot, err) in
                        if let err = err {
                            self.collectionView.setEmptyMessage("There was an error loading the posts")
                            log.debug("Error getting documents: \(err as NSObject)")
                        } else {
                            for document in querySnapshot!.documents {
                                let docRef = db.collection("users").document(docID).collection("posts").document(document.documentID)
                                docRef.getDocument { (document, _) in
                                    if let post = document.flatMap({
                                        $0.data().flatMap({ (data) in
                                            return Post(dictionary: data)
                                        })
                                    }) {
                                        list.pointee.append(post)
                                    } else {
                                        log.debug("Document does not exist")
                                    }
                                    self.collectionView.backgroundView = nil
                                    newSnap()
                                }
                            }
                        }
                    }
                }
            }
        case .followingAll:
            if myUser.following!.isNotEmpty || myUser.following != nil {
                for docID in myUser.following! {
                    db.collection("users").document(docID).collection("posts").getDocuments() { (querySnapshot, err) in
                        if let err = err {
                            self.collectionView.setEmptyMessage("There was an error loading the posts")
                            log.debug("Error getting documents: \(err as NSObject)")
                        } else {
                            for document in querySnapshot!.documents {
                                let docRef = db.collection("users").document(docID).collection("posts").document(document.documentID)
                                docRef.getDocument { (document, _) in
                                    if let post = document.flatMap({
                                        $0.data().flatMap({ (data) in
                                            return Post(dictionary: data)
                                        })
                                    }) {
                                        list.pointee.append(post)
                                    } else {
                                        log.debug("Document does not exist")
                                    }
                                    self.collectionView.backgroundView = nil
                                    newSnap()
                                }
                            }
                        }
                    }
                }
            }
        }
        
    }
}
