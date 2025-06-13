//
//  UserViewModel.swift
//  CLC'd
//
//  Created by Peidong Chen on 6/1/25.
//

import SwiftUI
import Foundation
import Combine

class UserViewModel: ObservableObject {
    @AppStorage("username") var username: String = ""
}
