import SwiftUI
import SwiftData
import PhotosUI

struct SearchBarView: View {

    @Binding var searchText: String
    @Binding var isSearching: Bool
    @Binding var selectedImageItem: PhotosPickerItem?
    
    var body: some View {
        HStack {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                
                TextField("Search items...", text: $searchText, onEditingChanged: { isEditing in
                    withAnimation {
                        isSearching = isEditing
                    }
                })
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .submitLabel(.search)
                .onSubmit {
                    isSearching = true
                }
                
                if !searchText.isEmpty {
                    Button(action: {
                        searchText = ""
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                    }
                }

                PhotosPicker(
                    selection: $selectedImageItem,
                    matching: .images,
                    photoLibrary: .shared()) {
                        Image(systemName: "photo")
                            .resizable()
                            .frame(width: 22, height: 22)
                            .padding(6)
                            .foregroundColor(.blue)
                }
            }
            .animation(.easeInOut(duration: 0.2), value: searchText)
            .padding(10)
            .background(Color(.systemGray6))
            .cornerRadius(10)
            
            if isSearching {
                Button("Cancel") {
                    withAnimation {
                        isSearching = false
                        searchText = ""
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    }
                }
                .foregroundColor(.blue)
                .transition(.move(edge: .trailing).combined(with: .opacity))
            }
        }
        .padding(.horizontal)
    }
}

struct TagView: View {
    @Binding var objectTag: String?
    @Binding var ColorTag: String?
    @Binding var BrandTag: String?
    
    var body: some View {
        HStack(spacing: 8) {
            Label("Object: \(objectTag ?? "")", systemImage: "tag")
            if let color = ColorTag {
                Label("Color: \(color)", systemImage: "paintpalette")
            }
            if let brand = BrandTag {
                Label("Brand: \(brand)", systemImage: "briefcase")
            }

            Button(action: {
                self.objectTag = nil
                self.ColorTag = nil
                self.BrandTag = nil
            }) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.gray)
            }
            .buttonStyle(BorderlessButtonStyle())
        }
        .padding(.horizontal)
        .padding(.vertical, 6)
        .background(Color(.systemGray6))
        .cornerRadius(8)
        .transition(.opacity)
    }
}

struct MainContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [Item]
    @Binding var selectedTab: Int
    @Binding var searchText: String
    @Binding var isSearching: Bool
    @Binding var selectedImageItem: PhotosPickerItem?
    @Binding var objectTag: String?
    @Binding var ColorTag: String?
    @Binding var BrandTag: String?
    @Binding var selectedItem: Item?
    @Binding var isGetter: Bool
    var sortOption: SortOption
    var selectedCategory: String?
    var isAdmin: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Picker Tabs
            Picker("Item Status", selection: $selectedTab) {
                Text("Unclaimed").tag(0)
                Text("Claimed").tag(1)
                Text("All").tag(2)
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)
            .frame(width: 300)
            .frame(maxWidth: .infinity, alignment: .center)
            
            // Search Bar with Image Picker
            SearchBarView(
                searchText: $searchText,
                isSearching: $isSearching,
                selectedImageItem: $selectedImageItem
            )
            
            if let objectTag = objectTag {
                TagView(
                    objectTag: $objectTag,
                    ColorTag: $ColorTag,
                    BrandTag: $BrandTag
                )
            }
            
            // Filtered and Sorted Items
            let filteredItems = sortedAndFilteredItems()
            
            ItemGridView(
                filteredItems: filteredItems,
                isSearching: isSearching,
                selectedTab: selectedTab,
                selectedItem: $selectedItem,
                isGetter: $isGetter
            )
        }
    }
    
    // MARK: - Helper Functions
    func similarityScore(for item: Item) -> Int {
        var score = 0

        if let objectTag = objectTag?.lowercased(),
           item.itemObjectTag?.lowercased() == objectTag {
            score += 100
        }

        if let colorTag = ColorTag?.lowercased(),
           item.itemColorTag?.lowercased() == colorTag {
            score += 10
        }

        if let brandTag = BrandTag?.lowercased(),
           item.itemBrandTag?.lowercased() == brandTag {
            score += 1
        }

        return score
    }
    
    func sortedAndFilteredItems() -> [Item] {
        var filtered = items.filter {
            switch selectedTab {
            case 0: return !$0.isClaimed
            case 1: return $0.isClaimed
            default: return true
            }
        }

        if let category = selectedCategory {
            filtered = filtered.filter { $0.category == category }
        }

        if !searchText.isEmpty {
            filtered = filtered.filter { $0.itemName.localizedCaseInsensitiveContains(searchText) }
        }

        if let objectTag = objectTag {
            filtered = filtered.filter {
                $0.itemObjectTag?.lowercased() == objectTag.lowercased()
            }
        }

        if let colorTag = ColorTag {
            filtered = filtered.filter {
                $0.itemColorTag?.lowercased() == colorTag.lowercased()
            }
        }

        if let brandTag = BrandTag {
            filtered = filtered.filter {
                $0.itemBrandTag?.lowercased() == brandTag.lowercased()
            }
        }

        filtered.sort {
            similarityScore(for: $0) > similarityScore(for: $1)
        }

        return filtered
    }
}

struct ItemGridView: View {
    var filteredItems: [Item]
    var isSearching: Bool
    var selectedTab: Int
    @Binding var selectedItem: Item?
    @Binding var isGetter: Bool
    
