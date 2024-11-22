import SwiftUI
/// Экран создания новой задачи с поддержкой CoreData
struct NewTaskView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode
    
    @State private var title: String = ""
    @State private var description: String = ""
    @FocusState private var isTitleFocused: Bool
    @State private var showingDate: Bool = false
    @State private var currentTask: TodoTask?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            TextField("", text: $title)
                .font(.system(size: 24, weight: .semibold))
                .foregroundColor(.white)
                .focused($isTitleFocused)
                .submitLabel(.return)
                .onSubmit {
                    showingDate = true
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
            
            if showingDate {
                Text(formattedDate(Date()))
                    .font(.system(size: 13))
                    .foregroundColor(.gray)
                    .padding(.horizontal, 16)
                    .padding(.top, 2)
            }
            
            TextEditor(text: $description)
                .font(.system(size: 17, weight: .regular))
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
                    saveTask()
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
        .onAppear {
            isTitleFocused = true
        }
        .preferredColorScheme(.dark)
    }
    
    private func saveTask() {
        guard !title.isEmpty || !description.isEmpty else { return }
        
        if currentTask == nil {
            let newTask = TodoTask(context: viewContext)
            newTask.id = Int64(Date().timeIntervalSince1970)
            newTask.title = title
            newTask.todoDescription = description
            newTask.createdAt = Date()
            newTask.isCompleted = false
            currentTask = newTask
        } else {
            currentTask?.title = title
            currentTask?.todoDescription = description
        }
        
        do {
            try viewContext.save()
        } catch {
            print("Error saving task: \(error)")
        }
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yy"
        return formatter.string(from: date)
    }
} 
