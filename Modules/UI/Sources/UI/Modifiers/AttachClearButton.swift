import SwiftUI
import Design

public struct AttachClearButton: ViewModifier {
    public enum DisplayMode {
        case always
        case textEntered
    }
    
    @Binding fileprivate var text: String

    let buttonColor: Color
    let onClear: () -> Void
    let displayMode: DisplayMode
    
    init(text: Binding<String>, buttonColor: Color = .at_green, displayMode: DisplayMode = .textEntered, onClear: @escaping () -> Void) {
        self._text = text
        self.onClear = onClear
        self.displayMode = displayMode
        self.buttonColor = buttonColor
    }

    public func body(content: Content) -> some View {
        HStack {
            content
            
            Spacer()
            
            Image(systemName: "multiply.circle.fill")
                .foregroundColor(buttonColor)
                .opacity(displayMode == .always ? 1 : text == "" ? 0 : 1)
                .onTapGesture {
                    self.text = ""
                    onClear()
                }
        }
    }
}


extension TextField {
    public func attachClearButton(text: Binding<String>, buttonColor: Color = .secondary, displayMode: AttachClearButton.DisplayMode = .textEntered, onClear: @escaping () -> Void = {}) -> some View {
        modifier(AttachClearButton(text: text, buttonColor: buttonColor, displayMode: displayMode, onClear: onClear))
    }
}
