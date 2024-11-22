import SwiftUI

struct MenuButton: View {
    let title: String
    let icon: String
    var isDestructive: Bool = false
    
    var body: some View {
        HStack {
            Text(title)
                .foregroundColor(isDestructive ? .red : .white)
            Spacer()
            Image(systemName: icon)
                .foregroundColor(isDestructive ? .red : .gray)
        }
        .padding(.horizontal, 16)
        .frame(height: 44)
    }
} 