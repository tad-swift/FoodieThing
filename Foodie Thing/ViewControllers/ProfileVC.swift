//
//  ProfileVC.swift
//  Foodie Thing
//
//  Created by Tadreik Campbell on 5/20/20.
//  Copyright © 2020 Tadreik Campbell. All rights reserved.
//


import UIKit
import AVKit
import FirebaseFirestore
import FirebaseAuth
import FirebaseStorage
import YPImagePicker
import SPAlert


class ProfileVC: UIViewController, UIPopoverPresentationControllerDelegate {
    
    enum Section: CaseIterable {
        case main
    }
    
    // MARK: - IBOoutlets
    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var addView: UIVisualEffectView!
    @IBOutlet weak var addBtn: UIButton!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var bioLabel: ActiveLabel!
    @IBOutlet weak var settingsView: UIVisualEffectView!
    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak var coverImageViewHeight: NSLayoutConstraint!
    @IBOutlet weak var profileHeight: NSLayoutConstraint!
    @IBOutlet weak var profileWidth: NSLayoutConstraint!
    @IBOutlet weak var tview: UIView!
    
    // MARK: - Variables
    var db: Firestore!
    var collectionView: UICollectionView!
    var dataSource: UICollectionViewDiffableDataSource<Section, Post>!
    var posts = [Post]()
    var user: User!
    let userAuth = Auth.auth().currentUser
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        configureHierarchy()
        configureDataSource()
        loadUserData()
        addPosts()
    }
    
    func setupViews() {
        settingsView.layer.masksToBounds = true
        settingsView.layer.cornerRadius = settingsView.frame.height / 2
        addView.layer.masksToBounds = true
        addView.layer.cornerRadius = addView.frame.height / 2
        profilePic.layer.borderWidth = 3
        profilePic.layer.borderColor = .init(genericGrayGamma2_2Gray: 1, alpha: 1)
        profilePic.layer.masksToBounds = true
        profilePic.layer.cornerRadius = 16
        profilePic.contentMode = .scaleAspectFill
        bioLabel.enabledTypes = [.hashtag, .mention]
        bioLabel.handleMentionTap() { element in
            self.openMention(name: element)
        }
        bioLabel.handleHashtagTap { element in
            //self.openHashtag()
        }
        addBtn.showsMenuAsPrimaryAction = true
        addBtn.menu = createPostMenu()
        coverImageView.layer.opacity = 0.5
        NotificationCenter.default.addObserver(self, selector: #selector(loadUserData), name: Notification.Name("reloadProfile"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(refresh), name: Notification.Name("refreshPosts"), object: nil)
    }
    
    @objc func refresh() {
        posts.removeAll()
        addPosts()
    }
    
    func sortPosts() {
        posts = posts.sorted { (lhs: Post, rhs: Post) -> Bool in
            return lhs.dateCreated!.dateValue() > rhs.dateCreated!.dateValue()
        }
    }
    
    func newSnap() {
        sortPosts()
        var snapshot = NSDiffableDataSourceSnapshot<Section, Post>()
        snapshot.appendSections([.main])
        snapshot.appendItems(posts)
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    func createPostMenu() -> UIMenu {
        let photoItem = UIAction(title: "Post a photo", handler: {_ in self.openPhotoPicker()})
        let videoItem = UIAction(title: "Post a video", handler: {_ in self.openVideoPicker()})
        let profileItem = UIAction(title: "Change profile picture", handler: {_ in self.openProfilePicker()})
        let coverItem = UIAction(title: "Change profile background", handler: {_ in self.openCoverPicker()})
        let menuActions = [photoItem, videoItem, profileItem, coverItem]
        let newMenu = UIMenu(title: "", children: menuActions)
        return newMenu
    }
    
    func addPosts() {
        db = Firestore.firestore()
        db.collection("users").document(userAuth!.uid).collection("posts").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    let docRef = self.db.collection("users").document(self.userAuth!.uid).collection("posts").document(document.documentID)
                    docRef.getDocument { (document, _) in
                        if let post = document.flatMap({
                            $0.data().flatMap({ (data) in
                                return Post(dictionary: data)
                            })
                        }) {
                            self.posts.append(post)
                            
                        } else {
                            print("Document does not exist")
                        }
                        self.newSnap()
                    }
                }
            }
        }
    }
    
    @objc func loadUserData() {
        db = Firestore.firestore()
        let docRef = db.collection("users").document(userAuth!.uid)
        docRef.getDocument { (document, _) in
            if let userData = document.flatMap({
                $0.data().flatMap({ (data) in
                    return User(dictionary: data)
                })
            }) {
                self.user = userData
                self.usernameLabel.text = "@\(userData.username ?? "")"
                self.nameLabel.text = userData.name
                self.bioLabel.text = userData.bio
                let processor = DownsamplingImageProcessor(size: (self.profilePic.bounds.size))
                self.profilePic.kf.setImage(
                    with: URL(string: userData.profilePic!),
                    placeholder: UIImage(systemName: "person.fill"),
                    options: [
                        .processor(processor),
                        .scaleFactor(UIScreen.main.scale),
                        .transition(.fade(0)),
                        .cacheOriginalImage])
                let processor2 = DownsamplingImageProcessor(size: (self.coverImageView.bounds.size))
                self.coverImageView.kf.setImage(
                    with: URL(string: userData.coverPhoto!),
                    placeholder: UIImage(named: "gradient"),
                    options: [
                        .processor(processor2),
                        .scaleFactor(UIScreen.main.scale),
                        .transition(.fade(0)),
                        .cacheOriginalImage])
            } else {
                print("Document does not exist")
            }
            
        }
    }
    
    func openVideoPicker() {
        var tempPost: [String: Any]!
        var postID: String!
        let picker = YPImagePicker(configuration: createYPVideoConfig())
        picker.didFinishPicking { [unowned picker] items, _ in
            if let video = items.singleVideo {
                let storage = Storage.storage()
                let storageRef = storage.reference()
                let tempString = self.randomString(length: 40)
                let videosRef = storageRef.child("\(self.userAuth!.uid)/posts/\(tempString).mov")
                let thumbRef = storageRef.child("\(self.userAuth!.uid)/posts/\(tempString).jpg")
                let videoMetadata = StorageMetadata()
                let thumbMetadata = StorageMetadata()
                postID = tempString
                videoMetadata.contentType = "video/mov"
                thumbMetadata.contentType = "image/jpeg"
                let optmizedThumbData = video.thumbnail.jpegData(compressionQuality: 0.5)
                var thumbDownloadURL: String!
                _ = thumbRef.putData(optmizedThumbData!, metadata: thumbMetadata) { metadata, error in
                    guard metadata != nil else {
                        return
                    }
                    thumbRef.downloadURL { (url, error) in
                        thumbDownloadURL = url?.absoluteString
                    }
                }
                
                _ = videosRef.putFile(from: video.url, metadata: videoMetadata) { metadata, error in
                    guard metadata != nil else {
                        return
                    }
                    videosRef.downloadURL { (url, error) in
                        let downloadURL = url?.absoluteString
                        tempPost = [
                            "dateCreated": Timestamp(date: Date()),
                            "videourl": downloadURL!,
                            "imageurl": thumbDownloadURL!,
                            "caption": "",
                            "tags": [String](),
                            "docID": tempString,
                            "userDocID": self.userAuth!.uid,
                            "isVideo": true,
                            "storageRef": "\(self.userAuth!.uid)/posts/\(tempString)"
                        ]
                    }
                }
            }
            picker.dismiss(animated: true, completion: {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let captionVC = storyboard.instantiateViewController(withIdentifier: "changeCaptionVC") as! CaptionViewController
                let navController = UINavigationController(rootViewController: captionVC)
                captionVC.userDocID = self.userAuth!.uid
                captionVC.postDocID = postID
                captionVC.post = tempPost
                self.present(navController, animated: true)
            })
        }
        self.present(picker, animated: true, completion: nil)
    }
    
    func openPhotoPicker() {
        var tempPost: [String: Any]!
        var postID: String!
        let picker = YPImagePicker(configuration: createYPPhotoConfig())
        picker.didFinishPicking { [unowned picker] items, _ in
            if let photo = items.singlePhoto {
                let storage = Storage.storage()
                let storageRef = storage.reference()
                let tempString = self.randomString(length: 40)
                let riversRef = storageRef.child("\(self.userAuth!.uid)/posts/\(tempString).jpg")
                let optimizedImageData = photo.image.jpegData(compressionQuality: 0.5)
                let metadata = StorageMetadata()
                postID = tempString
                metadata.contentType = "image/jpeg"
                _ = riversRef.putData(optimizedImageData!, metadata: metadata) { metadata, error in
                    guard metadata != nil else {
                        return
                    }
                    riversRef.downloadURL { (url, error) in
                        let downloadURL = url?.absoluteString
                        tempPost = [
                            "dateCreated": Timestamp(date: Date()),
                            "videourl": "",
                            "imageurl": downloadURL!,
                            "caption": "",
                            "tags": [String](),
                            "docID": tempString,
                            "userDocID": self.userAuth!.uid,
                            "isVideo": false,
                            "storageRef": "\(self.userAuth!.uid)/posts/\(tempString)"
                        ]
                    }
                }
            }
            picker.dismiss(animated: true, completion: {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let captionVC = storyboard.instantiateViewController(withIdentifier: "changeCaptionVC") as! CaptionViewController
                let navController = UINavigationController(rootViewController: captionVC)
                captionVC.userDocID = self.userAuth!.uid
                captionVC.postDocID = postID
                captionVC.post = tempPost
                self.present(navController, animated: true)
            })
        }
        self.present(picker, animated: true, completion: nil)
    }
    
    func openProfilePicker() {
        let picker = YPImagePicker(configuration: createYPPhotoConfig())
        picker.didFinishPicking { [unowned picker] items, _ in
            if let photo = items.singlePhoto {
                let storage = Storage.storage()
                let storageRef = storage.reference()
                let tempString = self.randomString(length: 40)
                let riversRef = storageRef.child("\(self.userAuth!.uid)/posts/\(tempString).jpg")
                let optimizedImageData = photo.image.jpegData(compressionQuality: 0.5)
                let metadata = StorageMetadata()
                metadata.contentType = "image/jpeg"
                _ = riversRef.putData(optimizedImageData!, metadata: metadata) { metadata, error in
                    guard metadata != nil else {
                        return
                    }
                    riversRef.downloadURL { (url, error) in
                        let downloadURL = url?.absoluteString
                        
                        self.db.collection("users").document(self.userAuth!.uid).setData(["profilePic": downloadURL!], merge: true) { err in
                            if let err = err {
                                SPAlert.present(title: "Error Changing", message: "\(err)", preset: .error)
                            } else {
                                SPAlert.present(title: "Done", preset: .done)
                                let processor = DownsamplingImageProcessor(size: (self.profilePic.bounds.size))
                                self.profilePic.kf.setImage(
                                    with: URL(string: downloadURL!),
                                    placeholder: UIImage(systemName: "person.fill"),
                                    options: [
                                        .processor(processor),
                                        .scaleFactor(UIScreen.main.scale),
                                        .transition(.fade(0)),
                                        .cacheOriginalImage])
                            }
                        }
                    }
                }
            }
            picker.dismiss(animated: true, completion: nil)
        }
        self.present(picker, animated: true, completion: nil)
    }
    
    func openCoverPicker() {
        let picker = YPImagePicker(configuration: createYPPhotoConfig())
        picker.didFinishPicking { [unowned picker] items, _ in
            if let photo = items.singlePhoto {
                let storage = Storage.storage()
                let storageRef = storage.reference()
                let tempString = self.randomString(length: 40)
                let riversRef = storageRef.child("\(self.userAuth!.uid)/posts/\(tempString).jpg")
                let optimizedImageData = photo.image.jpegData(compressionQuality: 0.5)
                let metadata = StorageMetadata()
                metadata.contentType = "image/jpeg"
                _ = riversRef.putData(optimizedImageData!, metadata: metadata) { metadata, error in
                    guard metadata != nil else {
                        return
                    }
                    riversRef.downloadURL { (url, error) in
                        let downloadURL = url?.absoluteString
                        
                        self.db.collection("users").document(self.userAuth!.uid).setData(["coverPhoto": downloadURL!], merge: true) { err in
                            if let err = err {
                                SPAlert.present(title: "Error Changing", message: "\(err)", preset: .error)
                            } else {
                                SPAlert.present(title: "Done", preset: .done)
                                let processor = DownsamplingImageProcessor(size: (self.coverImageView.bounds.size))
                                self.coverImageView.kf.setImage(
                                    with: URL(string: downloadURL!),
                                    placeholder: UIImage(named: "gradient"),
                                    options: [
                                        .processor(processor),
                                        .scaleFactor(UIScreen.main.scale),
                                        .transition(.fade(0)),
                                        .cacheOriginalImage])
                            }
                        }
                    }
                }
            }
            picker.dismiss(animated: true, completion: nil)
        }
        self.present(picker, animated: true, completion: nil)
    }
    
    
}

