//
//  MainVC.swift
//  Places
//
//  Created by Егор Губанов on 10.07.2022.
//

import UIKit

class MainVC: UITableViewController {
    
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return realm.objects(Place.self).count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CustomTableViewCell
        
        let place = realm.objects(Place.self)[indexPath.row]
        
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
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let place = realm.objects(Place.self)[indexPath.row]
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { _, _, _ in
            StorageManager.delete(object: place)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
        
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
    
    @IBAction func doneAction(_ segue: UIStoryboardSegue) {
        guard let svc = segue.source as? DataInputScreen else { return }
        let newPlace = svc.getNewPlace()
        StorageManager.add(object: newPlace)
        tableView.reloadData()
    }
}
