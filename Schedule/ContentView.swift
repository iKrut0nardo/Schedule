//
//  ContentView.swift
//  Schedule
//
//  Created by Obi-Van Kenobi on 2.03.23.
//

import SwiftUI

struct ContentView: View {
    // Data for the dropdowns
    let faculties = ["Пусто","ФЭИС", "ФИСЭ", "ЭФ", "МСФ"]
    let courses = ["Пусто","1 курс", "2 курс", "3 курс","4 курс", "5 курс"]
    let groups = ["Пусто"]
    
    // Selected values from the dropdowns
    @State private var selectedFaculty = ""
    @State private var selectedCourse = ""
    @State private var selectedGroup = ""
    
    var availableGroups: [String] {
        switch (selectedFaculty, selectedCourse) {
        case ("ФЭИС", "3 курс"):
            return ["Пусто","ПО6", "ПО7"]
        default:
            return groups
        }
    }
    
    
    var body: some View {
        NavigationView {
            VStack {
                Spacer()
                // Dropdown for faculty selection
                Picker("Faculty", selection: $selectedFaculty) {
                    ForEach(faculties, id: \.self) {
                        Text($0)
                    }
                }
                
                
                // Dropdown for course selection
                Picker("Course", selection: $selectedCourse) {
                    ForEach(courses, id: \.self) {
                        Text($0)
                    }
                }
                .disabled(selectedFaculty.isEmpty)
                
                // Dropdown for group selection
                Picker("Group", selection: $selectedGroup) {
                    ForEach(availableGroups, id: \.self) {
                        Text($0)
                    }
                }
                
                .disabled(selectedCourse.isEmpty)
                Spacer()
                // Next button
                NavigationLink(destination: NextView(selectedGroup: selectedGroup)) {
                    Text("Далее").font(.largeTitle)
                }

                .disabled(selectedGroup.isEmpty)
            }
            .onTapGesture {
                // Save selected values to UserDefaults
                UserDefaults.standard.set(selectedFaculty, forKey: "SelectedFaculty")
                UserDefaults.standard.set(selectedCourse, forKey: "SelectedCourse")
                UserDefaults.standard.set(selectedGroup, forKey: "SelectedGroup")
            }
            
            .onAppear(perform: {
                // Load selected values from UserDefaults
                                if let savedFaculty = UserDefaults.standard.string(forKey: "SelectedFaculty") {
                                    selectedFaculty = savedFaculty
                                }
                                if let savedCourse = UserDefaults.standard.string(forKey: "SelectedCourse") {
                                    selectedCourse = savedCourse
                                }
                                if let savedGroup = UserDefaults.standard.string(forKey: "SelectedGroup") {
                                    selectedGroup = savedGroup
                                }
                            downloadDatabase()
                        })
        }
    }
}
        

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
