import SwiftUI
import UI
import Design
import Core
import Combine

public struct Restaurants: View {
    enum ViewOption: String {
        case list
        case map
        
        var toggleTitle: String {
            switch self {
            case .list: return Self.map.rawValue.capitalized
            case .map: return Self.list.rawValue.capitalized
            }
        }
        
        var toggleImage: Image {
            switch self {
            case .list: return Image(asset: .pin)
            case .map: return Image(asset: .list)
            }
        }
        
        func toggle() -> ViewOption {
            self == .list ? .map : .list
        }
    }
    
    @State private var option: ViewOption = .list
    
    @StateObject var viewModel: ViewModel
    @StateObject var orientation = DeviceOrientation()
    
    public init(viewModel builder: @autoclosure @escaping () -> ViewModel) {
        self._viewModel = StateObject(wrappedValue: builder())
    }
    
    public var body: some View {
        ZStack {
            VStack {
                Header(
                    searchText: $viewModel.searchText,
                    sortBy: $viewModel.sortBy,
                    isLandscape: orientation.isLandscape
                )
                
                Spacer()
            }
            .zIndex(999)
            
            if orientation.isLandscape {
                HStack(spacing: 0) {
                    RestaurantList(
                        restaurants: $viewModel.restaurants,
                        selectedRestaurant: $viewModel.selectedRestaurant,
                        isLandscape: orientation.isLandscape
                    )
                    .frame(maxWidth: UIScreen.main.bounds.width * (is_iPad() ? 0.3 : 0.5))
                    .padding(.top, 44)
                    
                    RestaurantsMap(
                        restaurants: $viewModel.restaurants,
                        selectedRestaurant: $viewModel.selectedRestaurant,
                        region: $viewModel.region,
                        isLandscape: orientation.isLandscape
                    )
                }
                
            } else {
                
                VStack {
                    RestaurantList(
                        restaurants: $viewModel.restaurants,
                        selectedRestaurant: $viewModel.selectedRestaurant,
                        isLandscape: orientation.isLandscape
                    )
                }
                .background(.white)
                .padding(.top, 84)
                .zIndex(option == .list ? 1 : 0)
                
                RestaurantsMap(
                    restaurants: $viewModel.restaurants,
                    selectedRestaurant: $viewModel.selectedRestaurant,
                    region: $viewModel.region,
                    isLandscape: orientation.isLandscape
                )
                .zIndex(option == .map ? 1 : 0)
                
                FloatingButton(option: $option)
                    .zIndex(999)
            }
        }
        .animation(.spring(), value: !viewModel.searchResults.isEmpty)
        .onAppear(perform: viewModel.getNearbyRestaurants)
    }
}

struct Restaurants_Previews: PreviewProvider {
    
    final class GetNearbyRestaurantsUseCaseStub: GetNearbyRestaurantsUseCase {
        func nearbyRestaurants() -> AnyPublisher<[Restaurant], Error> {
            .result([])
        }
    }
    
    final class SearchForRestaurantsUseCaseStub: SearchForRestaurantsUseCase {
        func searchRestaurants(_ searchText: String) -> AnyPublisher<[Restaurant], Error> {
            .result([])
        }
    }
    
    static var previews: some View {
        let viewModel = Restaurants.ViewModel(
            getNearbyRestaurantsUseCase: GetNearbyRestaurantsUseCaseStub(),
            searchForRestaurantsUseCase: SearchForRestaurantsUseCaseStub(),
            inputSearchFilterHandler: InputSearchFilterHandler()
        )
        
        return Restaurants(viewModel: viewModel)
    }
}

struct FloatingButton: View {
    @Binding var option: Restaurants.ViewOption
    
    var body: some View {
        VStack {
            Spacer()
            
            Button(action: {
                option = option.toggle()
            }) {
                HStack(spacing: 2) {
                    option.toggleImage
                    
                    Text(option.toggleTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.at_white)
                }
                .frame(width: 100, height: 44)
                .background(Color.at_green)
                .cornerRadius(6)
                .shadow(color: .gray_05, radius: 4, x: 0, y: 0)
            }
            
        }
        .padding(.bottom)
    }
}
