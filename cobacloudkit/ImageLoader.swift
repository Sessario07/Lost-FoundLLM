//
//  ImageLoader.swift
//  cobacloudkit
//
//  Created by Nicholas  on 08/04/25.
//

import UIKit

func loadImage(named name: String) -> UIImage? {
    let fileURL = FileManager.default
        .urls(for: .documentDirectory, in: .userDomainMask)
        .first?
        .appendingPathComponent(name)
    
    if let fileURL = fileURL, let imageData = try? Data(contentsOf: fileURL) {
        return UIImage(data: imageData)
    }
    return nil
}
