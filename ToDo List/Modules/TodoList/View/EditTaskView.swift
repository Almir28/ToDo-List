import Foundation
import SwiftUI
import CoreData

struct EditTaskView: View {
    @Environment(\.managedObjectContext) private var viewContext // Контекст для работы с Core Data
    @Environment(\.presentationMode) var presentationMode // Управление состоянием представления
    
    let task: TodoTask // Задача, которую нужно редактировать
    let onUpdate: (TodoTask) -> Void // Замыкание для обновления задачи
    
    @State private var title: String // Заголовок задачи
    @State private var description: String // Описание задачи
    
    init(task: TodoTask, onUpdate: @escaping (TodoTask) -> Void) {
        self.task = task
        self.onUpdate = onUpdate
        _title = State(initialValue: task.wrappedTitle) // Инициализация заголовка
        _description = State(initialValue: task.wrappedDescription) // Инициализация описания
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            TextField("Заголовок", text: $title) // Поле для ввода заголовка
                .font(.system(size: 20, weight: .regular))
                .foregroundColor(.white)
                .padding(.horizontal, 16)
                .padding(.top, 16)
            
            Text(formattedDate(task.wrappedCreatedAt)) // Отображение даты создания задачи
                .font(.system(size: 11, weight: .light))
                .foregroundColor(.gray)
                .padding(.horizontal, 16)
                .padding(.top, 2)
            
            TextEditor(text: $description) // Поле для ввода описания задачи
                .font(.system(size: 15, weight: .light))
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
                    saveChanges() // Сохранение изменений перед закрытием
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
        .preferredColorScheme(.dark) // Предпочтительная цветовая схема
    }
    
    /// Функция для сохранения изменений в задаче
    private func saveChanges() {
        task.title = title // Обновление заголовка задачи
        task.todoDescription = description // Обновление описания задачи
        onUpdate(task) // Вызов замыкания для обновления задачи
        
        try? viewContext.save() // Сохранение изменений в контексте
    }
    
    /// Форматирование даты в строку
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yy" // Формат даты
        return formatter.string(from: date) // Возврат отформатированной даты
    }
}
