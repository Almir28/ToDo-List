import SwiftUI

struct SearchBar: View {
    @Binding var text: String
    let onSearchButtonClicked: () -> Void
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            
            TextField("Search", text: $text)
                .textFieldStyle(.plain)
                .foregroundColor(.white)
                .onSubmit(onSearchButtonClicked)
            
            Button(action: {
                // Действие для микрофона
            }) {
                Image(systemName: "mic.fill")
                    .foregroundColor(.gray)
            }
            
            if !text.isEmpty {
                Button(action: {
                    text = ""
                    onSearchButtonClicked()
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(Color(hex: "#272729"))
        .cornerRadius(10)
        .padding(.horizontal)
    }
} 
