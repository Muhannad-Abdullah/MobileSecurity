import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            SavePasswordView()
                .tabItem {
                    Image(systemName: "key.fill")
                    Text("Home")
                }
            
            PasswordListView()
                .tabItem {
                    Image(systemName: "list.bullet")
                    Text("Passwords")
                }
            JailBreakDetectionView()
                .tabItem {
                    Image(systemName: "hand.raised.slash")
                    Text("JailBreak Detection")
                }
        }
    }
}
