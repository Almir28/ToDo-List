import SwiftUI

/// Обертка для UIBlurEffect в SwiftUI
/// Добавляет эффект размытия как в нативных iOS компонентах
struct BlurView: UIViewRepresentable {
    let style: UIBlurEffect.Style // Стиль размытия, передаваемый при инициализации

    /// Создание UIView для эффекта размытия
    func makeUIView(context: Context) -> UIVisualEffectView {
        return UIVisualEffectView(effect: UIBlurEffect(style: style)) // Создание и возврат UIVisualEffectView с заданным эффектом
    }

    /// Обновление UIView при изменении состояния
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        uiView.effect = UIBlurEffect(style: style) // Обновление эффекта размытия при изменении стиля
    }
}
