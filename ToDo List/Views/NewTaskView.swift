import SwiftUI

struct NewTaskView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var viewContext
    @State private var title: String = ""
    @State private var description: String = ""
    @State private var isTitleEntered = false
    @FocusState private var titleFocused: Bool
    @FocusState private var descriptionFocused: Bool
    
    let onSave: (TodoTask) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Navigation Bar
            HStack {
                Button(action: {
                    if !title.isEmpty {
                        saveTask()
                    }
                    dismiss()
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.yellow)
                        Text("Назад")
                            .foregroundColor(.yellow)
                    }
                }
                Spacer()
            }
            .padding(.horizontal)
            .padding(.top, 8)
            
            // Title Input
            if !isTitleEntered {
                TextField("", text: $title)
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)
                    .focused($titleFocused)
                    .onSubmit {
                        if !title.isEmpty {
                            isTitleEntered = true
                            descriptionFocused = true
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 24)
            } else {
                Text(title)
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal)
                    .padding(.top, 24)
                
                Text(formattedDate(Date()))
                    .font(.system(size: 13))
                    .foregroundColor(.gray)
                    .padding(.horizontal)
                    .padding(.top, 8)
                
                TextEditor(text: $description)
                    .font(.system(size: 17))
                    .foregroundColor(.white)
                    .background(Color.black)
                    .focused($descriptionFocused)
                    .padding(.top, 16)
            }
            
            Spacer()
        }
        .navigationBarHidden(true)
        .background(Color.black)
        .preferredColorScheme(.dark)
        .onAppear {
            titleFocused = true
        }
    }
    
    private func saveTask() {
        let newTask = TodoTask(context: viewContext)
        newTask.id = Int64(Date().timeIntervalSince1970)
        newTask.title = title
        newTask.todoDescription = description
        newTask.createdAt = Date()
        newTask.isCompleted = false
        newTask.userId = 1
        
        do {
            try viewContext.save()
            onSave(newTask)
        } catch {
            print("Ошибка сохранения задачи: \(error)")
        }
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yy"
        return formatter.string(from: date)
    }
} 