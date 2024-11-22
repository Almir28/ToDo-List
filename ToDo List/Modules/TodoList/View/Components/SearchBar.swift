import SwiftUI
import Speech
import AVFoundation

struct SearchBar: View {
    @Binding var text: String
    let onSearchButtonClicked: () -> Void
    @State private var isRecording = false
    @State private var speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "ru_RU"))
    @State private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    @State private var recognitionTask: SFSpeechRecognitionTask?
    @State private var audioEngine = AVAudioEngine()
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            
            TextField("Поиск", text: $text)
                .textFieldStyle(.plain)
                .foregroundColor(.white)
                .onSubmit(onSearchButtonClicked)
            
            Button(action: {
                if isRecording {
                    stopRecording()
                } else {
                    startRecording()
                }
            }) {
                Image(systemName: isRecording ? "stop.circle.fill" : "mic.fill")
                    .foregroundColor(isRecording ? .red : .gray)
                    .font(.system(size: 20))
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
        .onAppear {
            setupSpeechRecognition()
        }
    }
    
    private func setupSpeechRecognition() {
        SFSpeechRecognizer.requestAuthorization { status in
            DispatchQueue.main.async {
                switch status {
                case .authorized:
                    print("Разрешение получено")
                case .denied:
                    print("Пользователь отказал в доступе")
                case .restricted:
                    print("Распознавание речи недоступно")
                case .notDetermined:
                    print("Разрешение не запрошено")
                @unknown default:
                    print("Неизвестный статус")
                }
            }
        }
    }
    
    private func startRecording() {
        guard let recognizer = speechRecognizer, recognizer.isAvailable else {
            print("Распознавание речи недоступно")
            return
        }
        
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
            
            recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
            recognitionRequest?.shouldReportPartialResults = true
            
            recognitionTask = recognizer.recognitionTask(with: recognitionRequest!) { result, error in
                if let result = result {
                    DispatchQueue.main.async {
                        self.text = result.bestTranscription.formattedString
                        if !self.text.isEmpty {
                            self.onSearchButtonClicked()
                        }
                    }
                }
                
                if error != nil || result?.isFinal == true {
                    stopRecording()
                }
            }
            
            let inputNode = audioEngine.inputNode
            let recordingFormat = inputNode.outputFormat(forBus: 0)
            
            inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
                self.recognitionRequest?.append(buffer)
            }
            
            audioEngine.prepare()
            try audioEngine.start()
            isRecording = true
            
        } catch {
            print("Ошибка записи: \(error)")
            stopRecording()
        }
    }
    
    private func stopRecording() {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        recognitionRequest?.endAudio()
        recognitionTask?.cancel()
        isRecording = false
    }
}
