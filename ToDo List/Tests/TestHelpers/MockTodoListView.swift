//
//  MockTodoListView.swift
//  TodoListTests
//
//  Created by Swift Developer on 21.11.2024.

import Foundation
@testable import ToDo_List
import UIKit
/// Мок-реализация вью для тестирования презентера
/// Отслеживает вызовы методов обновления UI и состояния загрузки
class MockTodoListView: TodoListViewProtocol {
    var presenter: TodoListPresenterProtocol?
    var showLoadingCalled = false
    var hideLoadingCalled = false
    var showTasksCalled = false
    var showErrorCalled = false
    var updateUICalled = false
    
    func showLoading() {
        showLoadingCalled = true
    }
    
    func hideLoading() {
        hideLoadingCalled = true
    }
    
    func showTasks(_ tasks: [TodoTask]) {
        showTasksCalled = true
    }
    
    func showError(_ error: Error) {
        showErrorCalled = true
    }
    
    func updateUI() {
        updateUICalled = true
    }
}

