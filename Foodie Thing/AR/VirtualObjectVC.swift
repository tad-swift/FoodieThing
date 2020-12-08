//
//  VirtualObjectSelection.swift
//  Foodie Thing
//
//  Created by Tadreik Campbell on 10/1/19.
//  Copyright © 2019 Tadreik Campbell. All rights reserved.
//


import UIKit
import ARKit


// MARK: - VirtualObjectSelectionViewControllerDelegate

/// A protocol for reporting which objects have been selected.
protocol VirtualObjectSelectionViewControllerDelegate: class {
    func virtualObjectSelectionViewController(_ selectionViewController: VirtualObjectSelectionViewController, didSelectObject: VirtualObject)
    func virtualObjectSelectionViewController(_ selectionViewController: VirtualObjectSelectionViewController, didDeselectObject: VirtualObject)
}

/// A custom table view controller to allow users to select `VirtualObject`s for placement in the scene.
class VirtualObjectSelectionViewController: UICollectionViewController {
    
    /// The collection of `VirtualObject`s to select from.
    var virtualObjects = [VirtualObject]()
    
    /// The rows of the currently selected `VirtualObject`s.
    var selectedVirtualObjectRows = IndexSet()
    
    /// The rows of the 'VirtualObject's that are currently allowed to be placed.
    var enabledVirtualObjectRows = Set<Int>()
    
    weak var delegate: VirtualObjectSelectionViewControllerDelegate?
    
    weak var sceneView: ARSCNView?

    private var lastObjectAvailabilityUpdateTimestamp: TimeInterval?
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewWillLayoutSubviews() {
        preferredContentSize = CGSize(width: UIScreen.main.bounds.width, height: 120)
    }
    
    func updateObjectAvailability() {
        guard let sceneView = sceneView else { return }
        
        // Update object availability only if the last update was at least half a second ago.
        if let lastUpdateTimestamp = lastObjectAvailabilityUpdateTimestamp,
            let timestamp = sceneView.session.currentFrame?.timestamp,
            timestamp - lastUpdateTimestamp < 0.5 {
            return
        } else {
            lastObjectAvailabilityUpdateTimestamp = sceneView.session.currentFrame?.timestamp
        }
                
        var newEnabledVirtualObjectRows = Set<Int>()
        for (row, object) in VirtualObject.availableObjects.enumerated() {
            // Enable row always if item is already placed, in order to allow the user to remove it.
            if selectedVirtualObjectRows.contains(row) {
                newEnabledVirtualObjectRows.insert(row)
            }
            
            // Enable row if item can be placed at the current location
            if let query = sceneView.getRaycastQuery(for: object.allowedAlignment),
                let result = sceneView.castRay(for: query).first {
                object.mostRecentInitialPlacementResult = result
                object.raycastQuery = query
                newEnabledVirtualObjectRows.insert(row)
            } else {
                object.mostRecentInitialPlacementResult = nil
                object.raycastQuery = nil
            }
        }
        
        // Only reload changed rows
        let changedRows = newEnabledVirtualObjectRows.symmetricDifference(enabledVirtualObjectRows)
        enabledVirtualObjectRows = newEnabledVirtualObjectRows
        let indexPaths = changedRows.map { row in IndexPath(row: row, section: 0) }

        DispatchQueue.main.async {
            self.collectionView.reloadItems(at: indexPaths)
        }
    }
    
    // MARK: - UICollectionViewDelegate
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cellIsEnabled = enabledVirtualObjectRows.contains(indexPath.row)
        guard cellIsEnabled else { return }
        
        let object = virtualObjects[indexPath.row]
        
        // Check if the current row is already selected, then deselect it.
        if selectedVirtualObjectRows.contains(indexPath.row) {
            delegate?.virtualObjectSelectionViewController(self, didDeselectObject: object)
        } else {
            delegate?.virtualObjectSelectionViewController(self, didSelectObject: object)
        }

        dismiss(animated: true, completion: nil)
    }
        
    // MARK: - UICollectionViewDataSource
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return virtualObjects.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ObjectCell.reuseIdentifier, for: indexPath) as? ObjectCell else {
            fatalError("Expected `\(ObjectCell.self)` type for reuseIdentifier \(ObjectCell.reuseIdentifier). Check the configuration in Main.storyboard.")
        }
        
        cell.modelName = virtualObjects[indexPath.row].modelName

        if selectedVirtualObjectRows.contains(indexPath.row) {
            cell.checkImage.image = UIImage(systemName: "checkmark.circle.fill")
        } else {
            cell.checkImage.image = UIImage(systemName: "circle")
        }

        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        let cellIsEnabled = enabledVirtualObjectRows.contains(indexPath.row)
        guard cellIsEnabled else { return }

        let cell = collectionView.cellForItem(at: indexPath)
        cell?.backgroundColor = UIColor.lightGray.withAlphaComponent(0.5)
    }
    
    override func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        let cellIsEnabled = enabledVirtualObjectRows.contains(indexPath.row)
        guard cellIsEnabled else { return }

        let cell = collectionView.cellForItem(at: indexPath)
        cell?.backgroundColor = .clear
    }
    
}

