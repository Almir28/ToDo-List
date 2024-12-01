import SwiftUI
import UIKit

/// Кастомное меню для действий с задачами
/// Стандартное iOS меню с размытием и анимацией
struct ActionMenu: View {
    let onEdit: () -> Void // Замыкание для действия редактирования
    let onShare: () -> Void // Замыкание для действия поделиться
    let onDelete: () -> Void // Замыкание для действия удалить
    let onDismiss: () -> Void // Замыкание для закрытия меню
    
    var body: some View {
        ZStack {
            // Фоновое размытие для создания эффекта модального окна
            BlurView(style: .systemMaterial)
                .opacity(0.98) // Установка прозрачности
                .ignoresSafeArea() // Игнорирование безопасной зоны
                .onTapGesture {
                    withAnimation {
                        onDismiss() // Закрытие меню при нажатии на фон
                    }
                }
            
            VStack(spacing: 0) {
                // Кнопка редактирования
                Button(action: onEdit) {
                    HStack {
                        Text("Редактировать") // Текст кнопки
                            .font(.system(size: 17))
                            .foregroundColor(.primary) // Цвет текста
                        Spacer() // Пробел между текстом и иконкой
                        Image(systemName: "square.and.pencil") // Иконка редактирования
                            .font(.system(size: 16))
                            .foregroundColor(.gray) // Цвет иконки
                    }
                    .padding(.horizontal, 16) // Отступы по горизонтали
                    .frame(height: 44) // Высота кнопки
                }
                
                Divider() // Разделитель между кнопками
                    .background(Color.gray.opacity(0.2)) // Цвет разделителя
                
                // Кнопка поделиться
                Button(action: onShare) {
                    HStack {
                        Text("Поделиться") // Текст кнопки
                            .font(.system(size: 17))
                            .foregroundColor(.primary) // Цвет текста
                        Spacer() // Пробел между текстом и иконкой
                        Image(systemName: "square.and.arrow.up") // Иконка поделиться
                            .font(.system(size: 16))
                            .foregroundColor(.gray) // Цвет иконки
                    }
                    .padding(.horizontal, 16) // Отступы по горизонтали
                    .frame(height: 44) // Высота кнопки
                }
                
                Divider() // Разделитель между кнопками
                    .background(Color.gray.opacity(0.2)) // Цвет разделителя
                
                // Кнопка удаления
                Button(action: onDelete) {
                    HStack {
                        Text("Удалить") // Текст кнопки
                            .font(.system(size: 17))
                            .foregroundColor(.red) // Цвет текста
                        Spacer() // Пробел между текстом и иконкой
                        Image(systemName: "trash") // Иконка удаления
                            .font(.system(size: 16))
                            .foregroundColor(.red) // Цвет иконки
                    }
                    .padding(.horizontal, 16) // Отступы по горизонтали
                    .frame(height: 44) // Высота кнопки
                }
            }
            .background(Color(uiColor: .secondarySystemGroupedBackground)) // Фоновый цвет меню
            .cornerRadius(13) // Закругление углов
            .frame(width: 300) // Ширина меню
            .shadow(color: Color.black.opacity(0.2), radius: 20, x: 0, y: 10) // Тень для меню
        }
        .transition(.opacity.combined(with: .scale)) // Анимация появления меню
    }
}
