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
import SPAlert


final class ProfileVC: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var addView: UIVisualEffectView!
    @IBOutlet weak var addBtn: UIButton!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var bioLabel: ActiveLabel!
    @IBOutlet weak var settingsView: UIVisualEffectView!
    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak var coverImageViewHeight: NSLayoutConstraint!
    @IBOutlet weak var profileHeight: NSLayoutConstraint!
    @IBOutlet weak var profileWidth: NSLayoutConstraint!
    @IBOutlet weak var centerx: NSLayoutConstraint!
    @IBOutlet weak var nameLabelTop: NSLayoutConstraint!
    @IBOutlet weak var nameLabelCenterx: NSLayoutConstraint!
    @IBOutlet weak var tview: UIView!
    
    // MARK: - Variables
    enum Section: CaseIterable {
        case main
    }
    
    var dataSource: UICollectionViewDiffableDataSource<Section, Post>!
    
    var collectionView: UICollectionView!
    
    var query: Query!
    
    var documents = [DocumentSnapshot]()
    
    var posts = [Post]()
    
    let storageRef = Storage.storage().reference()
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        configureHierarchy()
        configureDataSource()
        query = db.collection("users").document(myUser.docID).collection("posts")
            .order(by: "dateCreated", descending: true)
            .limit(to: 16)
        fetchPosts {
            if self.posts.isEmpty {
                self.collectionView.setEmptyMessage("It looks like your kitchen is empty, use the add button in the top left to share a new meal")
            }
        }
        profilePic.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(switchAccount))
        profilePic.addGestureRecognizer(tap)
    }
    
    @objc func switchAccount() {
        let ids = ["NikUWpMT91hUmblXGdvwteGFoNl1", "CJNryI3DDqeg5UZo06UHyYgaDH82"]
        if ids.contains(Auth.auth().currentUser!.uid) {
            let alert = UIAlertController(title: "Switch Account?", message: nil, preferredStyle: .alert)
            alert.preferredAction = UIAlertAction(title: "No", style: .default)
            alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: {_ in
                let id = ids.first(where: { $0 != myUser.docID})!
                let docRef = db.collection("users").document(id)
                docRef.getDocument { (document, _) in
                    let obj = try! document?.data(as: User.self)!
                    myUser = obj
                    self.bioLabel.text = myUser.bio
                    self.nameLabel.text = "\(myUser.name)\n@\(myUser.username)"
                    let processor = DownsamplingImageProcessor(size: (self.profilePic.bounds.size))
                    self.profilePic.kf.setImage(
                        with: URL(string: myUser.profilePic),
                        placeholder: UIImage(systemName: "person.fill"),
                        options: [
                            .processor(processor),
                            .scaleFactor(UIScreen.main.scale),
                            .transition(.fade(0)),
                            .cacheOriginalImage])
                    let processor2 = DownsamplingImageProcessor(size: (self.coverImageView.bounds.size))
                    self.coverImageView.kf.setImage(
                        with: URL(string: myUser.coverPhoto),
                        placeholder: UIImage(named: "gradient"),
                        options: [
                            .processor(processor2),
                            .scaleFactor(UIScreen.main.scale),
                            .transition(.fade(0)),
                            .cacheOriginalImage])
                    self.refresh()
                    
                }
            }))
            self.present(alert, animated: true)
        }
    }
    
    // Do all UIViews setup here.
    func setupViews() {
        settingsView.layer.masksToBounds = true
        addView.layer.masksToBounds = true
        settingsView.layer.cornerRadius = settingsView.frame.height / 2
        addView.layer.cornerRadius = addView.frame.height / 2
        profilePic.layer.borderWidth = 3
        profilePic.layer.borderColor = .init(genericGrayGamma2_2Gray: 1, alpha: 1)
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
        if myUser.name.isNotEmpty {
            nameLabel.text = "\(myUser.name)\n@\(myUser.username)"
        } else {
            nameLabel.text = "@\(myUser.username)"
        }
        
        bioLabel.text = myUser.bio
        let processor = DownsamplingImageProcessor(size: (profilePic.bounds.size))
        profilePic.kf.setImage(
            with: URL(string: myUser.profilePic),
            placeholder: UIImage(systemName: "person.fill"),
            options: [
                .processor(processor),
                .scaleFactor(UIScreen.main.scale),
                .transition(.fade(0)),
                .cacheOriginalImage])
        let processor2 = DownsamplingImageProcessor(size: (coverImageView.bounds.size))
        coverImageView.kf.setImage(
            with: URL(string: myUser.coverPhoto),
            placeholder: UIImage(named: "gradient"),
            options: [
                .processor(processor2),
                .scaleFactor(UIScreen.main.scale),
                .transition(.fade(0)),
                .cacheOriginalImage])
        
        NotificationCenter.default.addObserver(self, selector: #selector(loadUserData), name: Notification.Name("reloadProfile"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(refresh), name: Notification.Name("refreshPosts"), object: nil)
    }
    
    @objc func refresh() {
        posts.removeAll()
        fetchPosts {
            if self.posts.isEmpty {
                self.collectionView.setEmptyMessage("It looks like your kitchen is empty, use the add button in the top left to share a new meal")
            }
        }
    }
    
    func newSnap() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Post>()
        snapshot.appendSections([.main])
        snapshot.appendItems(posts)
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    func fetchPosts(_ completion: @escaping () -> Void) {
        db.collection("posts")
            .whereField("userDocID", isEqualTo: myUser.docID)
            .getDocuments { snapshot, error in
                guard let snapshot = snapshot else { completion(); return }
                self.posts = snapshot.documents.compactMap { doc in
                    return try? doc.data(as: Post.self)
                }
                self.newSnap()
                completion()
            }
    }
    
    func createPostMenu() -> UIMenu {
        let photoItem = UIAction(title: "Share a photo", handler: {_ in self.openPhotoPicker()})
        let videoItem = UIAction(title: "Share a video", handler: {_ in self.openVideoPicker()})
        let profileItem = UIAction(title: "Set profile picture", handler: {_ in self.openProfilePicker()})
        let coverItem = UIAction(title: "Set profile background", handler: {_ in self.openCoverPicker()})
        let menuActions = [photoItem, videoItem, profileItem, coverItem]
        let newMenu = UIMenu(title: "", children: menuActions)
        return newMenu
    }
    
    /// Grabs user's data from Firebase and updates the profile
    @objc func loadUserData() {
        let docRef = db.collection("users").document(myUser.docID)
        docRef.getDocument {[self] (document, _) in
            myUser = try! document?.data(as: User.self)!
            if myUser.name.isNotEmpty {
                nameLabel.text = "\(myUser.name)\n@\(myUser.username)"
            } else {
                nameLabel.text = "@\(myUser.username)"
            }
            bioLabel.text = myUser.bio
            let processor = DownsamplingImageProcessor(size: (profilePic.bounds.size))
            profilePic.kf.setImage(
                with: URL(string: myUser.profilePic),
                placeholder: UIImage(systemName: "person.fill"),
                options: [
                    .processor(processor),
                    .scaleFactor(UIScreen.main.scale),
                    .transition(.fade(0)),
                    .cacheOriginalImage])
            let processor2 = DownsamplingImageProcessor(size: (coverImageView.bounds.size))
            coverImageView.kf.setImage(
                with: URL(string: myUser.coverPhoto),
                placeholder: UIImage(named: "gradient"),
                options: [
                    .processor(processor2),
                    .scaleFactor(UIScreen.main.scale),
                    .transition(.fade(0)),
                    .cacheOriginalImage])
        }
    }
    
    @IBAction func openSettings(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Settings", bundle: nil)
        let optionsVC = storyboard.instantiateViewController(identifier: "optionsNav")
        present(optionsVC, animated: true, completion: nil)
    }

    /// Allows user to upload a new video
    func openVideoPicker() {
        let picker = YPImagePicker(configuration: createYPConfig(type: .video))
        picker.didFinishPicking { [self] items, _ in
            if let video = items.singleVideo {
                let tempString = randomString(length: 40)
                let videosRef = storageRef.child("users/\(myUser.docID)/\(tempString).mov")
                let thumbRef = storageRef.child("users/\(myUser.docID)/\(tempString).jpg")
                let videoMetadata = StorageMetadata()
                let thumbMetadata = StorageMetadata()
                videoMetadata.contentType = "video/quicktime"
                thumbMetadata.contentType = "image/jpeg"
                let optmizedThumbData = video.thumbnail.jpegData(compressionQuality: 0.5)
                var thumbDownloadURL: String!
                thumbRef.putData(optmizedThumbData!, metadata: thumbMetadata) { metadata, error in
                    guard metadata != nil else {
                        return
                    }
                    thumbRef.downloadURL { (url, error) in
                        thumbDownloadURL = url?.absoluteString
                    }
                }
                videosRef.putFile(from: video.url, metadata: videoMetadata) { metadata, error in
                    guard metadata != nil else {
                        return
                    }
                    videosRef.downloadURL { (url, error) in
                        let downloadURL = url?.absoluteString
                        tempPost = Post(videourl: downloadURL!, imageurl: thumbDownloadURL!,
                                        tags: [String](), dateCreated: Timestamp(date: Date()),
                                        docID: tempString, caption: "", userDocID: myUser.docID,
                                        isVideo: true, storageRef: "users/\(myUser.docID)/\(tempString)",
                                        views: 0)
                    }
                }
            }
        }
        self.present(picker, animated: true, completion: nil)
    }
    
    /// Allows user to upload a new photo
    func openPhotoPicker() {
        let picker = YPImagePicker(configuration: createYPConfig(type: .photo))
        picker.didFinishPicking { [self] items, _ in
            if let photo = items.singlePhoto {
                let tempString = randomString(length: 40)
                let riversRef = storageRef.child("users/\(myUser.docID)/\(tempString).jpg")
                let optimizedImageData = photo.image.jpegData(compressionQuality: 0.5)
                let metadata = StorageMetadata()
                metadata.contentType = "image/jpeg"
                riversRef.putData(optimizedImageData!, metadata: metadata) { metadata, error in
                    guard metadata != nil else {
                        return
                    }
                    riversRef.downloadURL { (url, error) in
                        let downloadURL = url?.absoluteString
                        tempPost = Post(videourl: "", imageurl: downloadURL!,
                                        tags: [String](), dateCreated: Timestamp(date: Date()),
                                        docID: tempString, caption: "",
                                        userDocID: myUser.docID, isVideo: false,
                                        storageRef: "users/\(myUser.docID)/\(tempString)",
                                        views: 0)
                    }
                }
            }
        }
        self.present(picker, animated: true, completion: nil)
    }
    
    /// Allows user to change their profile photo
    func openProfilePicker() {
        let picker = YPImagePicker(configuration: createYPConfig(type: .photo))
        picker.didFinishPicking { [self, unowned picker] items, _ in
            if let photo = items.singlePhoto {
                let tempString = randomString(length: 40)
                let riversRef = storageRef.child("users/\(myUser.docID)/\(tempString).jpg")
                let optimizedImageData = photo.image.jpegData(compressionQuality: 0.4)
                let metadata = StorageMetadata()
                metadata.contentType = "image/jpeg"
                riversRef.putData(optimizedImageData!, metadata: metadata) { metadata, error in
                    guard metadata != nil else {
                        return
                    }
                    riversRef.downloadURL { (url, error) in
                        let downloadURL = url?.absoluteString
                        
                        db.collection("users").document(myUser.docID).setData(["profilePic": downloadURL!], merge: true) { err in
                            if let err = err {
                                SPAlert.present(title: "Error Changing", message: "\(err)", preset: .error)
                            } else {
                                SPAlert.present(title: "Done", preset: .done)
                                let processor = DownsamplingImageProcessor(size: (profilePic.bounds.size))
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
    
    /// Allows user to change the background image of their profile
    func openCoverPicker() {
        let picker = YPImagePicker(configuration: createYPConfig(type: .photo))
        picker.didFinishPicking { [self, unowned picker] items, _ in
            if let photo = items.singlePhoto {
                let tempString = randomString(length: 40)
                let riversRef = storageRef.child("users/\(myUser.docID)/\(tempString).jpg")
                let optimizedImageData = photo.image.jpegData(compressionQuality: 0.5)
                let metadata = StorageMetadata()
                metadata.contentType = "image/jpeg"
                riversRef.putData(optimizedImageData!, metadata: metadata) { metadata, error in
                    guard metadata != nil else {
                        return
                    }
                    riversRef.downloadURL { (url, error) in
                        let downloadURL = url?.absoluteString
                        
                        db.collection("users").document(myUser.docID).setData(["coverPhoto": downloadURL!], merge: true) { err in
                            if let err = err {
                                SPAlert.present(title: "Error Changing", message: "\(err)", preset: .error)
                            } else {
                                SPAlert.present(title: "Done", preset: .done)
                                let processor = DownsamplingImageProcessor(size: (coverImageView.bounds.size))
                                coverImageView.kf.setImage(
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
            let columns = contentSize.width > 800 ? 4 : 2
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            let groupSize = contentSize.width > 800 ? NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalWidth(0.25)) : NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalWidth(0.5))
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
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 30, right: 0)
        collectionView.showsVerticalScrollIndicator = false
        if myUser.docID == "TP4naRGfbDhwVOvVHSGPOP16B603" {
            collectionView.backgroundColor = .black
        } else {
            collectionView.backgroundColor = .systemBackground
        }
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
        if item!.isVideo {
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
    
//    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
//        if indexPath.row == posts.count - 4 {
//            paginate(to: &posts, from: .singleUserAll, userDocID: myUser.docID)
//        }
//    }
}

// MARK: - Context Menu for cells
extension ProfileVC {
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        if dataSource.itemIdentifier(for: indexPath)?.isVideo == true {
            let video = dataSource.itemIdentifier(for: indexPath)
            let videoMenuConfig = UIContextMenuConfiguration(identifier: nil, previewProvider: nil) {[self] action in
                /// Menu item to change the video thumbnail
                let changeThumb = UIAction(title: "Change Thumbnail", image: UIImage(systemName: "photo.fill.on.rectangle.fill")) {_ in
                    let picker = YPImagePicker(configuration: self.createYPConfig(type: .photo))
                    picker.didFinishPicking { [unowned picker] items, _ in
                        if let photo = items.singlePhoto {
                            let tempString = randomString(length: 40)
                            let riversRef = storageRef.child("users/\(myUser.docID)/\(tempString).jpg")
                            let optimizedImageData = photo.image.jpegData(compressionQuality: 0.7)
                            let metadata = StorageMetadata()
                            metadata.contentType = "image/jpeg"
                            _ = riversRef.putData(optimizedImageData!, metadata: metadata) { metadata, error in
                                guard metadata != nil else {
                                    return
                                }
                                riversRef.downloadURL { (url, error) in
                                    let downloadURL = url?.absoluteString
                                    db.collection("posts").document(video!.docID).updateData(["imageurl": downloadURL!])
                                    db.collection("users").document(myUser.docID).collection("posts").document(video!.docID).updateData(["imageurl": downloadURL!]) { err in
                                        if let err = err {
                                            log.debug("Error writing document: \(err as NSObject)")
                                            SPAlert.present(title: "Error Changing", preset: .error)
                                        } else {
                                            SPAlert.present(title: "Done", preset: .done)
                                            posts.remove(at: indexPath.item)
                                            self.newSnap()
                                        }
                                    }
                                }
                            }
                        }
                        picker.dismiss(animated: true, completion: nil)
                    }
                    self.present(picker, animated: true, completion: nil)
                }
                
                /// Menu item to delete the post
                let delete = UIAction(title: "Delete", image: UIImage(systemName: "trash.fill"), attributes: .destructive, handler: {action in
                    db.collection("posts").document(video!.docID).delete()
                    db.collection("users").document(myUser.docID).collection("posts").document(video!.docID).delete() { err in
                        if let err = err {
                            SPAlert.present(title: "Error Deleting", preset: .error)
                            log.debug("Error writing document: \(err as NSObject)")
                        } else {
                            Storage.storage().reference().child("\(video!.storageRef).mov").delete()
                            Storage.storage().reference().child("\(video!.storageRef).jpg").delete()
                            SPAlert.present(title: "Deleted", preset: .done)
                            posts.remove(at: indexPath.row)
                            newSnap()
                            if collectionView.isCollectionEmpty() {
                                collectionView.setEmptyMessage("There are no posts to display")
                            } else {
                                collectionView.backgroundView = nil
                            }
                        }
                    }
                    
                })
                return UIMenu(title: "", children: [changeThumb, delete])
            }
            return videoMenuConfig
        } else {
            let photo = dataSource.itemIdentifier(for: indexPath)
            let photoMenuConfig = UIContextMenuConfiguration(identifier: nil, previewProvider: nil){[self] action in
                let delete = UIAction(title: "Delete", image: UIImage(systemName: "trash.fill"), attributes: .destructive, handler: {action in
                    
                    db.collection("posts").document(photo!.docID).delete()
                    db.collection("users").document(myUser.docID).collection("posts").document(photo!.docID).delete() { err in
                        if let err = err {
                            SPAlert.present(title: "Error Deleting", message: "\(err)", preset: .error)
                        } else {
                            Storage.storage().reference().child("\(photo!.storageRef).jpg").delete()
                            SPAlert.present(title: "Deleted", preset: .done)
                            posts.remove(at: indexPath.row)
                            newSnap()
                            if collectionView.isCollectionEmpty() {
                                collectionView.setEmptyMessage("There are no posts to display")
                            } else {
                                collectionView.backgroundView = nil
                            }
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
    /// Shrink the profile header view when the user scrolls down. Expand it on scroll to top.
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let headerViewMaxHeight: CGFloat = 330
        let headerViewMinHeight: CGFloat = 130
        let profileMax: CGFloat = 100
        let profileMin: CGFloat = 50
        let y = scrollView.contentOffset.y
        let newHeaderViewHeight = coverImageViewHeight.constant - y
        let newProfileHeight = profileHeight.constant - (y / 4)
        let newcenterx = centerx.constant - (y / 2)
        let centerxMax: CGFloat = 0
        let centerxMin: CGFloat = -90
        let nameCenterMax: CGFloat = 30
        let nameCenterMin: CGFloat = 0
        let newNameCenterx = nameLabelCenterx.constant + (y / 6)
        let nameHeightMax: CGFloat = 128
        let nameHeightMin: CGFloat = 14
        let newNameHeight = nameLabelTop.constant - (y / 1.75)
        
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
        
        if newcenterx > centerxMax {
            centerx.constant = centerxMax
        } else if newcenterx < centerxMin {
            centerx.constant = centerxMin
        } else {
            centerx.constant = newcenterx
        }
        
        if newNameCenterx > nameCenterMax {
            nameLabelCenterx.constant = nameCenterMax
        } else if newNameCenterx < nameCenterMin {
            nameLabelCenterx.constant = nameCenterMin
        } else {
            nameLabelCenterx.constant = newNameCenterx
        }
        
        if newNameHeight > nameHeightMax {
            nameLabelTop.constant = nameHeightMax
        } else if newNameHeight < nameHeightMin {
            nameLabelTop.constant = nameHeightMin
        } else {
            nameLabelTop.constant = newNameHeight
        }
        
    }
}
