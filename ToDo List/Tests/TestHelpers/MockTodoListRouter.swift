//
//  MockTodoListRouter.swift
//  TodoListTests
//
//  Created by Swift Developer on 21.11.2024.
//

import UIKit
import SwiftUI
@testable import ToDo_List
import CoreData

class MockTodoListRouter: TodoListRouterProtocol {
    var makeNewTaskViewCalled = false
    var makeEditTaskViewCalled = false
    var makeTaskDetailViewCalled = false
    
    func makeNewTaskView() -> UIViewController {
        makeNewTaskViewCalled = true
        return UIViewController()
    }
    
    func makeEditTaskView(task: TodoTask) -> UIViewController {
        makeEditTaskViewCalled = true
        return UIViewController()
    }
    
    func makeTaskDetailView(task: TodoTask) -> UIViewController {
        makeTaskDetailViewCalled = true
        return UIViewController()
    }
}
