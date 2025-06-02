//
//  UserViewModel.swift
//  CLC'd
//
//  Created by Peidong Chen on 6/1/25.
//

import Foundation
import Combine

class UserViewModel: ObservableObject {
    @Published var username: String = ""
}
