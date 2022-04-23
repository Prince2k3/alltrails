import Foundation
import Restaurants
import CoreLocation
import Remote
import Core

extension Restaurants.ViewModel {
    static var `default`: Restaurants.ViewModel {
        let httpClient =  URLSessionHTTPClient(session: .shared).validate().logging(to: Print())
        let locationManager = CLLocationManager()
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        let remoteSearchNearbyRestaurantsUseCase = RemoteSearchNearbyRestaurantsUseCase(httpClient: httpClient)
        let trackUserAndGetNearbyRestaurantsUseCase = UpdateLocationAndGetNearbyRestaurantsUseCase(
            userLocationObserverUseCase: locationManager,
            remoteSearchNearbyRestaurantsUseCase: remoteSearchNearbyRestaurantsUseCase
        )
        
        let trackUserAndSearchNearbyRestaurantsUseCase = UpdateLocationAndSearchNearbyRestaurantsUseCase(
            userLocationObserverUseCase: locationManager,
            remoteSearchNearbyRestaurantsUseCase: remoteSearchNearbyRestaurantsUseCase
        )
        
        return Restaurants.ViewModel(
            getNearbyRestaurantsUseCase: trackUserAndGetNearbyRestaurantsUseCase,
            searchForRestaurantsUseCase: trackUserAndSearchNearbyRestaurantsUseCase,
            inputSearchFilterHandler: InputSearchFilterHandler()
        )
    }
}

