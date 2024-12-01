import Foundation
@testable import ToDo_List
import UIKit

/// Мок-реализация вью для тестирования презентера
/// Отслеживает вызовы методов обновления UI и состояния загрузки
class MockTodoListView: TodoListViewProtocol {
    var presenter: TodoListPresenterProtocol? // Презентер, связанный с вью
    var showLoadingCalled = false // Флаг, указывающий, был ли вызван метод показа загрузки
    var hideLoadingCalled = false // Флаг, указывающий, был ли вызван метод скрытия загрузки
    var showTasksCalled = false // Флаг, указывающий, был ли вызван метод показа задач
    var showErrorCalled = false // Флаг, указывающий, был ли вызван метод показа ошибки
    var updateUICalled = false // Флаг, указывающий, был ли вызван метод обновления UI
    
    /// Метод для показа индикатора загрузки
    func showLoading() {
        showLoadingCalled = true // Установка флага вызова
    }
    
    /// Метод для скрытия индикатора загрузки
    func hideLoading() {
        hideLoadingCalled = true // Установка флага вызова
    }
    
    /// Метод для показа списка задач
    func showTasks(_ tasks: [TodoTask]) {
        showTasksCalled = true // Установка флага вызова
    }
    
    /// Метод для показа ошибки
    func showError(_ error: Error) {
        showErrorCalled = true // Установка флага вызова
    }
    
    /// Метод для обновления пользовательского интерфейса
    func updateUI() {
        updateUICalled = true // Установка флага вызова
    }
}
