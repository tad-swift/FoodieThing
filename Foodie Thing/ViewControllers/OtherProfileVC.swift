//
//  OtherProfileVC.swift
//  Foodie Thing
//
//  Created by Tadreik Campbell on 11/1/20.
//  Copyright © 2020 Tadreik Campbell. All rights reserved.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth
import SPAlert


final class OtherProfileViewController: UIViewController {
    
    // MARK: - IBOoutlets
    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var bioLabel: ActiveLabel!
    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak var tview: UIView!
    @IBOutlet weak var followView: UIVisualEffectView!
    @IBOutlet weak var followBtn: UIButton!
    @IBOutlet weak var coverImageViewHeight: NSLayoutConstraint!
    @IBOutlet weak var profileHeight: NSLayoutConstraint!
    @IBOutlet weak var profileWidth: NSLayoutConstraint!
    @IBOutlet weak var centerx: NSLayoutConstraint!
    @IBOutlet weak var nameLabelTop: NSLayoutConstraint!
    @IBOutlet weak var nameLabelCenter: NSLayoutConstraint!
    @IBOutlet weak var backBtn: UIVisualEffectView!
    
    // MARK: - Variables
    enum Section: CaseIterable {
        case main
    }
    
    var dataSource: UICollectionViewDiffableDataSource<Section, Post>!
    
    var collectionView: UICollectionView!
    
    var query: Query!
    
    var documents = [DocumentSnapshot]()
    var posts = [Post]()
    var user: User!
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        configureHierarchy()
        configureDataSource()
        updateFollowBtn()
        fetchPosts {
            if self.posts.isEmpty {
                self.collectionView.setEmptyMessage("It looks like this user has no content")
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        if user.docID == Auth.auth().currentUser!.uid {
            followBtn.isEnabled = false
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    func setupViews() {
        backBtn.layer.masksToBounds = true
        backBtn.layer.cornerRadius = backBtn.frame.height / 2
        profilePic.layer.borderWidth = 3
        profilePic.layer.borderColor = .init(genericGrayGamma2_2Gray: 1, alpha: 1)
        profilePic.layer.cornerRadius = 16
        profilePic.contentMode = .scaleAspectFill
        let processor = DownsamplingImageProcessor(size: (self.profilePic.bounds.size))
        profilePic.kf.setImage(
            with: URL(string: user.profilePic),
            placeholder: UIImage(systemName: "person.fill"),
            options: [
                .processor(processor),
                .scaleFactor(UIScreen.main.scale),
                .transition(.fade(0)),
                .cacheOriginalImage])
        let processor2 = DownsamplingImageProcessor(size: (self.coverImageView.bounds.size))
        coverImageView.kf.setImage(
            with: URL(string: user.coverPhoto),
            placeholder: UIImage(named: "gradient"),
            options: [
                .processor(processor2),
                .scaleFactor(UIScreen.main.scale),
                .transition(.fade(0)),
                .cacheOriginalImage])
        coverImageView.layer.opacity = 0.5
        if user.name.isNotEmpty {
            usernameLabel.text = "\(user.name)\n@\(user.username)"
        } else {
            usernameLabel.text = "@\(user.username )"
        }
        bioLabel.text = user.bio
        bioLabel.enabledTypes = [.hashtag, .mention]
        bioLabel.handleMentionTap() { element in
            self.openMention(name: element)
        }
        bioLabel.handleHashtagTap { element in
            //self.openHashtag()
        }
        followView.layer.masksToBounds = true
        followView.layer.cornerRadius = followView.frame.height / 2
        self.title = user.username
    }
    
    func newSnap() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Post>()
        snapshot.appendSections([.main])
        snapshot.appendItems(posts)
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    func fetchPosts(_ completion: @escaping () -> Void) {
        db.collection("posts")
            .whereField("userDocID", isEqualTo: user.docID)
            .getDocuments { snapshot, error in
                guard let snapshot = snapshot else { completion(); return }
                self.posts = snapshot.documents.compactMap { doc in
                    return try? doc.data(as: Post.self)
                }
                self.newSnap()
                completion()
            }
    }
    
    func isFollowing(_ accountID: String) -> Bool {
        if myUser.following.contains(accountID) {
            return true
        } else {
            return false
        }
    }
    
    func updateFollowBtn() {
        if isFollowing(user.docID) {
            followBtn.setTitle("Following", for: .normal)
            followBtn.setImage(UIImage(systemName: "checkmark", withConfiguration: UIImage.SymbolConfiguration.init(scale: .small)), for: .normal)
        } else {
            followBtn.setTitle("Follow", for: .normal)
            followBtn.setImage(UIImage(systemName: "plus", withConfiguration: UIImage.SymbolConfiguration.init(scale: .small)), for: .normal)
        }
    }
    
    @IBAction func followTapped(_ sender: Any) {
        if isFollowing(user.docID) {
            // Unfollow
            myUser.following.removeAll { $0 == user.docID }
            db.collection("users").document(myUser.docID).setData(["following": myUser.following], merge: true)
            updateFollowBtn()
        } else {
            myUser.following.append(user.docID)
            db.collection("users").document(myUser.docID).setData(["following": myUser.following], merge: true)
            updateFollowBtn()
        }
    }
    
    @IBAction func backTapped(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - CollectionView Delegate
extension OtherProfileViewController: UICollectionViewDelegate {
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
        collectionView.showsVerticalScrollIndicator = false
        if user.docID == "TP4naRGfbDhwVOvVHSGPOP16B603" {
            collectionView.backgroundColor = .black
        } else {
            collectionView.backgroundColor = .systemBackground
        }
        tview.addSubview(collectionView)
        collectionView.delegate = self
    }
}

// MARK: - CollectionView Datasource
extension OtherProfileViewController {
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
            videoVC.video = item
            videoVC.aspectRatio = getVideoResolution(url: item!.videourl!)
            self.show(videoVC, sender: self)
        } else {
            let photoVC = storyboard.instantiateViewController(withIdentifier: "photoPostVC") as! PhotoPostViewController
            photoVC.photo = item
            self.show(photoVC, sender: self)
        }
    }
    
//    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
//        if indexPath.row == posts.count - 4 {
//            paginate(to: &posts, from: .singleUserAll, userDocID: user.docID)
//        }
//    }
}

// MARK: - ScrollView(didScroll:)
extension OtherProfileViewController {
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
        let centerxMin: CGFloat = -80
        let nameCenterMax: CGFloat = 10
        let nameCenterMin: CGFloat = 0
        let newNameCenterx = nameLabelCenter.constant + (y / 18)
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
            nameLabelCenter.constant = nameCenterMax
        } else if newNameCenterx < nameCenterMin {
            nameLabelCenter.constant = nameCenterMin
        } else {
            nameLabelCenter.constant = newNameCenterx
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
