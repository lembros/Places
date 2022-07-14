//
//  MainVC.swift
//  Places
//
//  Created by Егор Губанов on 10.07.2022.
//

import UIKit

var places = Place.getPlaces()

class MainVC: UITableViewController {

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return places.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CustomTableViewCell
        
        let place = places[indexPath.row]
        
        cell.nameLabel.text = place.name
        cell.placeImage.image = place.image
        if place.location != nil {
            cell.locationLabel.text = place.location
        }
        
        cell.typeLabel.text = place.type?.rawValue
        
        cell.placeImage.contentMode = .scaleAspectFill
        cell.placeImage.layer.cornerRadius = cell.placeImage.frame.size.height / 2
    
        return cell
    }
    
    @IBAction func cancelAction(_ segue: UIStoryboardSegue) {
        guard let svc = segue.source as? DataInputScreen else { return }
        let newPlace = svc.getNewPlace()
        places.append(newPlace)
        tableView.reloadData()
    }

}
