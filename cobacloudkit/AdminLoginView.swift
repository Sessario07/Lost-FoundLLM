//
//  AdminLoginView.swift
//  cobacloudkit
//
//  Created by Sessario Ammar Wibowo on 02/04/25.
//

import SwiftUI

struct AdminLoginView: View {
    @Binding var isAdmin: Bool
    @State private var username = ""
    @State private var password = ""
    @Environment(\ .presentationMode) var presentationMode
    @State private var showSuccessAlert = false
    @State private var showFailedAlert = false
    
    var body: some View {
        VStack {
            Text("Admin Login")
                .font(.title)
                .padding()
            TextField("Username", text: $username)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            SecureField("Password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            Button("Login") {
                if username == "Admin" && password == "password123" {
                    isAdmin = true
                    showSuccessAlert = true
                }else{
                    showFailedAlert = true
                }
                
            }
            .alert("Success", isPresented: $showSuccessAlert) {
                Button("OK", role: .cancel){
                    presentationMode.wrappedValue.dismiss()
                }
            } message: {
                Text("Welcome Admin!")
            }
            .alert("Failed", isPresented: $showFailedAlert) {
                Button("OK", role: .cancel){
                    
                }
            } message: {
                Text("Wrong credintials!")
            }
            .padding()
        }
    }
}

