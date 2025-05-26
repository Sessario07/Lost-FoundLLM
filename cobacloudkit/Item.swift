//
//  Item.swift
//  cobacloudkit
//
//  Created by Sessario Ammar Wibowo on 26/03/25.
//

import Foundation
import SwiftData

@Model
class Item: Identifiable {
    var id: UUID?
    var dateFound: Date = Date()
    var dateClaimed: Date?
    var itemName: String = ""
    var itemDescription: String?
    var isClaimed: Bool = false
    var imageName: String?
    var category: String?
    var locationFound: String?
    var claimer: String?
    var claimerContact: String?
    
    var itemObjectTag: String?
    var itemColorTag: String?
    var itemBrandTag: String?


    
    init(id: UUID = UUID(), dateFound: Date, dateClaimed: Date? = nil, itemName: String, itemDescription: String, isClaimed: Bool = false, imageName: String = "salemalekum", category: String, locationFound: String, claimer: String? = nil, claimerContact: String? = nil, ObjectTag: String? = nil, ColorTag: String? = nil, BrandTag: String? = nil) {
        self.id = id
        self.dateFound = dateFound
        self.dateClaimed = dateClaimed
        self.itemName = itemName
        self.itemDescription = itemDescription
        self.isClaimed = isClaimed
        self.imageName = imageName
        self.category = category
        self.locationFound = locationFound
        self.claimer = claimer
        self.claimerContact = claimerContact
        self.itemObjectTag = ObjectTag
        self.itemColorTag = ColorTag
        self.itemBrandTag = BrandTag
    }
}