// MARK: - CollectionView Delegate
extension ProfileVC: UICollectionViewDelegate {
    func createLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout(sectionProvider: {
            (sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            let contentSize = layoutEnvironment.container.effectiveContentSize
            let columns = contentSize.width > 800 ? 3 : 2
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            let groupSize = contentSize.width > 800 ? NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalWidth(0.29)) : NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalWidth(0.5))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: columns)
            group.interItemSpacing = .fixed(5)
            let section = NSCollectionLayoutSection(group: group)
            section.orthogonalScrollingBehavior = .none
            section.interGroupSpacing = CGFloat(5)
            section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
            return section
        })
        return layout
    }
    
    func configureHierarchy() {
        collectionView = UICollectionView(frame: tview.bounds, collectionViewLayout: createLayout())
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.showsVerticalScrollIndicator = false
        collectionView.backgroundColor = .systemBackground
        tview.addSubview(collectionView)
        collectionView.delegate = self
    }
}

// MARK: - CollectionView Datasource
extension ProfileVC {
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
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let item = dataSource.itemIdentifier(for: indexPath)
        if item!.isVideo! {
            let videoVC = storyboard.instantiateViewController(withIdentifier: "videoPostVC") as! VideoPostViewController
            let nav = UINavigationController(rootViewController: videoVC)
            videoVC.video = item
            videoVC.aspectRatio = getVideoResolution(url: item!.videourl!)
            self.show(nav, sender: self)
        } else {
            let photoVC = storyboard.instantiateViewController(withIdentifier: "photoPostVC") as! PhotoPostViewController
            let nav = UINavigationController(rootViewController: photoVC)
            photoVC.photo = item
            self.show(nav, sender: self)
        }
    }
}

