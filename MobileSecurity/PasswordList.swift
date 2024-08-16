import SwiftUI
import CryptoKit

struct PasswordListView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.password, ascending: true)],
        animation: .default)
    private var items: FetchedResults<Item>

    var body: some View {
        NavigationView {
            List {
                ForEach(items) { item in
                    if let decryptedPassword = decryptPassword(item.password ?? "") {
                        Text(decryptedPassword)
                    }
                }
                .onDelete(perform: deleteItems)
            }
            .navigationTitle("Saved Passwords")
        }
    }

    private func decryptPassword(_ encryptedPassword: String) -> String? {
        guard let key = KeychainHelper.shared.retrieveKey() else { return nil }
        guard let data = Data(base64Encoded: encryptedPassword) else { return nil }
        
        do {
            let sealedBox = try AES.GCM.SealedBox(combined: data)
            let decryptedData = try AES.GCM.open(sealedBox, using: key)
            return String(data: decryptedData, encoding: .utf8)
        } catch {
            print("Decryption failed: \(error)")
            return nil
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { items[$0] }.forEach(viewContext.delete)

            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}
