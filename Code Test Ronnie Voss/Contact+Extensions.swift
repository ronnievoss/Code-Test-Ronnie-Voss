//
//  Contact+Extensions.swift
//  Code Test Ronnie Voss
//
//  Created by Ronnie Voss on 10/11/17.
//  Copyright © 2017 Ronnie Voss. All rights reserved.
//

import Foundation

extension Contact {
    
    @objc var lastInitial: String {
        guard let lastName = lastName else {
            return ""
        }
        return (lastName as NSString).substring(to: 1).uppercased()
    }
    
    var fullName: String {
        var components = [String]()
        
        if let string = firstName {
            components.append(string)
        }
        
        if let string = lastName {
            components.append(string)
        }
        
        return components.joined(separator: " ")
    }
    
    var formattedBirthdate: String {
        guard let birthdate = birthdate else {
            return ""
        }
        
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: birthdate)
    }
}
