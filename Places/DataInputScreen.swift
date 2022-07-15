//
//  DataInputScreen.swift
//  Places
//
//  Created by Егор Губанов on 13.07.2022.
//

import UIKit

class DataInputScreen: UITableViewController {

    @IBOutlet weak var placeNameField: UITextField!
    @IBOutlet weak var locationField: UITextField!
    @IBOutlet weak var typeField: UITextField!
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var addButton: UIBarButtonItem!
        
    var wasImageChosen = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        placeNameField.returnKeyType = .done
        locationField.returnKeyType = .done
        
        placeNameField.delegate = self
        locationField.delegate = self
        
        addButton.isEnabled = false
        placeNameField.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
    }
    
    // MARK: New place
    func getNewPlace() -> Place {
        
        let location = locationField.text!.isEmpty ? nil : locationField.text
        let imageData = wasImageChosen ? image.image?.pngData() : UIImage(named: "imagePlaceholder")?.pngData()
        
        let place = Place(name: placeNameField.text!,
                          location: location,
                          type: typeField.text,
                          imageData: imageData)
        return place
    }

    @IBAction func cancelPressed(_ sender: UIBarButtonItem) {
        dismiss(animated: true)
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        0
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        view.endEditing(true)
        
        if indexPath.row == 0 {
            
            let cameraIcon = UIImage(named: "camera")
            let photoIcon = UIImage(named: "photo")
            
            let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            
            let camera = UIAlertAction(title: "Camera", style: .default) { _ in
                self.chooseImagePicker(with: .camera)
            }
            camera.setValue(cameraIcon, forKey: "image")
            camera.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
            
            let library = UIAlertAction(title: "Choose from photo library", style: .default) { _ in
                self.chooseImagePicker(with: .photoLibrary)
            }
            library.setValue(photoIcon, forKey: "image")
            library.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
            
            let cancel = UIAlertAction(title: "Cancel", style: .cancel)
            
            alert.addAction(camera)
            alert.addAction(library)
            alert.addAction(cancel)
            
            present(alert, animated: true)
        }
    }
}


// MARK: Working with text
extension DataInputScreen: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @objc func textFieldChanged() {
        addButton.isEnabled = placeNameField.text! != ""
    }
}


// MARK: Working with images
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
        self.image.image = info[.editedImage] as? UIImage
        self.image.contentMode = .scaleAspectFill
        wasImageChosen = true
        dismiss(animated: true)
    }
}
