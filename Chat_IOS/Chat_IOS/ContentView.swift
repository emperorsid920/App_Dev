//
//  ContentView.swift
//  Chat_IOS
//
//  Created by Sid Kumar on 6/15/25.
//

import SwiftUI

struct Message: Identifiable {
    let id = UUID()
    let text: String
    let isUser: Bool
}

struct ContentView: View {
    @State private var messages: [Message] = []
    @State private var inputText: String = ""
    @State private var isLoading: Bool = false

    let ollamaURL = URL(string: "http://localhost:11434/api/chat")!

    var body: some View {
        VStack {
            ScrollViewReader { scrollViewProxy in
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 8) {
                        ForEach(messages) { message in
                            HStack {
                                if message.isUser {
                                    Spacer()
                                    Text(message.text)
                                        .padding(10)
                                        .background(Color.blue.opacity(0.2))
                                        .cornerRadius(10)
                                } else {
                                    Text(message.text)
                                        .padding(10)
                                        .background(Color.gray.opacity(0.2))
                                        .cornerRadius(10)
                                    Spacer()
                                }
                            }
                        }
                    }
                    .padding()
                }
                .onChange(of: messages.count) { _ in
                    if let lastID = messages.last?.id {
                        withAnimation {
                            scrollViewProxy.scrollTo(lastID, anchor: .bottom)
                        }
                    }
                }
            }

            HStack {
                TextField("Type your message...", text: $inputText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .disabled(isLoading)
                Button("Send") {
                    sendMessage()
                }
                .disabled(inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isLoading)
            }
            .padding()
        }
    }

    func sendMessage() {
        let userMessage = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !userMessage.isEmpty else { return }
        messages.append(Message(text: userMessage, isUser: true))
        inputText = ""
        isLoading = true

        let ollamaMessages = messages.map { m in
            [
                "role": m.isUser ? "user" : "assistant",
                "content": m.text
            ]
        }

        let requestBody: [String: Any] = [
            "model": "llama3.2",
            "messages": ollamaMessages
        ]

        var request = URLRequest(url: ollamaURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: requestBody)

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            defer { isLoading = false }
            guard let data = data, error == nil else {
                DispatchQueue.main.async {
                    messages.append(Message(text: "Error: \(error?.localizedDescription ?? "Unknown error")", isUser: false))
                }
                return
            }

            // Ollama streams NDJSON (one JSON per line)
            guard let responseString = String(data: data, encoding: .utf8) else {
                DispatchQueue.main.async {
                    messages.append(Message(text: "Error: Unable to decode response from Ollama.", isUser: false))
                }
                return
            }
            print("Ollama raw response:\n\(responseString)")

            // Accumulate the assistant's response
            var assistantReply = ""
            responseString.enumerateLines { line, _ in
                if let lineData = line.data(using: .utf8),
                   let json = try? JSONSerialization.jsonObject(with: lineData) as? [String: Any],
                   let messageDict = json["message"] as? [String: Any],
                   let role = messageDict["role"] as? String,
                   role == "assistant",
                   let content = messageDict["content"] as? String {
                    assistantReply += content
                }
            }

            DispatchQueue.main.async {
                if !assistantReply.isEmpty {
                    messages.append(Message(text: assistantReply, isUser: false))
                } else {
                    messages.append(Message(text: "Error: No valid assistant reply received from Ollama.", isUser: false))
                }
            }
        }
        task.resume()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
