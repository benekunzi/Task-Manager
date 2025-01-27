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
    @Binding var columns: [GridItem]
    @Binding var numberOfColumns: Int
    @Binding var showSubtasks: Bool
    
    @EnvironmentObject var projectModel: ProjectModel
    @EnvironmentObject var coreDataModel: CoreDataModel
    
    @State var size: CGSize = .zero
    @Binding var scale: CGFloat
    
    var body: some View {
        ScrollViewReader { reader in
            LazyVGrid(columns: self.columns, spacing: 20) {
                ForEach(Array(projectModel.filteredTasks), id: \.id) { task in
                    let taskIndex = projectModel.filteredTasks.firstIndex(where: { $0.id == task.id }) ?? 0
                    TaskCard(task: task,
                             showMoreOptions: $showMoreOptions,
                             isWiggling: $isWiggling,
                             numberOfColumns: $numberOfColumns,
                             scale: $scale,
                             showSubtasks: $showSubtasks)
                    .id(taskIndex)
                    .scaleEffect(task.isCompleted ? 0.9 : 1)
                    .opacity(task.isCompleted ? 0.5 : 1)
                    // Disappear up when isAppearing is false, appear from the bottom otherwise
                    .offset(y: projectModel.offsetTaskCards)
                    .animation(
                        .spring(response: 0.6, dampingFraction: 0.7)
                        .delay(Double(taskIndex) * 0.05), // Cascading effect
                        value: projectModel.offsetTaskCards
                    )
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
            }
            .id(projectModel.redrawID)
            .padding(.horizontal)
            .onChange(of: projectModel.offsetTaskCards) { newValue in print(newValue)}
            .onAppear {
                let taskIndex = projectModel.filteredTasks.firstIndex(where: { $0.isCompleted == false }) ?? 0
                withAnimation(.spring(duration: 0.75)) {
                    reader.scrollTo(taskIndex, anchor: .top)
                }
            }
        }
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
