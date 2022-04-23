// https://developer.apple.com/forums/thread/126878

import SwiftUI

public final class DeviceOrientation: ObservableObject {
    public enum Orientation {
        case portrait
        case landscape
    }
    
    @Published public var orientation: Orientation
    
    public var isLandscape: Bool { orientation == .landscape }
    
    public init() {
        orientation = UIDevice.current.orientation.isLandscape ? .landscape : .portrait
        NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)
            .compactMap { ($0.object as? UIDevice)?.orientation }
            .map { deviceOrientation in
                if deviceOrientation.isLandscape {
                    return .landscape
                }
                
                return .portrait
            }
            .assign(to: &$orientation)
    }
}

extension View {
    public func is_iPad() -> Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }
}
