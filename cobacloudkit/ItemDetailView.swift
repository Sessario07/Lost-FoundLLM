//
//  ItemDetailView.swift
//  cobacloudkit
//
//  Created by Sessario Ammar Wibowo on 02/04/25.
//

import SwiftUI
import PhotosUI

struct ItemDetailView: View {
    @Environment(\.dismiss) var dismiss
    var item: Item
    var isAdmin: Bool
    
    @State private var updatedItemName: String = ""
    @State private var updatedCategory: String = ""
    @State private var updatedLocationFound: String = ""
    @State private var updatedClaimer: String = ""
    @State private var updatedClaimerContact: String = ""
    @State private var updatedDescription: String = ""
    @State private var updatedDateFound: Date? = nil
    @State private var updatedDateClaimed: Date? = nil
    @State private var notSameClaimerAndContact: Bool = false
    
    @State var isUpdate: Bool = false
    @State var text: String = ""
    @State private var editableDescription: String = ""

    
    
    // MARK: - Reusable Row
    struct DetailRow: View {
        var title: String
        var icon: String
        var value: String
        var isDate: Bool = false
        var isStatus: Bool = false

        var body: some View {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.gray)

                HStack(spacing: 6) {
                    Image(systemName: icon)
                        .foregroundColor(isStatus ? (value == "Claimed" ? .green : .orange) : .black)

                    Text(formatValue())
                        .font(.body)
                        .fontWeight(.semibold)
                }
            }
        }
        
        

        private func formatValue() -> String {
            if isDate {
                // Optionally format if needed later
                return value
            }
            return value
        }
        
        private func formattedDate(_ date: Date?) -> String {
            guard let date = date else { return "-" }
            let formatter = DateFormatter()
            formatter.dateFormat = "d/M/yy"
            return formatter.string(from: date)
        }
    }
    
    struct InsertStringRow: View {
        var title: String
        var icon: String
        @Binding var text: String


        var body: some View {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.gray)

                HStack(spacing: 6) {
                    Image(systemName: icon)
                        .foregroundColor(.black)

                    TextField("Enter \(text)", text: $text)
                        .font(.body)
                        .fontWeight(.semibold)
                        
                }
            }
        }
    }
    
    struct InsertImageRow: View {
        var title: String
        var icon: String
        @Binding var selectedImage: UIImage?
        @State private var selectedItem: PhotosPickerItem?

        var body: some View {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.gray)

                HStack(spacing: 6) {
                    Image(systemName: icon)
                        .foregroundColor(.black)

                    PhotosPicker(selection: $selectedItem, matching: .images) {
                        Text(selectedImage == nil ? "Select Image" : "Image Selected")
                            .font(.body)
                            .fontWeight(.semibold)
                            .foregroundColor(.blue)
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
        }
    }
    
    struct InsertDateRow: View {
        var title: String
        var icon: String
        @Binding var selectedDate: Date?

        var body: some View {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.gray)

                HStack(spacing: 6) {
                    Image(systemName: icon)
                        .foregroundColor(.black)

                    DatePicker(
                        "",
                        selection: Binding(
                            get: { selectedDate ?? Date() },
                            set: { selectedDate = $0 }
                        ),
                        displayedComponents: .date
                    )
                    .labelsHidden()
                }
            }
        }
    }

    var body: some View {
        if(!isUpdate){
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // MARK: - Header
                    HStack {
                        Text("Item Details")
                            .font(.title2)
                            .fontWeight(.semibold)
                        Spacer()
                        Button(action: {
                            dismiss()
                        }) {
                            Image(systemName: "xmark")
                                .foregroundColor(.black)
                                .padding(10)
                                .background(Color.gray.opacity(0.2))
                                .clipShape(Circle())
                        }
                    }

                    // MARK: - Image
                    Image(uiImage: loadImage(named: item.imageName ?? "") ?? UIImage(systemName: "photo")!)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 370, height: 300)
                        .clipped()
                        .cornerRadius(20)

                    // MARK: - Grid
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], alignment: .leading, spacing: 16) {
                        DetailRow(title: "Item", icon: "cube.box.fill", value: item.itemName ?? "")
                        DetailRow(title: "Category", icon: "tag.fill", value: item.category ?? "")
                        DetailRow(title: "Date Found", icon: "calendar", value: formattedDate(item.dateFound))
                        DetailRow(title: "Location Found", icon: "map.fill", value: item.locationFound ?? "")
                        DetailRow(title: "Status", icon: item.isClaimed ? "checkmark.circle.fill" : "clock.fill", value: item.isClaimed ? "Claimed" : "Unclaimed", isStatus: true)
                        DetailRow(title: "Claim Item", icon: "location.fill", value: "Front Desk")

                        if let claimedDate = item.dateClaimed {
                            DetailRow(title: "Date Claimed", icon: "calendar.badge.clock", value: formattedDate(claimedDate))
                        }
                        
                        if item.isClaimed, let claimer = item.claimer, let contact = item.claimerContact {
                                DetailRow(title: "Claimer", icon: "person.fill", value: claimer)
                                DetailRow(title: "Contact", icon: "phone.fill", value: contact)
                            
                        }

                        
                    }
                    .padding(.horizontal, 12)
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Description")
                            .font(.subheadline)
                            .foregroundColor(.gray)

                        HStack(alignment: .top, spacing: 6) {
                            Image(systemName: "doc.text.fill")
                                .foregroundColor(.black)
                                .padding(.top, 2) // optional tweak for visual alignment

                            Text(item.itemDescription ?? "")
                                .font(.body)
                                .fontWeight(.semibold)
                                .fixedSize(horizontal: false, vertical: true) // allows multiline
                        }
                    }
                    .gridCellColumns(2)
                    .padding(.horizontal, 12)
                }
                .padding(.horizontal)
                .padding(.top)
                .padding(.bottom, 40)
            }
            .background(Color.white)
            .presentationDragIndicator(.visible)
        }else{
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // MARK: - Header
                    HStack {
                        Text("Item Details Update")
                            .font(.title2)
                            .fontWeight(.semibold)
                        Spacer()
                        Button(action: {
                            dismiss()
                        }) {
                            Image(systemName: "xmark")
                                .foregroundColor(.black)
                                .padding(10)
                                .background(Color.gray.opacity(0.2))
                                .clipShape(Circle())
                        }
                    }

                    // MARK: - Image
                    Image(uiImage: loadImage(named: item.imageName ?? "") ?? UIImage(systemName: "photo")!)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 370, height: 300)
                        .clipped()
                        .cornerRadius(20)

                    // MARK: - Grid
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], alignment: .leading, spacing: 16) {
                        InsertStringRow(title: "Item", icon: "cube.box.fill", text: $updatedItemName )
                        InsertStringRow(title: "Category", icon: "tag.fill", text: $updatedCategory)
                        InsertDateRow(title: "Date Found", icon: "calendar", selectedDate: $updatedDateFound)
                        InsertStringRow(title: "Location Found", icon: "map.fill", text: $updatedLocationFound)
                        InsertStringRow(title: "Claimer", icon: "person.fill", text: $updatedClaimer)
                        InsertDateRow(title: "Date Claimed", icon: "calendar", selectedDate: $updatedDateClaimed)
                        InsertStringRow(title: "Claimer Contact", icon: "person.fill", text: $updatedClaimerContact)
                        InsertStringRow(title: "Description", icon: "cube.box.fill", text: $updatedDescription)
                        
                    

                        
                    }
                    .alert("Error", isPresented: $notSameClaimerAndContact) {
                        Button("OK", role: .cancel) {
                            //nothing
                        }
                    } message: {
                        Text("The claimer cannot be nil if the contact is not nil.")
                    }
                    .padding(.horizontal, 12)
                    .gridCellColumns(2)
                    .padding(.horizontal, 12)
                }
                .padding(.horizontal)
                .padding(.top)
                .padding(.bottom, 40)
            }
            .background(Color.white)
            .presentationDragIndicator(.visible)
            .onAppear {
                updatedItemName = item.itemName ?? ""
                    updatedCategory = item.category ?? ""
                    updatedLocationFound = item.locationFound ?? ""
                    updatedClaimer = item.claimer ?? ""
                    updatedClaimerContact = item.claimerContact ?? ""
                    updatedDescription = item.itemDescription ?? ""
                    updatedDateFound = item.dateFound ?? Date()
                    updatedDateClaimed = item.dateClaimed
                }
        }

        if isAdmin {
            Button(action: {
                if(!isUpdate){
                    isUpdate.toggle()
                }else{
                    
                    if(updatedClaimer == "" && updatedClaimerContact != ""){
                        notSameClaimerAndContact.toggle()
                        return
                    }
                    item.itemName = updatedItemName
                    item.category = updatedCategory
                    item.locationFound = updatedLocationFound
                    if(updatedClaimer != ""){
                        item.claimer = updatedClaimer
                    }else{
                        item.claimer = nil
                    }
                    if(updatedClaimerContact != ""){
                        item.claimerContact = updatedClaimerContact
                    }else{
                        item.claimerContact = nil
                    }
                    item.itemDescription = updatedDescription
                    item.dateFound = updatedDateFound ?? item.dateFound
                    if(updatedDateClaimed == nil){
                        item.dateClaimed = updatedDateClaimed
                    }else{
                        item.dateClaimed = nil
                    }
                    if((item.claimer) != nil){
                        item.isClaimed = true
                    }
                    
                    if(updatedClaimer == ""){
                        item.claimer = nil
                        item.claimerContact = nil
                        item.isClaimed = false
                    }
                    dismiss()
                }
            }) {
                Text("Update")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(12)
            }
            .padding(.horizontal)
            .padding(.top)
        }
                   
    
}

    private func formattedDate(_ date: Date?) -> String {
        guard let date = date else { return "-" }
        let formatter = DateFormatter()
        formatter.dateFormat = "d/M/yy"
        return formatter.string(from: date)
    }
}



