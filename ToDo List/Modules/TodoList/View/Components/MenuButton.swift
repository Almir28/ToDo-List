import SwiftUI

struct MenuButton: View {
    let title: String // Заголовок кнопки
    let icon: String // Иконка кнопки
    var isDestructive: Bool = false // Флаг, указывающий, является ли кнопка разрушительной (например, для удаления)

    var body: some View {
        HStack {
            Text(title) // Отображение заголовка кнопки
                .foregroundColor(isDestructive ? .red : .white) // Установка цвета текста в зависимости от флага isDestructive
            Spacer() // Пробел между текстом и иконкой
            Image(systemName: icon) // Отображение иконки
                .foregroundColor(isDestructive ? .red : .gray) // Установка цвета иконки в зависимости от флага isDestructive
        }
        .padding(.horizontal, 16) // Установка горизонтальных отступов
        .frame(height: 44) // Установка высоты кнопки
    }
}
