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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        typePicker.dataSource = self
        typePicker.delegate = self
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
