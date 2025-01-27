//
//  TextEditor.swift
//  RoadMe
//
//  Created by Benedict Kunzmann on 26.01.25.
//

import SwiftUI

struct TextEditorScrollableView: View {
    
    @StateObject var newTask: ProjectTask
    
    init(newTask: ProjectTask) {
        self._newTask = StateObject(wrappedValue: newTask)
        UITextView.appearance().backgroundColor = .clear
    }
    
    var body: some View {
        VStack {
            ScrollView {
                ZStack(alignment: .topLeading) {
                    TextEditor(text: $newTask.description)
                        .colorMultiply(Color("LightGray"))
                        .frame(minHeight: 26, alignment: .leading)
                        .fixedSize(horizontal: false, vertical: true)
                        .multilineTextAlignment(.leading)
                        .cornerRadius(6)
                }
            }
        }
    }
}
