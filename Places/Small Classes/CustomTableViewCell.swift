//
//  CustomTableViewCell.swift
//  Places
//
//  Created by Егор Губанов on 13.07.2022.
//

import UIKit

class CustomTableViewCell: UITableViewCell {
    
    @IBOutlet weak var placeImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    
    @IBOutlet var images: [UIImageView]!
    
    var place: Place! {
        // As soon as place property is set, we can now setup rating stars
        didSet {
            let length = 15
            let size = CGSize(width: length, height: length)
            
            let emptyStar = UIImage(named: "emptyStar")?.scalePreservingAspectRatio(targetSize: size)
            let filledStar = UIImage(named: "filledStar")?.scalePreservingAspectRatio(targetSize: size)
            guard place != nil else { return }
            
            for (index, imageView) in images.enumerated() {
                imageView.image = index < place.rating ? filledStar : emptyStar
                imageView.frame.size = size
            }
        }
    }
}
