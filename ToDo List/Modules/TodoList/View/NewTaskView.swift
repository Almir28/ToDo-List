import SwiftUI

/// Экран создания новой задачи с поддержкой CoreData
struct NewTaskView: View {
    @Environment(\.managedObjectContext) private var viewContext // Контекст для работы с Core Data
    @Environment(\.presentationMode) var presentationMode // Управление состоянием представления
    
    @State private var title: String = "" // Заголовок новой задачи
    @State private var description: String = "" // Описание новой задачи
    @FocusState private var isTitleFocused: Bool // Фокус на поле заголовка
    @State private var showingDate: Bool = false // Статус отображения даты
    @State private var currentTask: TodoTask? // Текущая задача (если редактируется)
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            TextField("", text: $title) // Поле для ввода заголовка
                .font(.system(size: 24, weight: .semibold))
                .foregroundColor(.white)
                .focused($isTitleFocused) // Установка фокуса на поле
                .submitLabel(.return) // Метка для клавиши "Enter"
                .onSubmit {
                    showingDate = true // Показать дату при нажатии "Enter"
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
            
            if showingDate {
                Text(formattedDate(Date())) // Отображение текущей даты
                    .font(.system(size: 13))
                    .foregroundColor(.gray)
                    .padding(.horizontal, 16)
                    .padding(.top, 2)
            }
            
            TextEditor(text: $description) // Поле для ввода описания задачи
                .font(.system(size: 17, weight: .regular))
                .foregroundColor(.white)
                .scrollContentBackground(.hidden)
                .background(Color.clear)
                .padding(.horizontal, 12)
                .padding(.top, 2)
            
            Spacer() // Пробел для растяжения содержимого
        }
        .background(Color.black) // Фоновый цвет
        .navigationBarTitleDisplayMode(.inline) // Режим отображения заголовка навигации
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    saveTask() // Сохранение задачи перед закрытием
                    presentationMode.wrappedValue.dismiss() // Закрытие представления
                }) {
                    HStack(spacing: 5) {
                        Image(systemName: "chevron.left") // Иконка для кнопки "Назад"
                            .foregroundColor(.yellow)
                        Text("Назад") // Текст кнопки "Назад"
                            .foregroundColor(.yellow)
                    }
                }
            }
        }
        .onAppear {
            isTitleFocused = true // Установка фокуса на поле заголовка при появлении
        }
        .preferredColorScheme(.dark) // Предпочтительная цветовая схема
    }
    
    /// Функция для сохранения новой задачи
    private func saveTask() {
        guard !title.isEmpty || !description.isEmpty else { return } // Проверка на пустые поля
        
        if currentTask == nil {
            let newTask = TodoTask(context: viewContext) // Создание новой задачи
            newTask.id = Int64(Date().timeIntervalSince1970) // Установка уникального идентификатора
            newTask.title = title // Установка заголовка
            newTask.todoDescription = description // Установка описания
            newTask.createdAt = Date() // Установка даты создания
            newTask.isCompleted = false // Установка статуса завершенности
            currentTask = newTask // Сохранение текущей задачи
        } else {
            currentTask?.title = title // Обновление заголовка существующей задачи
            currentTask?.todoDescription = description // Обновление описания существующей задачи
        }
        
        do {
            try viewContext.save() // Сохранение изменений в контексте
        } catch {
            print("Error saving task: \(error)") // Обработка ошибок сохранения
        }
    }
    
    /// Форматирование даты в строку
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yy" // Формат даты
        return formatter.string(from: date) // Возврат отформатированной даты
    }
}
