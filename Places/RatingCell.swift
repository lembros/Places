//
//  RatingCell.swift
//  Places
//
//  Created by Егор Губанов on 17.07.2022.
//

import UIKit

class RatingCell: UITableViewCell {
    
    @IBOutlet var stars: [UIButton]!
    
    var rating = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupStars()
    }
    
    private func setupStars() {
        let size = CGSize(width: 60, height: 60)
        let emptyStar = UIImage(named: "emptyStar")?.scalePreservingAspectRatio(targetSize: size)
        let highlightedStar = UIImage(named: "highlightedStar")?.scalePreservingAspectRatio(targetSize: size)
        let filledStar = UIImage(named: "filledStar")?.scalePreservingAspectRatio(targetSize: size)

        
        for button in stars {
            button.setImage(emptyStar, for: .normal)
            button.setImage(highlightedStar, for: .highlighted)
            button.setImage(filledStar, for: .selected)
                        
            button.frame.size = size
            button.tintColor = .clear
            button.addTarget(self, action: #selector(changeRating(_:)), for: .touchUpInside)
        }
    }
    
    @objc func changeRating(_ sender: UIButton) {
        let number = numberOfStar(sender)
        
        let selectionFeedbackGenerator = UISelectionFeedbackGenerator()
        selectionFeedbackGenerator.selectionChanged()
        
        if number == rating {
            setNewRating(0)
            return
        }
        
        setNewRating(number)
    }
    
    private func numberOfStar(_ star: UIButton) -> Int {
        for (index, button) in stars.enumerated() {
            if button === star {
                return index + 1
            }
        }
        return 0
    }
    
    func setNewRating(_ rating: Int) {
        guard (0...5).contains(rating) else { return }
        for (index, button) in stars.enumerated() {
            button.isSelected = index < rating
        }
        self.rating = rating
    }

}


extension UIImage {
    func scalePreservingAspectRatio(targetSize: CGSize) -> UIImage {
        // Determine the scale factor that preserves aspect ratio
        let widthRatio = targetSize.width / size.width
        let heightRatio = targetSize.height / size.height
        
        let scaleFactor = min(widthRatio, heightRatio)
        
        // Compute the new image size that preserves aspect ratio
        let scaledImageSize = CGSize(
            width: size.width * scaleFactor,
            height: size.height * scaleFactor
        )

        // Draw and return the resized UIImage
        let renderer = UIGraphicsImageRenderer(
            size: scaledImageSize
        )

        let scaledImage = renderer.image { _ in
            self.draw(in: CGRect(
                origin: .zero,
                size: scaledImageSize
            ))
        }
        
        return scaledImage
    }
}
