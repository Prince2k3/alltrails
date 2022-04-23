import SwiftUI
import UI
import Design
import Core
import MapKit

struct RestaurantsMap: View {
    @Binding var restaurants: [Restaurant]
    @Binding var selectedRestaurant: Restaurant?
    @Binding var region: MKCoordinateRegion
    
    let isLandscape: Bool
    
    var body: some View {
        Map(coordinateRegion: $region, showsUserLocation: true, annotationItems: restaurants) { restuarant in
            MapAnnotation(coordinate: restuarant.location.coordinate2D) {
                
                if !isLandscape, selectedRestaurant == restuarant, let selectedRestaurant = selectedRestaurant {
                    VStack(spacing: 0) {
                        VStack {
                            RestaurantRow(selectedRestaurant, selected: false)
                                .frame(width: 275)
                            
                            Image(systemName: "arrowtriangle.down.fill")
                                .foregroundColor(.at_white)
                                .offset(y: -2)
                         
                        }
                        .animation(nil, value: selectedRestaurant)
                        .onAppear(perform: {
                            withAnimation {
                                region = MKCoordinateRegion(
                                    center: restuarant.location.coordinate2D,
                                    span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                                )
                            }
                        })
                        
                        Button(action: { self.selectedRestaurant = nil }) {
                            Image(asset: selectedRestaurant == restuarant ? .activePin : .inactivePin)
                        }
                    }
                    .offset(y: -55.9) // work the offset of the view on top of the annotation. This isn't acceptable to me
                } else {
                    Button(action: {
                        selectedRestaurant = restuarant
                        
                        guard isLandscape, selectedRestaurant == restuarant else { return }
                        withAnimation {
                            region = MKCoordinateRegion(
                                center: restuarant.location.coordinate2D,
                                span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                            )
                        }
                    }) {
                        Image(asset: selectedRestaurant == restuarant ? .activePin : .inactivePin)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .ignoresSafeArea()
    }
}