extension Item {
    static func dummyData() -> [Item] {
        return [
            Item(
                id: UUID(),
                dateFound: Date(timeIntervalSinceNow: -86400 * 2),
                dateClaimed: nil,
                itemName: "Wallet",
                itemDescription: "A black leather wallet with some cash and cards inside budi santoso membeli makan di kantin ayam brocoli A black leather wallet with some cash and cards inside budi santoso membeli makan di kantin ayam brocoli A black leather wallet with some cash and cards inside budi santoso membeli makan di kantin ayam brocoli.",
                isClaimed: false,
                imageName: "NotFound.png",
                category: "Accessories",
                locationFound: "Library",
                claimer: nil,
                claimerContact: "0812-3456-7890"
            ),
            Item(
                id: UUID(),
                dateFound: Date(timeIntervalSinceNow: -86400 * 5),
                dateClaimed: Date(timeIntervalSinceNow: -86400 * 1),
                itemName: "Backpack",
                itemDescription: "A blue backpack containing books and a laptop charger.",
                isClaimed: true,
                imageName: "salemalekum",
                category: "Bags",
                locationFound: "Cafeteria",
                claimer: "John Doe",
                claimerContact: "0812-3456-7890"
            ),
            Item(
                id: UUID(),
                dateFound: Date(timeIntervalSinceNow: -86400 * 10),
                dateClaimed: nil,
                itemName: "Umbrella",
                itemDescription: "A red umbrella with a curved wooden handle.",
                isClaimed: false,
                imageName: "salemalekum",
                category: "Miscellaneous",
                locationFound: "Bus Stop",
                claimer: nil,
                claimerContact: "0812-3456-7890"
            ),
            Item(
                id: UUID(),
                dateFound: Date(timeIntervalSinceNow: -86400 * 7),
                dateClaimed: Date(timeIntervalSinceNow: -86400 * 3),
                itemName: "Smartphone",
                itemDescription: "A white iPhone 12 with a cracked screen protector.",
                isClaimed: true,
                imageName: "Yoga",
                category: "Electronics",
                locationFound: "Gym",
                claimer: "Jane Smith",
                claimerContact: "0812-3456-7890"
            ),
            Item(
                id: UUID(),
                dateFound: Date(timeIntervalSinceNow: -86400 * 7),
                dateClaimed: Date(timeIntervalSinceNow: -86400 * 3),
                itemName: "Smartphone",
                itemDescription: "A white iPhone 12 with a cracked screen protector.",
                isClaimed: true,
                imageName: "Yoga",
                category: "Electronics",
                locationFound: "Gym",
                claimer: "Jane Smith",
                claimerContact: "0812-3456-7890"
            ),
            Item(
                            dateFound: Date(timeIntervalSinceNow: -86400 * 2),
                            itemName: "Wallet",
                            itemDescription: "A black leather wallet with some cash and cards inside. Found near the library.",
                            isClaimed: false,
                            imageName: "wallet.png",
                            category: "Accessories",
                            locationFound: "Library",
                            claimer: nil,
                            claimerContact: nil,
                            ObjectTag: "Wallet",
                            ColorTag: "Black",
                            BrandTag: "Gucci"
                        ),
                        Item(
                            dateFound: Date(timeIntervalSinceNow: -86400 * 5),
                            dateClaimed: Date(timeIntervalSinceNow: -86400 * 1),
                            itemName: "Backpack",
                            itemDescription: "A blue backpack containing books and a laptop charger.",
                            isClaimed: true,
                            imageName: "backpack.png",
                            category: "Bags",
                            locationFound: "Cafeteria",
                            claimer: "John Doe",
                            claimerContact: "0812-3456-7890",
                            ObjectTag: "Backpack",
                            ColorTag: "Blue",
                            BrandTag: "Eiger"
                        ),
                        Item(
                            dateFound: Date(timeIntervalSinceNow: -86400 * 10),
                            itemName: "Umbrella",
                            itemDescription: "A red umbrella with a curved wooden handle.",
                            isClaimed: false,
                            imageName: "umbrella.png",
                            category: "Miscellaneous",
                            locationFound: "Bus Stop",
                            claimer: nil,
                            claimerContact: nil,
                            ObjectTag: "Umbrella",
                            ColorTag: "Red",
                            BrandTag: "Totes"
                        ),
                        Item(
                            dateFound: Date(timeIntervalSinceNow: -86400 * 7),
                            dateClaimed: Date(timeIntervalSinceNow: -86400 * 3),
                            itemName: "Smartphone",
                            itemDescription: "A white iPhone 12 with a cracked screen protector.",
                            isClaimed: true,
                            imageName: "iphone.png",
                            category: "Electronics",
                            locationFound: "Gym",
                            claimer: "Jane Smith",
                            claimerContact: "0812-9876-5432",
                            ObjectTag: "Phone",
                            ColorTag: "White",
                            BrandTag: "Apple"
                        ),
                        Item(
                            dateFound: Date(timeIntervalSinceNow: -86400 * 3),
                            itemName: "Water Bottle",
                            itemDescription: "A silver stainless steel water bottle with a dented lid.",
                            isClaimed: false,
                            imageName: "bottle.png",
                            category: "Miscellaneous",
                            locationFound: "Lecture Hall B",
                            claimer: nil,
                            claimerContact: nil,
                            ObjectTag: "Bottle",
                            ColorTag: "Silver",
                            BrandTag: "Thermos"
                        ),
            Item(
                            dateFound: Date(timeIntervalSinceNow: -86400 * 1),
                            itemName: "Jacket",
                            itemDescription: "A red jacket with a zipper and two side pockets.",
                            isClaimed: false,
                            imageName: "jacket_red.png",
                            category: "Clothing",
                            locationFound: "Library",
                            claimer: nil,
                            claimerContact: nil,
                            ObjectTag: "Jacket",
                            ColorTag: "Red",
                            BrandTag: "H&M"
                        ),
                        Item(
                            dateFound: Date(timeIntervalSinceNow: -86400 * 3),
                            itemName: "Jacket",
                            itemDescription: "A brown jacket, slightly worn, found on a chair.",
                            isClaimed: false,
                            imageName: "jacket_brown1.png",
                            category: "Clothing",
                            locationFound: "Cafeteria",
                            claimer: nil,
                            claimerContact: nil,
                            ObjectTag: "Jacket",
                            ColorTag: "Brown",
                            BrandTag: "H&M"
                        ),
                        Item(
                            dateFound: Date(timeIntervalSinceNow: -86400 * 4),
                            itemName: "Jacket",
                            itemDescription: "A brown jacket with a Uniqlo logo inside the collar.",
                            isClaimed: false,
                            imageName: "jacket_brown2.png",
                            category: "Clothing",
                            locationFound: "Lecture Hall C",
                            claimer: nil,
                            claimerContact: nil,
                            ObjectTag: "Jacket",
                            ColorTag: "Brown",
                            BrandTag: "Uniqlo"
                        ),
                        Item(
                            dateFound: Date(timeIntervalSinceNow: -86400 * 2),
                            itemName: "Jacket",
                            itemDescription: "A navy blue jacket with a button front and inner lining.",
                            isClaimed: false,
                            imageName: "jacket_blue.png",
                            category: "Clothing",
                            locationFound: "Gym",
                            claimer: nil,
                            claimerContact: nil,
                            ObjectTag: "Jacket",
                            ColorTag: "Navy Blue",
                            BrandTag: "Zara"
                        )
        ]
    }
}


