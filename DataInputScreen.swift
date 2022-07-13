//
//  DataInputScreen.swift
//  Places
//
//  Created by Егор Губанов on 13.07.2022.
//

import UIKit

class DataInputScreen: UITableViewController {

    @IBOutlet weak var typePicker: UIPickerView!
    @IBOutlet weak var placeNameField: UITextField!
    @IBOutlet weak var locationField: UITextField!
    @IBOutlet weak var image: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        placeNameField.returnKeyType = .done
        locationField.returnKeyType = .done
        
        placeNameField.delegate = self
        locationField.delegate = self
        
        typePicker.dataSource = self
        typePicker.delegate = self
    }


    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        0
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0: break
        default: view.endEditing(true)
        }
    }
}

extension DataInputScreen: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension DataInputScreen: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return Place.PlaceType.values.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return Place.PlaceType.values[row].rawValue
    }
    
}

extension DataInputScreen: UIPickerViewDelegate {
}
