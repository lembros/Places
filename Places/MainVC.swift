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
        
        if place.location != nil {
            cell.locationLabel.text = place.location
        }
        
        cell.typeLabel.text = place.type
        
        cell.placeImage.contentMode = .scaleAspectFill
        cell.placeImage.layer.cornerRadius = cell.placeImage.frame.size.height / 2
    
        return cell
    }
    
    @IBAction func doneAction(_ segue: UIStoryboardSegue) {
        guard let svc = segue.source as? DataInputScreen else { return }
        let newPlace = svc.getNewPlace()
        StorageManager.add(object: newPlace)
        tableView.reloadData()
    }

}
