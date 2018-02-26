//
//  Address+Extensions.swift
//  Code Test Ronnie Voss
//
//  Created by Ronnie Voss on 10/11/17.
//  Copyright © 2017 Ronnie Voss. All rights reserved.
//

import Foundation

extension Address {
    
    var formattedAddress: String {
        var components = [String]()
        
        if let string = addressLine1 {
            components.append(string)
        }
        if addressLine2 != "" {
            if let string = addressLine2 {
                components.append(string)
            }
        }
        
        var cityStateComponents = [String]()
        
        if let string = city {
            cityStateComponents.append(string)
        }
        
        if let string = state {
            cityStateComponents.append(string)
        }
        
        var subcomponents = [String]()
        
        let joinedCityState = cityStateComponents.joined(separator: ", ")
        if !joinedCityState.isEmpty {
            subcomponents.append(joinedCityState)
        }
        
        if let string = zipcode {
            subcomponents.append(string)
        }
        
        let joinedSubcomponents = subcomponents.joined(separator: " ")
        if !joinedSubcomponents.isEmpty {
            components.append(joinedSubcomponents)
        }
        
        return components.joined(separator: "\n")
    }
}
