import SwiftUI
import CryptoKit

struct SavePasswordView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @AppStorage("isKeyInitialized") private var isKeyInitialized: Bool = false
    
    @State private var password = ""
    @State private var isPresented = false
    @State private var alertMessage = ""

    var body: some View {
        VStack {
            SecureField("Password", text: $password)
                .border(Color.black)
                .textFieldStyle(.roundedBorder)
                .padding()
            
            Button(action: addItem) {
                Text("Save Password")
            }
            .alert(isPresented: $isPresented) {
                Alert(title: Text("Password Manager"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
        }
        .padding()
        .onAppear {
            if !isKeyInitialized {
                initializeKeyIfNeeded()
                isKeyInitialized = true
            }
        }
    }

    private func addItem() {
        guard !password.isEmpty else {
            alertMessage = "Password cannot be empty."
            isPresented = true
            return
        }
        
        guard let encryptedPassword = encryptPassword(password) else {
            alertMessage = "Failed to encrypt the password."
            isPresented = true
            return
        }
        
        let newItem = Item(context: viewContext)
        newItem.password = encryptedPassword
        
        do {
            try viewContext.save()
            alertMessage = "The password was saved successfully."
            isPresented = true
            password = ""
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }

    private func encryptPassword(_ password: String) -> String? {
        guard let key = KeychainHelper.shared.retrieveKey() else { return nil }
        
        let data = Data(password.utf8)
        
        do {
            let sealedBox = try AES.GCM.seal(data, using: key)
            return sealedBox.combined?.base64EncodedString()
        } catch {
            print("Encryption failed: \(error)")
            return nil
        }
    }

    private func initializeKeyIfNeeded() {
        if KeychainHelper.shared.retrieveKey() == nil {
            let key = SymmetricKey(size: .bits256)
            let saved = KeychainHelper.shared.saveKey(key)
            if saved {
                print("Encryption key saved successfully")
            } else {
                print("Failed to save encryption key")
            }
        } else {
            print("Encryption key already exists")
        }
    }
}