// MARK: - Context Menu for cells
extension ProfileVC {
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        if dataSource.itemIdentifier(for: indexPath)?.isVideo == true {
            let video = dataSource.itemIdentifier(for: indexPath)
            let videoMenuConfig = UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { action in
                let changeThumb = UIAction(title: "Change Thumbnail", image: UIImage(systemName: "photo.fill.on.rectangle.fill")) {_ in
                    let picker = YPImagePicker(configuration: self.createYPPhotoConfig())
                    picker.didFinishPicking { [unowned picker] items, _ in
                        if let photo = items.singlePhoto {
                            let storage = Storage.storage()
                            let storageRef = storage.reference()
                            let tempString = self.randomString(length: 40)
                            let riversRef = storageRef.child("\(self.userAuth!.uid)/posts/\(tempString).jpg")
                            let optimizedImageData = photo.image.jpegData(compressionQuality: 0.7)
                            let metadata = StorageMetadata()
                            metadata.contentType = "image/jpeg"
                            _ = riversRef.putData(optimizedImageData!, metadata: metadata) { metadata, error in
                                guard metadata != nil else {
                                    return
                                }
                                riversRef.downloadURL { (url, error) in
                                    let downloadURL = url?.absoluteString
                                    self.db.collection("posts").document(video!.docID!).setData(["imageurl": downloadURL!], merge: true)
                                    self.db.collection("users").document(self.userAuth!.uid).collection("posts").document(video!.docID!).setData(["imageurl": downloadURL!], merge: true) { err in
                                        if let err = err {
                                            print("Error writing document: \(err)")
                                            SPAlert.present(title: "Error Changing", preset: .error)
                                        } else {
                                            SPAlert.present(title: "Done", preset: .done)
                                            self.posts.removeAll()
                                            self.addPosts()
                                        }
                                    }
                                }
                            }
                        }
                        picker.dismiss(animated: true, completion: nil)
                    }
                    self.present(picker, animated: true, completion: nil)
                }
                
                let delete = UIAction(title: "Delete", image: UIImage(systemName: "trash.fill"), attributes: .destructive, handler: {action in
                    self.db.collection("posts").document(video!.docID!).delete()
                    self.db.collection("users").document(self.userAuth!.uid).collection("posts").document(video!.docID!).delete() { err in
                        if let err = err {
                            SPAlert.present(title: "Error Deleting", preset: .error)
                            print("Error writing document: \(err)")
                        } else {
                            SPAlert.present(title: "Deleted", preset: .done)
                            self.posts.remove(at: indexPath.row)
                            self.newSnap()
                        }
                    }
                    Storage.storage().reference().child("\(video!.storageRef!).mov").delete { error in
                        if let error = error {
                            print(error)
                        } else {
                            print("File deleted from storage")
                        }
                    }
                    Storage.storage().reference().child("\(video!.storageRef!).jpg").delete { error in
                        if let error = error {
                            print(error)
                        } else {
                            print("File deleted from storage")
                        }
                    }
                })
                return UIMenu(title: "", children: [changeThumb, delete])
            }
            return videoMenuConfig
        } else {
            let photo = dataSource.itemIdentifier(for: indexPath)
            let photoMenuConfig = UIContextMenuConfiguration(identifier: nil, previewProvider: nil){ action in
                let delete = UIAction(title: "Delete", image: UIImage(systemName: "trash.fill"), attributes: .destructive, handler: {action in
                    
                    self.db.collection("posts").document(photo!.docID!).delete()
                    self.db.collection("users").document(self.userAuth!.uid).collection("posts").document(photo!.docID!).delete() { err in
                        if let err = err {
                            SPAlert.present(title: "Error Deleting", message: "\(err)", preset: .error)
                        } else {
                            SPAlert.present(title: "Deleted", preset: .done)
                            self.posts.remove(at: indexPath.row)
                            self.newSnap()
                        }
                    }
                    Storage.storage().reference().child("\(photo!.storageRef!).jpg").delete { error in
                        if let error = error {
                            print(error)
                        } else {
                            print("File deleted from storage")
                        }
                    }
                })
                return UIMenu(title: "", children: [delete])
            }
            return photoMenuConfig
        }
    }
}

// MARK: - ScrollView(didScroll:)
extension ProfileVC {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let headerViewMaxHeight: CGFloat = 330
        let headerViewMinHeight: CGFloat = 130
        let profileMax: CGFloat = 100
        let profileMin: CGFloat = 50
        let y = scrollView.contentOffset.y
        let newHeaderViewHeight = coverImageViewHeight.constant - y
        
        let newProfileHeight = profileHeight.constant - (y / 3)
        
        if newHeaderViewHeight > headerViewMaxHeight {
            coverImageViewHeight.constant = headerViewMaxHeight
        } else if newHeaderViewHeight < headerViewMinHeight {
            coverImageViewHeight.constant = headerViewMinHeight
        } else {
            coverImageViewHeight.constant = newHeaderViewHeight
            scrollView.contentOffset.y = 0 // block scroll view
        }
        
        if newProfileHeight > profileMax {
            profileHeight.constant = profileMax
            profileWidth.constant = profileMax
        } else if newProfileHeight < profileMin {
            profileHeight.constant = profileMin
            profileWidth.constant = profileMin
        } else {
            profileHeight.constant = newProfileHeight
            profileWidth.constant = newProfileHeight
        }
    }
}
