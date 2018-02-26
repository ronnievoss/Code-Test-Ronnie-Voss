//
//  EditableSectionHeaderView.swift
//  Code Test Ronnie Voss
//
//  Created by Ronnie Voss on 10/11/17.
//  Copyright © 2017 Ronnie Voss. All rights reserved.
//

import Foundation
import UIKit

final class EditableSectionHeaderView: UIView {
    
    @IBOutlet weak var textLabel: UILabel?
    @IBOutlet weak var addButton: UIButton?
    
    var onTappedAddNew: (() -> Void)?
    
    @IBAction func didTapAddNewButton() {
        onTappedAddNew?()
    }
}
