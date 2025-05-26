//
//  Report.swift
//  cobacloudkit
//
//  Created by Sessario Ammar Wibowo on 13/05/25.
//

import SwiftData
import Foundation

@Model
class Report {
    var id: UUID?
    var itemName: String?
    var itemColor: String?
    var itemBrand: String?
    var reporteeDeviceId: String?

    init(id: UUID = UUID(), itemName: String, itemColor: String, itemBrand: String) {
        self.id = id
        self.itemName = itemName
        self.itemColor = itemColor
        self.itemBrand = itemBrand
    }
}
