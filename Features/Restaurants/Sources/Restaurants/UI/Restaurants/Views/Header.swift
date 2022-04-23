import SwiftUI
import UI
import Design

struct Header: View {
    @Binding var searchText: String
    @Binding var sortBy: Restaurants.ViewModel.SortBy
    
    let isLandscape: Bool
    
    var body: some View {
        Group {
            if isLandscape {
                VStack(spacing: 0) {
                    HStack(spacing: 40) {
                        VStack(alignment: .leading, spacing: 0) {
                            Image(asset: .logo)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 237, height: 44)
                        }
                        
                        Spacer()
                        
                        bottom()
                    }
                    .padding(.horizontal, 24)
                    
                    Divider()
                }
            } else {
                VStack(spacing: 0) {
                    VStack(spacing: 16) {
                        Image(asset: .logo)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 237, height: 44)
                    }
                    
                    Spacer()
                        .frame(height: 8)
                    
                    bottom()
                        .padding(.horizontal, 24)
                    
                    Spacer()
                        .frame(height: 8)
                    
                    Divider()
                }
            }
        }
        .background(
            Color.at_white
                .shadow(color: .gray_03, radius: 4, x: 0, y: 0)
                .ignoresSafeArea(edges: [.top, .horizontal])
        )
    }
    
    
    private func bottom() -> some View {
        HStack(spacing: 16) {
            Menu {
                Button(action: { sortBy = sortBy == .highToLow ? .none : .highToLow }) {
                    if sortBy == .highToLow {
                        Label("Rating High to Low", systemImage: "checkmark.circle.fill")
                    } else {
                        Text("Rating High to Low")
                    }
                }
                
                Button(action: { sortBy = sortBy == .lowToHigh ? .none : .lowToHigh }) {
                    if sortBy == .lowToHigh {
                        Label("Rating Low to High", systemImage: "checkmark.circle.fill")
                    } else {
                        Text("Rating Low to High")
                    }
                }
            } label: {
                Text(sortBy != .none ? "Sort" : "Filter")
                    .font(.caption)
                    .foregroundColor(sortBy != .none ? .at_white : .at_gray)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)
                    .background(sortBy != .none ? Color.at_green : Color.at_white)
                    .cornerRadius(6)
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(Color.gray_02, lineWidth: 1)
                    )
            }
            
            HStack {
                TextField("Search for a restaurant", text: $searchText)
                    .attachClearButton(text: $searchText)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.at_gray)
                
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.at_green)
            }
            .frame(maxWidth: 275)
            .padding(.leading)
            .padding(.trailing, 8)
            .padding(.vertical, 6)
            .background(
                Color.at_white
                    .cornerRadius(6)
                    .shadow(color: .gray_03, radius: 2, x: 0, y: 2)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(Color.gray_02, lineWidth: 1)
            )
        }
    }
}
