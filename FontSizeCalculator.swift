import SwiftUI

extension View {
    func calculateFontSize(for text: String, defaultSize: CGFloat, width: CGFloat) -> CGFloat {
        let textLength = text.count
        let maxLength = 500
        
        if textLength > maxLength {
            let ratio = CGFloat(maxLength) / CGFloat(textLength)
            let minFontSize: CGFloat = 12
            return max(defaultSize * ratio, minFontSize)
        }
        
        return defaultSize
    }
} 