import SwiftUI

extension Image {

    public init(asset named: ImageAsset, bundle: Bundle? = nil) {
        self.init(named.rawValue, bundle: .module)
    }
}
