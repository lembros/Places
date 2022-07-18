//
//  MainVC.swift
//  Places
//
//  Created by Егор Губанов on 10.07.2022.
//

import UIKit
import RealmSwift

class MainVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
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
    
    override func viewDidLoad() {
        tableView.delegate = self
        tableView.dataSource = self
        
        navigationItem.searchController = searchController
        searchController.hidesNavigationBarDuringPresentation = true
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
    
        doSorting()
    }
    
    // MARK: - Table view data source

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isSearching ? placesFound.count : places.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CustomTableViewCell
        
        let place = isSearching ? placesFound[indexPath.row] : places[indexPath.row]
        cell.place = place
                
        cell.nameLabel.text = place.name
        cell.placeImage.image = UIImage(data: place.imageData!)
        
        let location = (place.location == nil || place.location!.isEmpty) ? "Location" : place.location!
        let type = (place.type == nil || place.type!.isEmpty) ? "Type" : place.type!
        
        cell.locationLabel.text = location
        cell.typeLabel.text = type
                
        cell.placeImage.contentMode = .scaleAspectFill
        cell.placeImage.layer.cornerRadius = cell.placeImage.frame.size.height / 2
        
        return cell
    }
    
    // MARK: Table View delegate
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let cell = tableView.cellForRow(at: indexPath) as! CustomTableViewCell
        let place = cell.place!
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { _, _, _ in
            StorageManager.delete(object: place)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
        
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
    
    // MARK: Segues
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == "EditSegue" else { return }
        guard let cell = sender as? CustomTableViewCell else { return }
        guard let navigator = segue.destination as? UINavigationController else { return }
                
        let dvc = navigator.viewControllers.first! as! DataInputScreen
        
        dvc.currentTitle = cell.nameLabel.text
        dvc.place = cell.place
        dvc.wasImageChosen = true
    }
    
    @IBAction func doneAction(_ segue: UIStoryboardSegue) {
        guard let svc = segue.source as? DataInputScreen else { return }
        let newPlace = svc.getNewPlace()
        
        if let indexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: indexPath, animated: true)
            let cell = tableView.cellForRow(at: indexPath) as! CustomTableViewCell
            StorageManager.replace(object: cell.place, with: newPlace)
        } else {
            StorageManager.add(object: newPlace)
        }
        tableView.reloadData()
    }
    
    
    // MARK: Sorting
    
    @IBAction func changeSortngRule(_ sender: Any) {
        doSorting()
    }
    
    @IBAction func changeSortingOrder(_ sender: Any) {
        isAscendingSort.toggle()
        ascendingSortButton.image = isAscendingSort ? UIImage(named: "AZ") : UIImage(named: "ZA")
        doSorting()
    }
    
    
    private func doSorting() {
        switch sortingSegmentedControl.selectedSegmentIndex {
        case 0:
            places = places.sorted(by: \Place.date, ascending: isAscendingSort)
        case 1:
            places = places.sorted(by: \Place.name, ascending: isAscendingSort)
        case 2:
            places = places.sorted(by: \Place.rating, ascending: isAscendingSort)
        default: break
        }
        tableView.reloadData()
    }
}

// MARK: Searching

extension MainVC: UISearchResultsUpdating, UISearchBarDelegate {
    func updateSearchResults(for searchController: UISearchController) {
        let searchingFor = searchController.searchBar.text!
        
        placesFound = places.where {
            $0.name.contains(searchingFor, options: .caseInsensitive) || $0.location.contains(searchingFor, options: .caseInsensitive)
        }
        tableView.reloadData()
    }
    
}
