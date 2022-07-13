//
//  MainVC.swift
//  Places
//
//  Created by Егор Губанов on 10.07.2022.
//

import UIKit

let places = Place.getPlaces()

class MainVC: UITableViewController {

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return places.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CustomTableViewCell
        
        let place = places[indexPath.row]
        
        cell.nameLabel.text = place.name
        cell.placeImage.image = UIImage(named: place.image)
        cell.locationLabel.text = place.location
        cell.typeLabel.text = place.type.rawValue
        
        cell.placeImage.contentMode = .scaleAspectFill
        cell.placeImage.layer.cornerRadius = cell.placeImage.frame.size.height / 2
    
        return cell
    }
    
    @IBAction func cancelAction(_ segue: UIStoryboardSegue) {
    }

}
