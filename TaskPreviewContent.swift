struct TaskPreviewContent: View {
    let task: TodoTask
    
    var body: some View {
        ZStack {
            Color(hex: "#272729")
                .edgesIgnoringSafeArea(.all)
            
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    Text(task.wrappedTitle)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top, 12)
                    
                    if !task.wrappedDescription.isEmpty {
                        Text(task.wrappedDescription)
                            .font(.system(size: 15))
                            .foregroundColor(.white.opacity(0.9))
                            .multilineTextAlignment(.leading)
                            .fixedSize(horizontal: false, vertical: true)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .lineSpacing(4)
                    }
                    
                    Text(formattedDate(task.wrappedCreatedAt))
                        .font(.system(size: 13))
                        .foregroundColor(.gray)
                        .padding(.bottom, 12)
                }
                .padding(.horizontal, 16)
            }
        }
        .frame(width: UIScreen.main.bounds.width - 80, height: min(UIScreen.main.bounds.height * 0.7, 600))
        .cornerRadius(12)
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yy"
        return formatter.string(from: date)
    }
} 