    var body: some View {
        Group {
            if filteredItems.isEmpty && isSearching {
                NotFoundView()
            } else {
                VStack(spacing: 0) {
                    Divider()
                    ScrollView {
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                            ForEach(filteredItems, id: \.id) { item in
                                realItemCard(item: item, showClaimedDate: selectedTab == 1)
                                    .onTapGesture {
                                        selectedItem = item
                                        isGetter.toggle()
                                    }
                            }
                        }
                        .padding(.horizontal)
                    }
                    .listStyle(.plain)
                }
            }
        }
    }
}

struct NotFoundView: View {
    var body: some View {
        VStack(spacing: 12) {
            Image("NotFound")
                .resizable()
                .scaledToFit()
                .frame(width: 300, height: 300)
                .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct ContentView: View {
    var initialQuery: String?
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [Item]
    @Query private var reports: [Report]
    @State private var showReportPage = false
    @State private var objectTag: String? = "Jacket"
    @State private var ColorTag: String? = "Brown"
    @State private var BrandTag: String? = "H&M"
    @State private var imageDescription: String?
    @State private var searchText = ""
    @State private var selectedTab = 0
    @State private var sortOption: SortOption = .date
    @State private var selectedCategory: String? = nil
    @State private var selectedItem: Item? = nil
    @State private var isGetter = false
    @State private var isAddingItem = false
    @State private var isAdmin = false
    @State private var isShowingLogin = false
    @State private var isSearching = false
    
    @State private var selectedImageItem: PhotosPickerItem? = nil
    @State private var selectedUIImage: UIImage? = nil
    
    var body: some View {
        NavigationView {
            MainContentView(
                selectedTab: $selectedTab,
                searchText: $searchText,
                isSearching: $isSearching,
                selectedImageItem: $selectedImageItem,
                objectTag: $objectTag,
                ColorTag: $ColorTag,
                BrandTag: $BrandTag,
                selectedItem: $selectedItem,
                isGetter: $isGetter,
                sortOption: sortOption,
                selectedCategory: selectedCategory,
                isAdmin: isAdmin
            )
            .onAppear {
                print(reports)
                print(items)
            }
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    if !isAdmin {
                        Color.clear
                            .frame(width: 90, height: 30)
                            .contentShape(Rectangle())
                            .onLongPressGesture(minimumDuration: 1) {
                                isShowingLogin = true
                                print(reports)
                            }
                    } else {
                        Button("Logout") {
                            isAdmin.toggle()
                        }
                    }
                    
                    Menu {
                        Section(header: Text("Sort By")) {
                            Button("Alphabetical") { sortOption = .alphabetical }
                            Button("Date Found") { sortOption = .date }
                        }
                        Section(header: Text("Filter By Category")) {
                            Button("All") { selectedCategory = nil }
                            Button("Electronics") { selectedCategory = "Electronics" }
                            Button("Clothing") { selectedCategory = "Clothing" }
                            Button("Accessories") { selectedCategory = "Accessories" }
                        }
                    } label: {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                    }
                }
                
                ToolbarItem(placement: .navigationBarLeading) {
                    if isAdmin {
                        Button(action: { isAddingItem = true }) {
                            Image(systemName: "plus")
                        }
                    } else {
                        ZStack {
                            Button(action: { showReportPage = true }) {
                                Image(systemName: "plus")
                            }
                            
                            NavigationLink(
                                destination: ReportPage(),
                                isActive: $showReportPage
                            ) {
                                EmptyView()
                            }
                        }
                    }
                }
            }
            .sheet(isPresented: $isShowingLogin) {
                AdminLoginView(isAdmin: $isAdmin)
            }
            .sheet(item: $selectedItem) { item in
                ItemDetailView(item: item, isAdmin: isAdmin)
            }
            .sheet(isPresented: $isAddingItem) {
                AddItemView(isPresented: $isAddingItem)
            }
        }
        .onAppear {
            if let query = UserDefaults.standard.string(forKey: "launchSearchQuery") {
                    searchText = query
                    isSearching = true
                    UserDefaults.standard.removeObject(forKey: "launchSearchQuery")
            }
        }
        .preferredColorScheme(.light)
        .onChange(of: selectedImageItem) { newItem in
            Task {
                if let data = try? await newItem?.loadTransferable(type: Data.self),
                   let uiImage = UIImage(data: data) {
                    selectedUIImage = uiImage
                    handleImageSearch(from: uiImage)
                }
            }
        }
    }
    
    func handleImageSearch(from image: UIImage) {
        guard let url = URL(string: "http://10.60.54.166:8000/generate") else { return }

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
            return
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

                    responseString = responseString
                        .replacingOccurrences(of: "```json", with: "")
                        .replacingOccurrences(of: "```", with: "")
                        .trimmingCharacters(in: .whitespacesAndNewlines)

                    guard let responseData = responseString.data(using: .utf8) else {
                        print("Failed to convert cleaned string to Data")
                        return
                    }

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
    }
}
enum SortOption {
    case alphabetical, date
}



#Preview {
    let config = ModelConfiguration()
    let container = try! ModelContainer(for: Item.self, Report.self, configurations: config)
    
    for item in Item.dummyData() {
        container.mainContext.insert(item)
    }
    
    return ContentView()
        .modelContainer(container)
}
