//
//  MainContent.swift
//  RoadMe
//
//  Created by Benedict Kunzmann on 07.01.25.
//

import SwiftUI
import UniformTypeIdentifiers

struct MainContentView: View {
    @Binding var showMoreOptions: Bool
    @Binding var isWiggling: Bool
    
    @EnvironmentObject var projectModel: ProjectModel
    @EnvironmentObject var coreDataModel: CoreDataModel
    
    @Binding var columns: [GridItem]
    @Binding var numberOfColumns: Int
    
    @State var size: CGSize = .zero
    @State var scale: CGFloat = 1
    
    var body: some View {
        LazyVGrid(columns: self.columns, spacing: 20) {
            ForEach(projectModel.selectedTask.subtasks, id: \.id) { task in
                TaskCard(task: task,
                         showMoreOptions: $showMoreOptions,
                         isWiggling: $isWiggling,
                         numberOfColumns: $numberOfColumns,
                         scale: $scale)
                .if(showMoreOptions) { view in
                    view
                        .onDrag {
                            projectModel.draggedTask = task
                            return NSItemProvider(object: task.name as NSString)
                        }
                        .onDrop(of: [UTType.text],
                                delegate: DropViewDelegate(
                                    task: task,
                                    subtasks: $projectModel.filteredTasks,
                                    draggedTask: $projectModel.draggedTask)
                        )
                }
            }
        }.id(projectModel.redrawID)
        .padding(.horizontal)
        .onChange(of: projectModel.filteredTasks) { tasks in
            if tasks.isEmpty {
                showMoreOptions = false
                isWiggling = false
            }
            
            for (idx, task) in tasks.enumerated() {
                if idx == tasks.endIndex - 1 {
                    let newIndex = tasks.firstIndex(where: { $0.id == task.id }) ?? Int(task.index)
                    task.index = Int32(newIndex)
                    projectModel.projectsTasks = coreDataModel.updateIndex(taskID: task.id, index: Int32(newIndex))
                    if let updatedTask = findTask(in: projectModel.projectsTasks, withID: projectModel.selectedTask.id) {
                        projectModel.changeSelectedTask(task: updatedTask)
                    } else {
                        print("task wasn't found")
                        projectModel.changeSelectedTask(task: projectModel.default_Project)
                    }
                } else {
                    let newIndex = tasks.firstIndex(where: { $0.id == task.id }) ?? Int(task.index)
                    task.index = Int32(newIndex)
                    _ = coreDataModel.updateIndex(taskID: task.id, index: Int32(newIndex))
                }
            }
        }
        .onChange(of: self.numberOfColumns) { newValue in
            if newValue == 1 {
                self.scale = 1.0
            } else if newValue == 2 {
                self.scale = 0.75
            } else if newValue == 3 {
                self.scale = 0.5
            }
        }
    }
}


extension View {
  func readWidth(onChange: @escaping (CGFloat) -> Void) -> some View {
    background(
      GeometryReader { geometryProxy in
        Spacer()
          .preference(
            key: HeightPreferenceKey.self,
            value: geometryProxy.size.width
          )
      }
    )
    .onPreferenceChange(HeightPreferenceKey.self, perform: onChange)
  }
}

private struct HeightPreferenceKey: PreferenceKey {
  static var defaultValue: CGFloat = .zero
  static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {}
}
