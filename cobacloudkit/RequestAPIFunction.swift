//
//  RequestAPIFunction.swift
//  cobacloudkit
//
//  Created by Sessario Ammar Wibowo on 18/05/25.
//

import Foundation
import PhotosUI

func requestReport() -> [String]{
    
    var objectTag: String?
    var ColorTag: String?
    var BrandTag: String?
    
    var errorMessage: [String] = ["error"]
    
    guard let url = URL(string: "http://192.168.1.10:8000/generateReport") else { return errorMessage }
    
    var request = URLRequest(url: url)
    request.httpMethod = "POST"

    let json: [String: Any] = [
        "model": "llava:latest",
        "prompt": """
        Standarize this to make the input more uniformed in JSON format with the following fields:
        - object_name: the name of the object (e.g. jaket into Jacket)
        - object_color: the color of the object, only one color to describe it (e.g. merah into red, yello ito yellow)
        - object_brand: the brand (optional, return null if unknown)
        Return only the JSON object, no explanation or description.
        """,
        "stream": false
    ]

    do {
        let jsonData = try JSONSerialization.data(withJSONObject: json)
        request.httpBody = jsonData
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    } catch {
        print("Failed to encode JSON:", error)
        return errorMessage
    }

    URLSession.shared.dataTask(with: request) { data, res, err in
        defer {
            DispatchQueue.main.async {
                // UI updates go here if needed
            }
        }

        if let data = data, let rawResponse = String(data: data, encoding: .utf8) {
            print("Raw response JSON: \(rawResponse)")
        }
        
        if let err = err {
            print("Request error:", err)
            return
        }

        guard let data = data else {
            print("No response data")
            return
        }

        do {
            if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
               var responseString = json["response"] as? String {

                // Remove triple backticks and possible "json" label
                responseString = responseString
                    .replacingOccurrences(of: "```json", with: "")
                    .replacingOccurrences(of: "```", with: "")
                    .trimmingCharacters(in: .whitespacesAndNewlines)

                // Convert to Data
                guard let responseData = responseString.data(using: .utf8) else {
                    print("Failed to convert cleaned string to Data")
                    return
                }

                // Parse inner JSON
                if let nestedJson = try JSONSerialization.jsonObject(with: responseData) as? [String: Any] {
                    DispatchQueue.main.async {
                        let objectName = nestedJson["object_name"] as? String ?? "Unknown"
                        let objectColor = nestedJson["object_color"] as? String ?? "Unknown"
                        let objectBrand = nestedJson["object_brand"] as? String ?? "Unknown"
                        
                        objectTag = objectName
                        ColorTag = objectColor
                        BrandTag = objectBrand
                    }
                } else {
                    print("Failed to parse nested JSON")
                }
            } else {
                print("Unexpected JSON format")
            }
        } catch {
            print("JSON parsing error:", error)
        }
    }.resume()
    
    
     
        return [objectTag ?? "Unknown", ColorTag ?? "Unknown", BrandTag ?? "Unknown"]
        
    
    
}

func requestTags(from image: UIImage, completion: @escaping ([String]) -> Void) {
    guard let url = URL(string: "http://192.168.1.10:8000/generateReport") else {
        completion(["error URL"])
        return
    }

    guard let imageData = image.jpegData(compressionQuality: 1.0) else {
        completion(["Could not convert image to JPEG data"])
        return
    }

    let base64String = imageData.base64EncodedString()

    var request = URLRequest(url: url)
    request.httpMethod = "POST"

    let json: [String: Any] = [
        "model": "llava:latest",
        "images": [base64String],
        "prompt": """
        Analyze the submitted image and respond in JSON format with the following fields:
        - object_name: the name of the main visible object (e.g. pants, shirt, bag)
        - object_color: the color of the object, only one color to describe it (e.g. red, blue, beige)
        - object_brand: the brand (optional, return null if unknown)
        Return only the JSON object, no explanation or description.
        """,
        "stream": false
    ]

    do {
        let jsonData = try JSONSerialization.data(withJSONObject: json)
        request.httpBody = jsonData
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    } catch {
        print("Failed to encode JSON:", error)
        completion(["Failed to encode JSON"])
        return
    }

    URLSession.shared.dataTask(with: request) { data, res, err in
        if let err = err {
            print("Request error:", err)
            completion(["Request error"])
            return
        }

        guard let data = data else {
            print("No response data")
            completion(["No response data"])
            return
        }

        do {
            if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
               var responseString = json["response"] as? String {

                responseString = responseString
                    .replacingOccurrences(of: "```json", with: "")
                    .replacingOccurrences(of: "```", with: "")
                    .trimmingCharacters(in: .whitespacesAndNewlines)

                guard let responseData = responseString.data(using: .utf8) else {
                    print("Failed to convert cleaned string to Data")
                    completion(["Failed to decode response string"])
                    return
                }

                if let nestedJson = try JSONSerialization.jsonObject(with: responseData) as? [String: Any] {
                    let objectName = nestedJson["object_name"] as? String ?? "Unknown"
                    let objectColor = nestedJson["object_color"] as? String ?? "Unknown"
                    let objectBrand = nestedJson["object_brand"] as? String ?? "Unknown"
                    DispatchQueue.main.async {
                        completion([objectName, objectColor, objectBrand])
                    }
                } else {
                    print("Failed to parse nested JSON")
                    completion(["Parsing error"])
                }
            } else {
                print("Unexpected JSON format")
                completion(["Invalid response format"])
            }
        } catch {
            print("JSON parsing error:", error)
            completion(["JSON parsing error"])
        }
    }.resume()
}
