//
//  Picker.swift
//  RoadMe
//
//  Created by Benedict Kunzmann on 21.01.25.
//

import SwiftUI

struct PickerView: UIViewRepresentable {
    var data: [[String]]
    @Binding var selections: [Int]
    
    //makeCoordinator()
    func makeCoordinator() -> PickerView.Coordinator {
        Coordinator(self)
    }

    //makeUIView(context:)
    func makeUIView(context: UIViewRepresentableContext<PickerView>) -> UIPickerView {
        let picker = UIPickerView(frame: .zero)
        
        picker.dataSource = context.coordinator
        picker.delegate = context.coordinator

        return picker
    }

    //updateUIView(_:context:)
    func updateUIView(_ view: UIPickerView, context: UIViewRepresentableContext<PickerView>) {
        for i in 0...(self.selections.count - 1) {
            view.selectRow(self.selections[i], inComponent: i, animated: false)
        }
        context.coordinator.parent = self // fix
    }
    
    class Coordinator: NSObject, UIPickerViewDataSource, UIPickerViewDelegate {
        var parent: PickerView
        
        //init(_:)
        init(_ pickerView: PickerView) {
            self.parent = pickerView
        }
        
        //numberOfComponents(in:)
        func numberOfComponents(in pickerView: UIPickerView) -> Int {
            return self.parent.data.count
        }
        
        //pickerView(_:numberOfRowsInComponent:)
        func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
            return self.parent.data[component].count
        }
        
        //pickerView(_:titleForRow:forComponent:)
        func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
            return self.parent.data[component][row]
        }
        
        //pickerView(_:didSelectRow:inComponent:)
        func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
            self.parent.selections[component] = row
        }
    }
}
