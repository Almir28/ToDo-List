/// Утилита для работы с HEX-цветами в SwiftUI
import SwiftUI
/// Расширение добавляет возможность создания Color из HEX-строки.
/// Оптимизировано для производительности и безопасности.
///
/// - Note: Поддерживает форматы #RGB, #RRGGBB и #AARRGGBB
/// - Important: Строка может содержать или не содержать префикс #
extension Color {
    
    /// Инициализирует Color из HEX-строки
    ///
    /// - Parameter hex: Строка в HEX-формате
    /// - Returns: Color с соответствующими RGB/ARGB значениями
    init(hex: String) {
        // Нормализация входной строки
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        
        // Компоненты цвета
        let a, r, g, b: UInt64
        
        // Парсинг в зависимости от длины
        switch hex.count {
        case 3: // Короткий формат RGB
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // Полный формат RGB
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // Формат с alpha-каналом
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default: // Fallback для некорректного формата
            (a, r, g, b) = (255, 0, 0, 0)
        }

        // Инициализация через sRGB цветовое пространство
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
