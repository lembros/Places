//
//  MainVC.swift
//  Places
//
//  Created by Егор Губанов on 10.07.2022.
//

import UIKit
import RealmSwift

class MainViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - IBOutlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var ascendingSortButton: UIBarButtonItem!
    @IBOutlet weak var sortingSegmentedControl: UISegmentedControl!
    
    // Searching properties
    let searchController = UISearchController(searchResultsController: nil)
    private var placesFound: Results<Place>!
    private var isSearching: Bool {
        searchController.isActive && !(searchController.searchBar.text?.isEmpty ?? true)
    }
    
    // Sorting properties
    private var isAscendingSort = true
    
    // MARK: - ViewDidLoad
    
    override func viewDidLoad() {
        
        // TableView setup
        tableView.delegate = self
        tableView.dataSource = self
        
        // Search controller setup
        navigationItem.searchController = searchController
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
    
        // Initial sorting to match value in segmented control
        doSorting()
        
        // Adding right and left swipe recognizers
        setupGestures()
    }
    
    // MARK: - Table view data source

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isSearching ? placesFound.count : StorageManager.places.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CustomTableViewCell
        
        let place = isSearching ? placesFound[indexPath.row] : StorageManager.places[indexPath.row]
        
        // Setup of table view cell
        cell.place = place
                
        cell.nameLabel.text = place.name
        
        // If place has no image, display placeholder instead
        if let imageData = place.imageData {
            cell.placeImage.image = UIImage(data: imageData)
        } else {
            cell.placeImage.image = UIImage(named: "imagePlaceholder")
        }
        
        // If place has no location, display "Location" label instead, same with type
        let location = place.hasLocation ? place.location! : "Location"
        let type = place.hasType ? place.type! : "Type"
        
        cell.locationLabel.text  = location
        cell.typeLabel.text      = type
                
        cell.placeImage.contentMode = .scaleAspectFill
        cell.placeImage.layer.cornerRadius = cell.placeImage.frame.size.height / 2
        
        return cell
    }
    
    // MARK: - Private methods
    
    private func setupGestures() {
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(swipeHappened(_:)))
        rightSwipe.direction = .right
        
        let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(swipeHappened(_:)))
        leftSwipe.direction = .left
        
        view.addGestureRecognizer(rightSwipe)
        view.addGestureRecognizer(leftSwipe)
    }
    
    // MARK: - @objc
    
    @objc private func swipeHappened(_ gesture: UISwipeGestureRecognizer) {
        let change = gesture.direction == .right ? 1 : -1
        
        // If value is allowed
        if (0..<sortingSegmentedControl.numberOfSegments).contains(sortingSegmentedControl.selectedSegmentIndex + change) {
            sortingSegmentedControl.selectedSegmentIndex += change
            doSorting()
        }
    }
    
    // MARK: - Table View delegate
    
    // Delete place
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let cell = tableView.cellForRow(at: indexPath) as! CustomTableViewCell
        let place = cell.place!
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { _, _, _ in
            // Delete from database and from table view
            StorageManager.delete(object: place)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
        
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == "EditSegue" else { return }
        guard let cell = sender as? CustomTableViewCell else { return }
        guard let navigator = segue.destination as? NavigationController else { return }
                
        let dvc = navigator.viewControllers.first! as! DataViewController
        
        // MainVC -> NavigationController (aka navigator) -> DataInputScreen
        
        dvc.place = cell.place
    }
    
    // MARK: - IBActions
    
    // Unwind segue
    @IBAction func doneAction(_ segue: UIStoryboardSegue) {
        guard let svc = segue.source as? DataViewController else { return }
        let newPlace = svc.getNewPlace()
        
        // If row was chosen, modify data in this row
        // Otherwise, add new object
        if let indexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: indexPath, animated: true)
            let cell = tableView.cellForRow(at: indexPath) as! CustomTableViewCell
            StorageManager.replace(object: cell.place, with: newPlace)
        } else {
            StorageManager.add(object: newPlace)
        }
        tableView.reloadData()
    }
    
    @IBAction func cancelAction(_ segue: UIStoryboardSegue) {
        // If row was chosen, just deselect it
        guard let indexPath = tableView.indexPathForSelectedRow else { return }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // MARK: - Sorting
    
    // Resort table with updated value from picker
    @IBAction func changeSortngRule(_ sender: Any) {
        doSorting()
    }
    
    // Change sorting order and replace image accordingly
    @IBAction func changeSortingOrder(_ sender: Any) {
        isAscendingSort.toggle()
        ascendingSortButton.image = isAscendingSort ? UIImage(systemName: "arrow.down.to.line") : UIImage(systemName: "arrow.up.to.line")
        doSorting()
    }
    
    private func doSorting() {
        switch sortingSegmentedControl.selectedSegmentIndex {
        case 0:
            StorageManager.places = StorageManager.places.sorted(by: \Place.date, ascending: isAscendingSort)
        case 1:
            StorageManager.places = StorageManager.places.sorted(by: \Place.name, ascending: isAscendingSort)
        case 2:
            StorageManager.places = StorageManager.places.sorted(by: \Place.rating, ascending: isAscendingSort)
        default: break
        }
        tableView.reloadData()
    }
}

// MARK: - Searching

extension MainViewController: UISearchResultsUpdating, UISearchBarDelegate {
    func updateSearchResults(for searchController: UISearchController) {
        let searchingFor = searchController.searchBar.text!
        
        placesFound = StorageManager.places.where {
            $0.name.contains(searchingFor, options: .caseInsensitive) || $0.location.contains(searchingFor, options: .caseInsensitive)
        }
        tableView.reloadData()
    }
}
