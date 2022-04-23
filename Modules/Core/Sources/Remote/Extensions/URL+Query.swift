import Foundation

extension URL {
    public var components: URLComponents? { URLComponents(url: self, resolvingAgainstBaseURL: false) }
}

extension Array where Element == URLQueryItem {
    public subscript(_ name: String) -> String? {
        get {
            first { $0.name == name }?.value
        }
        
        set {
            guard let idx = firstIndex(where: { $0.name == name }) else { return }
            self[idx].value = newValue
        }
    }
}

extension URLComponents {
    public mutating func setQueryItems(with parameters: [String: String]) {
        self.queryItems = parameters.map(URLQueryItem.init(name:value:))
    }
}
