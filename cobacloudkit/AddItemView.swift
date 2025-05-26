import SwiftUI
import SwiftData
import PhotosUI


struct AddItemView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var reports: [Report]
    @Binding var isPresented: Bool
    
    @State private var itemName = ""
    @State private var itemDescription = ""
    @State private var category = "Electronics"
    @State private var locationFound = ""
    @State private var dateFound = Date()
    @State private var selectedImage: UIImage? = UIImage(named: "BlackJeans")
    @State private var selectedPhoto: PhotosPickerItem? = nil
    @State private var showSuccessAlert = false
    @State private var imageDescription = ""
    @State private var debugInfo = ""
    @State private var emptyInput = false
    @State private var isShowingCamera = false
    @State private var isShowingImagePicker = false
    @State private var itemObjectTag: String?
    @State private var itemColorTag: String?
    @State private var itemBrandTag: String?
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Item Details")) {
                    TextField("Item Name", text: $itemName)
                    TextField("Description", text: $itemDescription)
                    TextField("Location Found", text: $locationFound)
                    DatePicker("Date Found", selection: $dateFound, displayedComponents: .date)
                    Picker("Category", selection: $category) {
                        Text("Electronics").tag("Electronics")
                        Text("Clothing").tag("Clothing")
                        Text("Accessories").tag("Accessories")
                    }
                }
                
                Section(header: Text("Add Image")) {
                    PhotosPicker("Select Photo from Gallery", selection: $selectedPhoto, matching: .images)

                    Button("Take Photo with Camera") {
                        isShowingCamera = true
                    }

                    if let selectedImage = selectedImage {
                        Image(uiImage: selectedImage)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 200)
                            .cornerRadius(10)
                    }
                }
                
                if !imageDescription.isEmpty {
                    Section(header: Text("Image Analysis")) {
                        Text(imageDescription)
                    }
                }
            }
            .navigationTitle("Add Item")
            .alert("Success", isPresented: $showSuccessAlert) {
                Button("OK", role: .cancel) {
                    isPresented = false
                }
            } message: {
                Text("Item was successfully added!")
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { isPresented = false }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        addItem()
                    }
                }
            }
            .onChange(of: selectedPhoto) { newPhoto in
                loadSelectedImage()
            }
            .sheet(isPresented: $isShowingCamera) {
                ImagePicker(image: $selectedImage, sourceType: .camera)
                    .onDisappear {
                        if selectedImage != nil {
                            analyzeImage()
                        }
                    }
            }
        }
        .onAppear {
            if let selectedImage = selectedImage {
                analyzeImage()
            }
        }
        .alert("Error", isPresented: $emptyInput) {
            Button("OK", role: .cancel) {
                //empty
            }
        } message: {
            Text("The input cannot be empty!")
        }
    }
    
   
    
    func analyzeImage() {
        guard let url = URL(string: "http://10.60.54.166:8000/generate") else { return }

        guard let image = selectedImage else {
            imageDescription = "Could not load image"
            return
        }

        guard let imageData = image.jpegData(compressionQuality: 1.0) else {
            imageDescription = "Could not convert image to JPEG data"
            return
        }

        let base64String = imageData.base64EncodedString()
        imageDescription = base64String

        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        let json: [String: Any] = [
            "model": "llava:latest",
            "images": [imageDescription],
            "prompt": """
            Analyze the submitted image and respond in JSON format with the following fields:
            - object_name: the name of the main visible object (e.g. pants, shirt, bag)
            - object_color: the color of the object (e.g. red, blue, beige)
            - object_brand: the brand (optional, return null if unknown)
            - object_description: a brief description of the object, focus on it's features nothing else and describe the object like a human would, don't start with this image shows and so on
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
            return
        }

        URLSession.shared.dataTask(with: request) { data, res, err in
            defer {
                DispatchQueue.main.async {
                    // UI updates go here if needed
                }
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
                            let objectDesc = nestedJson["object_description"] as? String ?? "Unknown"
                            itemName = objectName
                            itemObjectTag = objectName
                            itemColorTag = objectColor
                            
                            if (objectBrand != "Unknown"){
                                itemBrandTag = objectBrand
                            } else {
                                itemBrandTag = nil
                            }
                            
                            itemDescription = objectDesc
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
    }
    
    func loadSelectedImage() {
        guard let selectedPhoto = selectedPhoto else { return }
        Task {
            if let data = try? await selectedPhoto.loadTransferable(type: Data.self),
               let uiImage = UIImage(data: data) {
                selectedImage = uiImage
                analyzeImage()
            }
        }
    }
    
    func saveImage(_ image: UIImage, withName name: String) {
        guard let data = image.jpegData(compressionQuality: 0.8) else { return }
        
        let fileURL = FileManager.default
            .urls(for: .documentDirectory, in: .userDomainMask)
            .first?
            .appendingPathComponent(name)
        
        do {
            try data.write(to: fileURL!)
            print("✅ Image saved successfully: \(fileURL!.absoluteString)")
        } catch {
            print("❌ Error saving image: \(error.localizedDescription)")
        }
    }
    func sendLocalNotification(title: String, body: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ Failed to schedule notification:", error)
            } else {
                print("✅ Notification scheduled")
            }
        }
    }
    
    func checkForMatchingReports(with tag: String) {
       
        
        print(reports)
        for report in reports {
            if report.itemName?.lowercased() == tag.lowercased() {
                sendLocalNotification(title: "Found a \(report.itemName ?? "an item")!", body: "hey! I found a \(report.itemName ?? "an item"), this might be yours!")
                break
            }
        }
    }
    
    func addItem() {
      
        if itemName.isEmpty || itemDescription.isEmpty || locationFound.isEmpty || category.isEmpty || dateFound == nil || selectedImage == nil{
            emptyInput.toggle()
            return
        }
        
        if(!emptyInput){
            let imageName = "item-\(UUID().uuidString).jpg"


            if let selectedImage = selectedImage {
                saveImage(selectedImage, withName: imageName)
            }


            let newItem = Item(
                id: UUID(),
                dateFound: dateFound,
                itemName: itemName,
                itemDescription: itemDescription,
                isClaimed: false,
                imageName: imageName,
                category: category,
                locationFound: locationFound,
                claimer: nil,
                ObjectTag: itemObjectTag,
                ColorTag: itemColorTag,
                BrandTag: itemBrandTag
            )

            modelContext.insert(newItem)
            checkForMatchingReports(with: itemObjectTag ?? "")
            showSuccessAlert = true
            
        }
            
        }
        
}
