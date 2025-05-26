import SwiftUI
import PhotosUI
import SwiftData


struct ReportPage: View {
    @Environment(\.presentationMode) private var presentationMode
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var reports: [Report]
    @State private var showWelcomeView = false
       
    @State private var showSuccess = false
    @State private var navigateAway = false
    @State private var objectTag: String?
    @State private var ColorTag: String?
    @State private var BrandTag: String?
    @State private var tags: [String] = []
    @State private var notfilled: Bool = false
    @State private var itemName = ""
    @State private var itemColor = ""
    @State private var itemBrand = ""
    @State private var description = "Describe It’s unique feature e.g. There’s a tear in the back"
    @State private var selectedImage: UIImage? = nil
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var showAlert = false
    
    var body: some View {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    
                    Group {
                        Text("Item Name *").fontWeight(.semibold)
                        TextField("What is the item you lost? e.g. Jacket", text: $itemName)
                            .padding()
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color(.systemGray4), lineWidth: 1)
                            )
                        
                        Text("Item Color *").fontWeight(.semibold)
                        TextField("What’s the color of said item? e.g. red", text: $itemColor)
                            .padding()
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color(.systemGray4), lineWidth: 1)
                            )
                        
                        HStack(spacing: 0) {
                            Text("Item Brand").fontWeight(.semibold)
                        }
                        TextField("what is the item’s brand? e.g. Probolinggo", text: $itemBrand)
                            .padding()
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color(.systemGray4), lineWidth: 1)
                            )
                    }
                    
                    Group {
                        Text("Description ").fontWeight(.semibold)
                        TextEditor(text: $description)
                            .foregroundStyle(description == "Describe It’s unique feature e.g. There’s a tear in the back" ? .gray : .black)
                            .frame(height: 100)
                            .padding()
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color(.systemGray4), lineWidth: 1)
                            )
                    }

                    Group {
                        HStack(spacing: 0) {
                            Text("Upload Your picture").fontWeight(.semibold)
                            Text("(Optional)").foregroundColor(.gray).font(.subheadline)
                        }
                        
                        VStack {
                            if let image = selectedImage {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 120)
                                    .cornerRadius(12)
                            } else {
                                PhotosPicker(selection: $selectedItem, matching: .images, photoLibrary: .shared()) {
                                    VStack {
                                        Image(systemName: "camera")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 40, height: 40)
                                            .foregroundColor(.gray)
                                        Text("Take a picture\nas item documentation")
                                            .font(.caption)
                                            .multilineTextAlignment(.center)
                                            .foregroundColor(.gray)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .frame(height: 120)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color(.systemGray4), style: StrokeStyle(lineWidth: 1, dash: [5]))
                                    )
                                }
                                .onChange(of: selectedItem) { newItem in
                                    Task {
                                        if let data = try? await newItem?.loadTransferable(type: Data.self),
                                           let uiImage = UIImage(data: data) {
                                            selectedImage = uiImage
                                        }
                                    }
                                }
                            }
                        }
                        .padding()
                    }

                    // Submit Button
                    Button(action: {
                        if itemName.trimmingCharacters(in: .whitespaces).isEmpty || itemColor.trimmingCharacters(in: .whitespaces).isEmpty {
                            showAlert = true
                            return
                        }
                        handleReport(itemName: itemName, itemColor: itemColor)
                    }) {
                        Text("Submit Item")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue.opacity(0.8))
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                    .padding(.top, 10)
                }
                .padding()
            }
            .navigationTitle("Report Lost Item")
            .navigationBarTitleDisplayMode(.inline)
            
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Missing Information"),
                      message: Text("Please fill in both the item name and item color."),
                      dismissButton: .default(Text("OK")))
            
            }
            .alert(isPresented: $showSuccess) {
                Alert(
                    title: Text("Success!"),
                    message: Text("Your report has been submitted."),
                    dismissButton: .default(Text("OK"), action: {
                        presentationMode.wrappedValue.dismiss()
                    })
                )
            }
        
    }

    func handleReport(itemName: String, itemColor: String) {
        guard let url = URL(string: "http://10.60.54.166:8000/generateReport") else {
            print("❌ Invalid URL")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let promptText = """
        Your task is to standardize and correct the following information into clean and consistent English.

        Perform the following actions:
        - Translate non-English words to English (e.g., "jaket" → "jacket", "merah" → "red")
        - Fix typos (e.g., "pant" → "pants", "yello" → "yellow")
        - Map to the closest standard label (e.g., "celana panjang" → "pants", "jeans" → "pants")
        - Use lowercase for all values except brand names
        - If brand is unknown, return null

        Here is the item:
        [
            {
                "object_name": "\(itemName)",
                "object_color": "\(itemColor)",
                "object_brand": null
            }
        ]

        Return the output strictly as a valid JSON object or array of objects in this format:
        {
            "object_name": "<standardized object name>",
            "object_color": "<standardized color>",
            "object_brand": "<brand name or null>"
        }

        Do not include any explanation or description outside of the JSON object. Only return a raw JSON object or array. Do NOT escape characters. Do NOT include code blocks or explanations.
        """

        let requestBody: [String: Any] = [
            "model": "llava:latest",
            "prompt": promptText,
            "stream": false
        ]

        do {
            let jsonData = try JSONSerialization.data(withJSONObject: requestBody)
            request.httpBody = jsonData
        } catch {
            print("❌ Failed to encode JSON:", error)
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Request error:", error)
                return
            }

            guard let data = data else {
                print("❌ No response data")
                return
            }

            do {
                guard
                    let outerJson = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                    var responseString = outerJson["response"] as? String
                else {
                    print("❌ Invalid or missing 'response' field in JSON")
                    print("Raw response:", String(data: data, encoding: .utf8) ?? "n/a")
                    return
                }

                responseString = responseString
                    .replacingOccurrences(of: "```json", with: "")
                    .replacingOccurrences(of: "```", with: "")
                    .trimmingCharacters(in: .whitespacesAndNewlines)

                guard let cleanedData = responseString
                    .replacingOccurrences(of: "\\_", with: "_")
                    .data(using: .utf8)
                else {
                    print("❌ Failed to convert cleaned string to Data")
                    return
                }

                let decoded = try JSONSerialization.jsonObject(with: cleanedData)

                DispatchQueue.main.async {
                    if let array = decoded as? [[String: Any]] {
                        for item in array {
                            let objectName = item["object_name"] as? String ?? "unknown"
                            let objectColor = item["object_color"] as? String ?? "unknown"
                            let objectBrand = item["object_brand"] as? String ?? "unknown"
                            print("✅ Parsed item:", objectName, objectColor, objectBrand)
                            
                            let newReport: Report = Report(id: UUID(), itemName: objectName, itemColor: objectColor, itemBrand: BrandTag ?? "Unknown")
                            
                            modelContext.insert(newReport)
                            
                            print(reports)
                            showSuccess.toggle()
                        }
                    } else if let obj = decoded as? [String: Any] {
                        let objectName = obj["object_name"] as? String ?? "unknown"
                        let objectColor = obj["object_color"] as? String ?? "unknown"
                        let objectBrand = obj["object_brand"] as? String ?? "unknown"
                        print("✅ Parsed object:", objectName, objectColor, objectBrand)
                        
                     
                        
                    } else {
                        print("❌ Response is neither an object nor array")
                    }
                }

            } catch {
                print("❌ JSON parsing error:", error)
                print("Raw response:", String(data: data, encoding: .utf8) ?? "n/a")
            }

        }.resume()
        
    }

}




#Preview {
    ReportPage()
}
