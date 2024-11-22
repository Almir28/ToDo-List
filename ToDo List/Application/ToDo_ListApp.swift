//
//  ToDo_ListApp.swift
//  ToDo List
//
//  Created by Swift Developer on 20.11.2024.
//

import SwiftUI
import CoreData

@main
struct ToDo_ListApp: App {
    let persistenceController = CoreDataStack.shared
    
    var body: some Scene {
        WindowGroup {
            TodoListView(context: persistenceController.context)
                .environment(\.managedObjectContext, persistenceController.context)
        }
    }
}
