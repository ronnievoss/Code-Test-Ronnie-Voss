//
//  EditableCell.swift
//  Code Test Ronnie Voss
//
//  Created by Ronnie Voss on 10/11/17.
//  Copyright © 2017 Ronnie Voss. All rights reserved.
//

import Foundation
import UIKit

final class EditableCell: UITableViewCell {
    
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var textFieldLabel: UILabel!
    
    @IBOutlet weak var addressLabel: UITextField!
    @IBOutlet weak var address1: UITextField!
    @IBOutlet weak var address2: UITextField!
    @IBOutlet weak var city: UITextField!
    @IBOutlet weak var state: UITextField!
    @IBOutlet weak var zipcode: UITextField!
    
    @IBOutlet weak var phoneLabel: UITextField!
    @IBOutlet weak var phoneNumber: UITextField!
    
    @IBOutlet weak var emailLabel: UITextField!
    @IBOutlet weak var emailAddress: UITextField!
    
    enum Field: Int {
        case firstName = 1
        case lastName = 2
        case birthdate = 3
        case addressLabel = 4
        case address1 = 5
        case address2 = 6
        case city = 7
        case state = 8
        case zipcode = 9
        case phoneLabel = 10
        case phoneNumber = 11
        case emailLabel = 12
        case emailAddress = 13
    }
    
    var isEditable: Bool = false {
        didSet {
            textField?.isEnabled = isEditable
            textField?.borderStyle = isEditable ? .roundedRect : .none
        }
    }
}

