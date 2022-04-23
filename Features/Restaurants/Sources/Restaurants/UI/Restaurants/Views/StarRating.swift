import SwiftUI 

struct StarRating: View {
    var rating: Int = 0
    
    var body: some View {
        HStack(spacing: 2) {
            ForEach(0..<5) { index in
                Image(systemName: "star.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 15)
                    .foregroundColor(index < rating ? .at_yellow : .gray_05)
            }
        }
    }
}
