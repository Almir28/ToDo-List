import UIKit
import SwiftUI
@testable import ToDo_List
import CoreData

/// Мок-реализация роутера для тестирования навигации
/// Отслеживает вызовы методов навигации и возвращает пустые контроллеры
class MockTodoListRouter: TodoListRouterProtocol {
    var makeNewTaskViewCalled = false // Флаг, указывающий, был ли вызван метод создания нового задания
    var makeEditTaskViewCalled = false // Флаг, указывающий, был ли вызван метод редактирования задания
    var makeTaskDetailViewCalled = false // Флаг, указывающий, был ли вызван метод отображения деталей задания
    
    /// Метод для создания представления нового задания
    func makeNewTaskView() -> UIViewController {
        makeNewTaskViewCalled = true // Установка флага вызова
        return UIViewController() // Возврат пустого контроллера
    }
    
    /// Метод для создания представления редактирования задания
    func makeEditTaskView(task: TodoTask) -> UIViewController {
        makeEditTaskViewCalled = true // Установка флага вызова
        return UIViewController() // Возврат пустого контроллера
    }
    
    /// Метод для создания представления деталей задания
    func makeTaskDetailView(task: TodoTask) -> UIViewController {
        makeTaskDetailViewCalled = true // Установка флага вызова
        return UIViewController() // Возврат пустого контроллера
    }
}
