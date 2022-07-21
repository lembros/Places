//
//  DataInputScreen.swift
//  Places
//
//  Created by Егор Губанов on 13.07.2022.
//

import UIKit
import Cosmos

class DataInputScreen: UITableViewController {

    // MARK: - IBOutlets
    
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var locationField: UITextField!
    @IBOutlet weak var typeField: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var cosmosView: CosmosView!
    @IBOutlet weak var addButton: UIBarButtonItem!
    
    var place: Place?
        
    private var wasImageChosen = false
    private let imagePlaceholder = UIImage(named: "Photo")
    
    // MARK: - ViewDidLoad
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        setupScreen()
        
        // To hide keyboard by 'Done' button
        nameField.delegate = self
        locationField.delegate = self
        
        // To update availability of 'done' button
        nameField.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
        
        // Haptic feedback while changing stars
        cosmosView.didTouchCosmos = { _ in
            let impactFeedbackgenerator = UIImpactFeedbackGenerator(style: .light)
            impactFeedbackgenerator.prepare()
            impactFeedbackgenerator.impactOccurred()
        }
    }
    
    private func setupScreen() {
        cosmosView.rating = 0
        
        // Get there only in edit mode
        if let place = place {
            
            title = place.name
            nameField.text = place.name
            locationField.text = place.location
            typeField.text = place.type
            
            // If place has image
            if let imageData = place.imageData {
                wasImageChosen = true
                imageView.image = UIImage(data: imageData)
                imageView.contentMode = .scaleAspectFill
            }
            cosmosView.rating = Double(place.rating)
        }
        
        addButton.isEnabled = nameField.hasText
        nameField.returnKeyType = .done
        locationField.returnKeyType = .done
    }
    
    // Empty method for exit segue
    @IBAction func closeMap(_ segue: UIStoryboardSegue) { }
    // Unwind segue from MapViewController
    @IBAction func locationReturned(_ segue: UIStoryboardSegue) {
        let svc = segue.source as! MapViewController
        
        let newAddress = svc.currentLocationLabel.text
        self.locationField.text = newAddress
    }
    
    // MARK: - New place
    
    func getNewPlace() -> Place {
        if !nameField.hasText {
            return Place()
        }
                
        let imageData = wasImageChosen ? imageView.image?.pngData() : nil
        
        place = Place(name: nameField.text!,
                      location: locationField.text,
                      type: typeField.text,
                      imageData: imageData,
                      rating: Int(cosmosView.rating))
        return place!
    }
    
    // MARK: - Table View Delegate
    
    // Get rid of header
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat { 0 }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // Hide keyboard when row touched
        view.endEditing(true)
        
        // Choosing image
        if indexPath.row == 0 {
            let cameraIcon = UIImage(systemName: "camera")
            let photoIcon = UIImage(systemName: "folder")
            let deleteIcon = UIImage(systemName: "clear")
            
            let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            
            let camera = UIAlertAction(title: "Camera", style: .default) { _ in
                self.chooseImagePicker(with: .camera)
            }
            camera.setValue(cameraIcon, forKey: "image")
            camera.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
            
            let photoLibrary = UIAlertAction(title: "Choose from photo library", style: .default) { _ in
                self.chooseImagePicker(with: .photoLibrary)
            }
            photoLibrary.setValue(photoIcon, forKey: "image")
            photoLibrary.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
            
            let deleteImage = UIAlertAction(title: " Delete image", style: .destructive) { _ in
                self.imageView.image = self.imagePlaceholder
                self.imageView.contentMode = .scaleAspectFit
                self.wasImageChosen = false
            }
            deleteImage.setValue(deleteIcon, forKey: "image")
            deleteImage.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
            
            let cancel = UIAlertAction(title: "Cancel", style: .cancel)
            
            alert.addAction(camera)
            alert.addAction(photoLibrary)
            alert.addAction(deleteImage)
            alert.addAction(cancel)
            
            present(alert, animated: true)
        }
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard ["ShowLocation", "ChooseLocation"].contains(segue.identifier) else { return }
        
        let dvc = segue.destination as! MapViewController
        dvc.place = getNewPlace()
        dvc.isShowingLocation = segue.identifier == "ShowLocation"
    }
    
}


// MARK: - Working with text

extension DataInputScreen: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @objc func textFieldChanged() {
        addButton.isEnabled = nameField.hasText
    }
}


// MARK: - Working with images

extension DataInputScreen: UIImagePickerControllerDelegate, UINavigationControllerDelegate  {
    func chooseImagePicker(with source: UIImagePickerController.SourceType) {
        guard UIImagePickerController.isSourceTypeAvailable(source) else { return }
        
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        picker.sourceType = source
        
        present(picker, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[.editedImage] as? UIImage
        wasImageChosen = true
        self.imageView.image = image
        self.imageView.contentMode = .scaleAspectFill
        dismiss(animated: true)
    }
}
