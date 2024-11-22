import SwiftUI
import CoreData
import Speech
import AVFoundation
/// Главный экран приложения со списком задач и голосовым поиском
/// Реализует отображение списка, поиск, создание задач и распознавание речи
struct TodoListView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var presenter: TodoListPresenter
    @State private var searchText = ""
    @State private var showingNewTask = false
    @State private var isLoading = true
    @State private var isRecording = false
    @State private var speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en_US"))
    @State private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    @State private var recognitionTask: SFSpeechRecognitionTask?
    @State private var audioEngine = AVAudioEngine()
    
    init(context: NSManagedObjectContext) {
        _presenter = StateObject(wrappedValue: TodoListPresenter(context: context))
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                VStack(spacing: 0) {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                        
                        TextField("Search", text: $searchText)
                            .textFieldStyle(.plain)
                            .foregroundColor(.white)
                            .onChange(of: searchText) { newValue in
                                presenter.searchTasks(query: newValue)
                            }
                        
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
                        
                        if !searchText.isEmpty {
                            Button(action: {
                                searchText = ""
                                presenter.searchTasks(query: "")
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
                    
                    TaskListView(
                        presenter: presenter,
                        searchText: $searchText
                    )
                    
                    BottomBarView(
                        presenter: presenter,
                        showingNewTask: $showingNewTask,
                        viewContext: viewContext
                    )
                }
                
                if isLoading && presenter.tasks.isEmpty {
                    LoadingView()
                }
            }
            .navigationTitle("Tasks")
            .preferredColorScheme(.dark)
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                isLoading = false
            }
        }
    }
    
    private func setupSpeechRecognition() {
        SFSpeechRecognizer.requestAuthorization { status in
            DispatchQueue.main.async {
                switch status {
                case .authorized:
                    print("Permission granted")
                case .denied:
                    print("User denied access")
                case .restricted:
                    print("Speech recognition restricted")
                case .notDetermined:
                    print("Permission not requested")
                @unknown default:
                    print("Unknown status")
                }
            }
        }
    }
    
    private func startRecording() {
        guard let recognizer = speechRecognizer, recognizer.isAvailable else {
            print("Speech recognition not available")
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
                        self.searchText = result.bestTranscription.formattedString
                        presenter.searchTasks(query: self.searchText)
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
            print("Recording error: \(error)")
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

private struct TaskListView: View {
    @ObservedObject var presenter: TodoListPresenter
    @Binding var searchText: String
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                ForEach(presenter.tasks) { task in
                    TodoTaskRow(
                        task: task,
                        onUpdate: { updatedTask in
                            presenter.updateTask(updatedTask)
                        },
                        onDelete: {
                            withAnimation {
                                presenter.viewDidLoad()
                            }
                        }
                    )
                    .padding(.horizontal, 16)
                    
                    if task != presenter.tasks.last {
                        Rectangle()
                            .frame(height: 1)
                            .foregroundColor(Color(hex: "#272729"))
                            .padding(.horizontal, 32)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(Color.black)
    }
}
private struct BottomBarView: View {
    @ObservedObject var presenter: TodoListPresenter
    @Binding var showingNewTask: Bool
    let viewContext: NSManagedObjectContext
    
    var body: some View {
        HStack {
            Spacer()
            Text("\(presenter.tasks.count) Tasks")
                .foregroundColor(.gray)
                .font(.system(size: 13))
            Spacer()
            
            NavigationLink(
                isActive: $showingNewTask,
                destination: {
                    NewTaskView()
                        .environment(\.managedObjectContext, viewContext)
                        .navigationBarBackButtonHidden(true)
                        .onDisappear {
                            presenter.viewDidLoad()
                        }
                },
                label: {
                    AddTaskButton(showingNewTask: $showingNewTask)
                }
            )
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
        .frame(height: 50)
        .background(Color(hex: "#272729").edgesIgnoringSafeArea(.bottom))
        .overlay(
            Rectangle()
                .frame(height: 1.5)
                .foregroundColor(Color(hex: "#272729"))
                .padding(.horizontal, 20), 
            alignment: .top
        )
    }
}

private struct AddTaskButton: View {
    @Binding var showingNewTask: Bool
    
    var body: some View {
        Image(systemName: "square.and.pencil")
            .resizable()
            .frame(width: 24, height: 24)
            .foregroundColor(.yellow)
            .onTapGesture {
                showingNewTask = true
            }
    }
}

private struct LoadingView: View {
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            ProgressView("Loading tasks...")
                .scaleEffect(1.5)
                .progressViewStyle(CircularProgressViewStyle(tint: .yellow))
                .foregroundColor(.white)
        }
    }
}
