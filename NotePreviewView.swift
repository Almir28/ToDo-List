struct NotePreviewView: View {
    let task: TodoTask
    
    var body: some View {
        ZStack {
            Color(hex: "#272729")
                .edgesIgnoringSafeArea(.all)
            
            VStack(alignment: .leading, spacing: 16) {
                Text(task.wrappedTitle)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 16)
                
                if !task.wrappedDescription.isEmpty {
                    Text(task.wrappedDescription)
                        .font(.system(size: 15, weight: .regular))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .lineSpacing(6)
                }
                
                Text(formattedDate(task.wrappedCreatedAt))
                    .font(.system(size: 13))
                    .foregroundColor(.gray)
                    .padding(.bottom, 16)
            }
            .padding(.horizontal, 24)
        }
        .frame(maxWidth: 350)
        .cornerRadius(12)
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yy"
        return formatter.string(from: date)
    }
} 