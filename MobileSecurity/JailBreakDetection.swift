import SwiftUI

struct JailBreakDetectionView: View {
    @State private var isPresented = false
    @State private var alertMessage = ""
    @State private var detected = [String]()
    @State private var detectionInfo = ""
    
    var body: some View {
        VStack {
            Button(action: isJailbroken) {
                Text("Check for Jailbreak")
            }
            .alert(isPresented: $isPresented) {
                Alert(title: Text("Jailbreak Detection"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
        }
    }
    
    private func checkForApps() {
        let jailbreakStores = ["Cydia", "Sileo", "Zebra"]
        let jailbreakURLs = ["cydia://", "sileo://", "zbra://"]

        for (index, store) in jailbreakStores.enumerated() {
            if let url = URL(string: jailbreakURLs[index]), UIApplication.shared.canOpenURL(url) {
                detected.append("\(store) detected")
            }
        }
    }

    private func checkForRootlessEnv() {
        if FileManager.default.fileExists(atPath: "/var/jb") {
            detected.append("/var/jb directory detected (rootless jailbreak environment)")
        }
    }

    private func isJailbroken() {
        detected.removeAll()
        
        checkForApps()
        checkForRootlessEnv()
        
        if detected.isEmpty {
            alertMessage = "Your device is NOT Jailbroken"
        } else {
            detectionInfo = detected.joined(separator: "\n")
            alertMessage = "Your device is Jailbroken!\n\nReasons:\n\(detectionInfo)"
        }
        
        isPresented = true
    }
}
