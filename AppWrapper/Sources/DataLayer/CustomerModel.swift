//
//  CustomerModel.swift
//  DataLayer
//
//  Created by Tymoteusz Pasieka on 10/19/25.
//

import Foundation
import RewardsAPI

public struct CustomerModel: Equatable, Sendable {
    public let name: String
    
    public init(name: String) {
        self.name = name
    }
    
    init(entity: CustomerEntity) {
        self.name = entity.name
    }
}

