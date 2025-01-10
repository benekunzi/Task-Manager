//
//  DropViewDelegate.swift
//  RoadMe
//
//  Created by Benedict Kunzmann on 02.01.25.
//

import SwiftUI

struct DropViewDelegate: DropDelegate {
    @ObservedObject var task: ProjectTask
    @Binding var subtasks: [ProjectTask]
    @Binding var draggedTask: ProjectTask?

    // Track whether a move operation has already been performed
    @State private var hasMoved: Bool = false

    func performDrop(info: DropInfo) -> Bool {
        // Reset the state when the drop is completed
        hasMoved = false
        return true
    }

    func dropEntered(info: DropInfo) {
        guard let draggedTask = draggedTask else { return }
        
        // Find the indices of the dragged and target tasks
        if let fromIndex = subtasks.firstIndex(where: { $0.id == draggedTask.id }),
           let toIndex = subtasks.firstIndex(where: { $0.id == task.id }) {
            
            // Prevent redundant moves
            if fromIndex != toIndex && !hasMoved {
                hasMoved = true
                withAnimation {
                    subtasks.move(fromOffsets: IndexSet(integer: fromIndex), toOffset: toIndex > fromIndex ? toIndex + 1 : toIndex)
                }
                // Update the index of the dragged task
                self.draggedTask?.index = Int32(toIndex)
            }
        }
    }
}
