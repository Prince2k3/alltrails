import SwiftUI
import Design

struct RestaurantRow: View {
    let photoURL: URL?
    let name: String
    let rating: Int
    let ratingCount: Int
    let priceLevel: String?
    let otherInfo: String?
    let selected: Bool
    
    var body: some View {
        HStack(alignment: .top) {
//            AsyncImage(url: photoURL) { image in
//                image
//                    .resizable()
//                    .scaledToFill()
//            } placeholder: {
//                Image(asset: .martisTrail)
//                    .resizable()
//                    .scaledToFill()
//            }
//            .frame(width: 64, height: 64)
//            .clipped()
            
            Image(asset: .martisTrail)
                .resizable()
                .scaledToFill()
                .frame(width: 64, height: 64)
                .clipped()
            
            VStack(alignment: .leading, spacing: 4) {
                Text(name)
                    .foregroundColor(.at_gray)
                    .font(.footnote)
                    .fontWeight(.bold)
                
                HStack(spacing: 4) {
                    StarRating(rating: rating)
                    
                    Text("(\(ratingCount))")
                        .font(.caption)
                        .foregroundColor(.at_gray2)
                }
                
                HStack(spacing: 2) {
                    if let priceLevel = priceLevel {
                        Text(priceLevel)
                            .foregroundColor(.at_gray2)
                            
                        Text("•")
                            .foregroundColor(.at_gray2)
                    }
                    
                    if let otherInfo = otherInfo {
                        Text(otherInfo)
                            .foregroundColor(.at_gray2)
                    }
                }
                .font(.caption)
            }
            
            Spacer()
            
            VStack {
                
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .frame(maxWidth: 375)
        .background(.white)
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(selected ? Color.at_green : Color.gray_05, lineWidth: selected ? 2 : 0.5)
        )
    }
}
