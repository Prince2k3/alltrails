import UIKit

extension UIImage {
    public static func imageAsset(_ named: ImageAsset, bundle: Bundle? = nil) -> UIImage {
        UIImage(named: named.rawValue, in: .module, compatibleWith: nil)!
    }
}
