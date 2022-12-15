//
//  User.swift
//  ChatAppDemo
//
//  Created by BeeTech on 07/12/2022.
//

import Foundation

public struct User {
    let name: String
    let email: String
    let password: String
    let avatar: String
    let id: String
    let isActive: Bool
    init(dict: [String: Any]) {
        self.name = dict["name"] as? String ?? ""
        self.email = dict["email"] as? String ?? ""
        self.password = dict["password"] as? String ?? ""
        self.avatar = dict["avatar"] as? String ?? ""
        self.id = dict["id"] as? String ?? ""
        self.isActive = dict["isActive"] as? Bool ?? false
    }
}



