//
//  IconPicker.swift
//  RoadMe
//
//  Created by Benedict Kunzmann on 28.12.24.
//

import SwiftUI

struct IconPicker: View {
    @StateObject var newProject: ProjectTask
    @Binding var showPicker: Bool
    
    @State private var showImagePicker: Bool = false
    @State private var inputImage: UIImage?
    @State var emojis: [Emoji] = []
    @State var groupedEmojis: [String: [Emoji]] = [:]
    
    let columns = Array(repeating: GridItem(.flexible()), count: 8)
    let groupOrder: [String] = ["Smileys & Emotion", "People & Body", "Animals & Nature", "Food & Drink", "Activities", "Travel & Places", "Objects", "Symbols", "Flags", "Component"]
    
    var body: some View {
        VStack {
            HStack {
                if (newProject.iconString != nil || newProject.iconImage != nil) {
                    Text("Entfernen")
                        .foregroundStyle(Color.blue)
                        .onTapGesture {
                            newProject.iconString = nil
                            newProject.iconImage = nil
                        }
                }
                Spacer()
                Image(systemName: "xmark")
                    .font(.headline)
                    .onTapGesture {showPicker.toggle()}
            }
            Text("Select an image")
            if (newProject.iconImage == nil) {
                Image(systemName: "plus")
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 10).stroke(Color("TextColor"), lineWidth: 1))
                    .onTapGesture {
                        self.showImagePicker.toggle()
                    }
            } else {
                Image(uiImage: newProject.iconImage!)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 50, height: 50)
                    .mask(RoundedRectangle(cornerRadius: 10))
                    .onTapGesture {
                        self.showImagePicker.toggle()
                    }
            }
            Text("or")
            VStack(alignment: .leading) {
                HStack {
                    Text("Choose an emoji: ")
                    Text(newProject.iconString ?? "")
                }
                ScrollView(.vertical) {
                    LazyVStack(alignment: .leading, spacing: 20) {
                        // Iterate through categories in custom order
                        ForEach(sortedCategories(), id: \.self) { category in
                            Section(header: Text(category).font(.headline)) {
                                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 8), spacing: 15) {
                                    ForEach(groupedEmojis[category] ?? []) { emoji in
                                        Text(emoji.char)
                                            .font(.largeTitle)
                                            .onTapGesture {
                                                newProject.iconString = emoji.char
                                                newProject.iconImage = nil
                                            }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        .font(.body)
        .padding()
        .foregroundStyle(Color("TextColor"))
        .onAppear {
            emojis = decode("emoji.json")
            groupEmojisByCategory()
        }
        .onDisappear {
            self.groupedEmojis.removeAll()
            self.emojis.removeAll()
        }
        .onChange(of: inputImage) { _ in loadImage() }
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(image: $inputImage)
        }
    }
    
    func groupEmojisByCategory() {
       groupedEmojis = Dictionary(grouping: emojis, by: { $0.group })
    }
    
    func sortedCategories() -> [String] {
        groupOrder.filter { groupedEmojis.keys.contains($0) } // Include only existing categories
    }
    
    func loadImage() {
        guard let inputImage = inputImage else { return }
        newProject.iconImage = inputImage
        newProject.iconString = nil
    }
}

struct Emoji : Identifiable, Codable  {
    let id: UUID = UUID()
    let codes: String
    let char: String
    let name: String
    let category: String
    let group: String
    let subgroup: String
    
    private enum CodingKeys: String, CodingKey {
        case codes, char, name, category, group, subgroup
    }
}

func decode(_ file: String) -> [Emoji] {
    guard let url = Bundle.main.url(forResource: file, withExtension: nil) else {
        fatalError("Failed to locate \(file) in bundle")
    }
    
    guard let data = try? Data(contentsOf: url) else {
        fatalError("Failed to load \(file) from bundle")
    }
    
    let decoder = JSONDecoder()
    
    do {
        let loadedFile = try decoder.decode([Emoji].self, from: data)
        return loadedFile
    } catch {
        fatalError("Failed to decode \(file) from bundle: \(error)")
    }
}
