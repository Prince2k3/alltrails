import SwiftUI
import Core

struct RestaurantList: View {
    @Binding var restaurants: [Restaurant]
    @Binding var selectedRestaurant: Restaurant?
    let isLandscape: Bool
    
    var body: some View {
        ScrollView {
            ScrollViewReader { proxy in
                LazyVStack(spacing: 16) {
                    ForEach(restaurants) { restaurant in
                        RestaurantRow(restaurant, selected: selectedRestaurant == restaurant)
                            .id(restaurant)
                            .onTapGesture {
                                selectedRestaurant = restaurant
                            }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)
                .padding(.bottom, 84)
                .onChange(of: selectedRestaurant) { newValue in
                    withAnimation {
                        if isLandscape {
                            proxy.scrollTo(newValue, anchor: .center)
                        } else {
                            proxy.scrollTo(newValue)
                        }
                        
                    }
                }
                
            }
            
        }
        .background(Color.gray_01)
    }
}
