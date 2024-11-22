//
//  EditTaskView.swift
//  ToDo List
//
//  Created by Swift Developer on 21.11.2024.
//

import Foundation
import SwiftUI
import CoreData

struct EditTaskView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode
    
    let task: TodoTask
    let onUpdate: (TodoTask) -> Void
    
    @State private var title: String
    @State private var description: String
    
    init(task: TodoTask, onUpdate: @escaping (TodoTask) -> Void) {
        self.task = task
        self.onUpdate = onUpdate
        _title = State(initialValue: task.wrappedTitle)
        _description = State(initialValue: task.wrappedDescription)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            TextField("Заголовок", text: $title)
                .font(.system(size: 20, weight: .regular))
                .foregroundColor(.white)
                .padding(.horizontal, 16)
                .padding(.top, 16)
            
            Text(formattedDate(task.wrappedCreatedAt))
                .font(.system(size: 11, weight: .light))
                .foregroundColor(.gray)
                .padding(.horizontal, 16)
                .padding(.top, 2)
            
            TextEditor(text: $description)
                .font(.system(size: 15, weight: .light)) 
                .foregroundColor(.white)
                .scrollContentBackground(.hidden)
                .background(Color.clear)
                .padding(.horizontal, 12)
                .padding(.top, 2)
            
            Spacer()
        }
        .background(Color.black)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    saveChanges()
                    presentationMode.wrappedValue.dismiss()
                }) {
                    HStack(spacing: 5) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.yellow)
                        Text("Назад")
                            .foregroundColor(.yellow)
                    }
                }
            }
        }
        .preferredColorScheme(.dark)
    }
    
    private func saveChanges() {
        task.title = title
        task.todoDescription = description
        onUpdate(task)
        
        try? viewContext.save()
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yy"
        return formatter.string(from: date)
    }
}
