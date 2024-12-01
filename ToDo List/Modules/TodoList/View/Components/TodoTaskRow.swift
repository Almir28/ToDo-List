import SwiftUI
import UIKit

/// Кастомная ячейка для отображения задачи в списке с поддержкой всех действий
/// Реализует отображение задачи, редактирование, удаление и шаринг через контекстное меню
struct TodoTaskRow: View {
    @Environment(\.managedObjectContext) private var viewContext // Контекст для работы с Core Data
    let task: TodoTask // Задача, которую нужно отобразить
    let onUpdate: (TodoTask) -> Void // Замыкание для обновления задачи
    let onDelete: () -> Void // Замыкание для удаления задачи
    @State private var isCompleted: Bool // Статус завершенности задачи
    @State private var isEditingNote = false // Статус редактирования заметки
    @State private var editedTitle: String // Отредактированный заголовок
    @State private var editedDescription: String // Отредактированное описание
    @State private var showingEditSheet = false // Статус отображения экрана редактирования
    
    init(task: TodoTask, onUpdate: @escaping (TodoTask) -> Void, onDelete: @escaping () -> Void) {
        self.task = task
        self.onUpdate = onUpdate
        self.onDelete = onDelete
        _isCompleted = State(initialValue: task.isCompleted) // Инициализация статуса завершенности
        _editedTitle = State(initialValue: task.wrappedTitle) // Инициализация отредактированного заголовка
        _editedDescription = State(initialValue: task.wrappedDescription) // Инициализация отредактированного описания
    }
    
    var body: some View {
        VStack(spacing: 0) {
            taskContentView // Отображение содержимого задачи
                .padding(.vertical, 8)
                .background(Color.black) // Фоновый цвет ячейки
                .contextMenu { // Контекстное меню для действий с задачей
                    VStack {
                        Button(action: {
                            showingEditSheet = true // Показать экран редактирования
                        }) {
                            Label {
                                Text("Редактировать")
                                    .foregroundColor(.black)
                            } icon: {
                                Image(systemName: "square.and.pencil")
                                    .foregroundColor(.black)
                            }
                        }
                        .background(.white)
                        
                        Button(action: {
                            shareNote() // Поделиться заметкой
                        }) {
                            Label {
                                Text("Поделиться")
                                    .foregroundColor(.black)
                            } icon: {
                                Image(systemName: "square.and.arrow.up")
                                    .foregroundColor(.black)
                            }
                        }
                        .background(.white)
                        
                        Button(role: .destructive, action: {
                            deleteNote() // Удалить заметку
                        }) {
                            Label {
                                Text("Удалить")
                                    .foregroundColor(.red)
                            } icon: {
                                Image(systemName: "trash")
                                    .foregroundColor(.red)
                            }
                        }
                        .background(.white)
                    }
                    .background(.white)
                } preview: { // Предварительный просмотр контекстного меню
                    ZStack {
                        Color(hex: "#272729")
                            .edgesIgnoringSafeArea(.all)
                        
                        ScrollView(.vertical, showsIndicators: false) {
                            VStack(alignment: .leading, spacing: 16) {
                                Text(task.wrappedTitle) // Заголовок задачи
                                    .font(.system(size: 20, weight: .medium))
                                    .foregroundColor(.white)
                                    .multilineTextAlignment(.leading)
                                    .fixedSize(horizontal: false, vertical: true)
                                
                                if !task.wrappedDescription.isEmpty {
                                    Text(task.wrappedDescription) // Описание задачи
                                        .font(.system(size: 14, weight: .light))
                                        .foregroundColor(.white.opacity(0.9))
                                        .multilineTextAlignment(.leading)
                                        .fixedSize(horizontal: false, vertical: true)
                                        .lineSpacing(4)
                                }
                                
                                Text(formattedDate(task.wrappedCreatedAt)) // Дата создания задачи
                                    .font(.system(size: 12, weight: .light))
                                    .foregroundColor(.gray)
                            }
                            .padding(20)
                        }
                    }
                    .frame(idealWidth: UIScreen.main.bounds.width - 60)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }
        }
        .sheet(isPresented: $showingEditSheet) { // Модальное окно для редактирования задачи
            NavigationView {
                EditTaskView(task: task, onUpdate: onUpdate) // Экран редактирования задачи
            }
        }
    }
    
    /// Представление для чекбокса завершенности задачи
    private var checkboxView: some View {
        ZStack {
            Circle()
                .stroke(isCompleted ? Color.yellow : Color.gray.opacity(0.6), lineWidth: 1) // Обводка чекбокса
                .frame(width: 20, height: 20)
            
            if isCompleted {
                Image(systemName: "checkmark") // Иконка завершенности
                    .font(.system(size: 11, weight: .light))
                    .foregroundColor(.yellow)
            }
        }
        .contentShape(Circle())
        .onTapGesture {
            withAnimation(.spring(response: 0.2, dampingFraction: 0.6)) {
                isCompleted.toggle() // Переключение статуса завершенности
                task.isCompleted = isCompleted
                onUpdate(task) // Обновление задачи
            }
        }
    }
    
    /// Представление содержимого задачи
    private var taskContentView: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(alignment: .center, spacing: 12) {
                checkboxView // Чекбокс завершенности
                
                Text(task.wrappedTitle) // Заголовок задачи
                    .font(.system(size: 17, weight: .medium))
                    .foregroundColor(isCompleted ? .gray : .white)
                    .strikethrough(isCompleted, color: .gray) // Зачеркивание завершенной задачи
                    .lineLimit(1)
            }
            
            if !task.wrappedDescription.isEmpty {
                Text(task.wrappedDescription) // Описание задачи
                    .font(.system(size: 13, weight: .light))
                    .foregroundColor(isCompleted ? .gray : .white)
                    .lineLimit(2)
                    .padding(.leading, 32)
            }
            
            Text(formattedDate(task.wrappedCreatedAt)) // Дата создания задачи
                .font(.system(size: 11, weight: .light))
                .foregroundColor(.gray.opacity(0.6))
                .padding(.leading, 32)
        }
        .padding(.vertical, 12)
        .background(Color.black) // Фоновый цвет ячейки
        .opacity(isCompleted ? 0.6 : 1) // Прозрачность для завершенной задачи
    }
    
    /// Функция для шаринга заметки
    private func shareNote() {
        let text = "\(task.wrappedTitle)\n\(task.wrappedDescription)" // Текст для шаринга
        let av = UIActivityViewController(activityItems: [text], applicationActivities: nil) // Контроллер для шаринга
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first,
           let viewController = window.rootViewController {
            viewController.present(av, animated: true) // Показать контроллер шаринга
        }
    }
    
    /// Функция для удаления заметки
    private func deleteNote() {
        viewContext.delete(task) // Удаление задачи из контекста
        do {
            try viewContext.save() // Сохранение изменений
            onDelete() // Вызов замыкания для удаления
        } catch {
            print("Error deleting note: \(error)") // Обработка ошибки удаления
        }
    }
    
    /// Форматирование даты в строку
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yy" // Формат даты
        return formatter.string(from: date) // Возврат отформатированной даты
    }
}

extension View {
    /// Стиль для кнопок меню
    func menuButtonStyle() -> some View {
        self
            .foregroundColor(.black)
            .background(.white)
    }
}
