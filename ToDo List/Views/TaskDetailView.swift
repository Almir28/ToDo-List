import SwiftUI

struct TaskDetailView: View {
    @Environment(\.dismiss) private var dismiss
    let task: TodoTask
    @State private var taskText: String
    @State private var isEditing = true
    
    init(task: TodoTask) {
        self.task = task
        _taskText = State(initialValue: task.wrappedDescription)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Navigation Bar
            HStack {
                Button(action: {
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
            
            // Title and Date
            VStack(alignment: .leading, spacing: 8) {
                Text(task.wrappedTitle)
                    .font(.system(size: 32, weight: .bold))
                Text(formattedDate(task.wrappedCreatedAt))
                    .font(.system(size: 13))
                    .foregroundColor(.gray)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal)
            .padding(.top, 24)
            
            // Text Editor
            TextEditor(text: $taskText)
                .font(.system(size: 17))
                .foregroundColor(.white)
                .background(Color.black)
                .padding(.top, 16)
            
            // Custom Keyboard Toolbar
            VStack(spacing: 0) {
                Divider()
                    .background(Color.gray.opacity(0.3))
                
                HStack(spacing: 20) {
                    Button(action: {}) {
                        Image(systemName: "face.smiling")
                            .foregroundColor(.gray)
                    }
                    Spacer()
                    Button(action: {}) {
                        Image(systemName: "mic")
                            .foregroundColor(.gray)
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 12)
                .background(Color(hex: "272729"))
            }
        }
        .navigationBarHidden(true)
        .background(Color.black)
        .preferredColorScheme(.dark)
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yy"
        return formatter.string(from: date)
    }
} 