//
//  DataInputScreen.swift
//  Places
//
//  Created by Егор Губанов on 13.07.2022.
//

import UIKit
import Cosmos

class DataInputScreen: UITableViewController {

    @IBOutlet weak var placeNameField: UITextField!
    @IBOutlet weak var locationField: UITextField!
    @IBOutlet weak var typeField: UITextField!
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var addButton: UIBarButtonItem! {
        didSet {
            addButton.isEnabled = false
        }
    }
    @IBOutlet weak var cosmosView: CosmosView!
    
    var place: Place?
    var currentTitle: String? = "New Place"
        
    var wasImageChosen = false
    
    
    // MARK: - ViewDidLoad
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        presentationController?.delegate = self
        
        setupScreen()
        
        placeNameField.delegate = self
        locationField.delegate = self
        
        placeNameField.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
        cosmosView.didTouchCosmos = { _ in
            let impactFeedbackgenerator = UIImpactFeedbackGenerator(style: .light)
            impactFeedbackgenerator.prepare()
            impactFeedbackgenerator.impactOccurred()
        }
        
    }
    
    private func setupScreen() {
        placeNameField.returnKeyType = .done
        locationField.returnKeyType = .done
        title = currentTitle
        
        guard let place = place else { return }

        addButton.isEnabled = true
        placeNameField.text = place.name
        locationField.text = place.location
        typeField.text = place.type
        image.image = UIImage(data: place.imageData!)
        if wasImageChosen {
            self.image.contentMode = .scaleAspectFill
        }
        

        cosmosView.rating = Double(place.rating)
    }
    
    @IBAction func closeMap(_ segue: UIStoryboardSegue) {
        
    }
    
    // MARK: - New place
    func getNewPlace() -> Place {
        if placeNameField.text == nil || placeNameField.text!.isEmpty {
            return Place()
        }
        
        let imageData = wasImageChosen ? image.image?.pngData() : UIImage(named: "imagePlaceholder")?.pngData()
        
        place = Place(name: placeNameField.text!,
                      location: locationField.text,
                      type: typeField.text,
                      imageData: imageData,
                      rating: Int(cosmosView.rating))
        return place!
    }
    
    // MARK: - Table View Delegate
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat { 0 }
    
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
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard ["ShowLocation", "ChooseLocation"].contains(segue.identifier) else { return }
        
        let dvc = segue.destination as! MapViewController
        dvc.place = place ?? getNewPlace()
        
        dvc.isShowingLocation = segue.identifier == "ShowLocation"
    }
    
    @IBAction func locationReturned(_ segue: UIStoryboardSegue) {
        let svc = segue.source as! MapViewController
        
        let newAdress = svc.currentLocationLabel.text
        self.locationField.text = newAdress
    }
}


// MARK: - Working with text

extension DataInputScreen: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @objc func textFieldChanged() {
        addButton.isEnabled = placeNameField.text! != ""
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
        self.image.image = info[.editedImage] as? UIImage
        self.image.contentMode = .scaleAspectFill
        wasImageChosen = true
        dismiss(animated: true)
    }
}

extension DataInputScreen: UIAdaptivePresentationControllerDelegate {
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        print(#function)
    }
    
    func presentationControllerWillDismiss(_ presentationController: UIPresentationController) {
        print(#function)
    }
}
