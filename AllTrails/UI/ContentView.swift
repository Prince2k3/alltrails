import SwiftUI
import CoreData
import Restaurants
import Combine
import Core

struct ContentView: View {
    var body: some View {
        Restaurants(viewModel: .default)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
