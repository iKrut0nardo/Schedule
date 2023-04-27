//
//  TodayView.swift
//  Schedule
//
//  Created by Obi-Van Kenobi on 5.04.23.
//
import SQLite3
import SwiftUI
import Foundation


struct TodayView: View {
    
    var selectedGroup: String // группа выбранная на первой странице
    var selectedSubGroup: String
    @State private var selectedWeekType = getAutoWeekType() // выбранный тип недели
    @State private var lessons = [Lesson]()// array to store lesson names
    @State private var autoWeektype = getAutoWeekType()
    
    var body: some View {
        NavigationView{
            VStack {
                Text(getCurrentWeekName())
                    .bold()
                    .font(.none)
                    .foregroundColor(.secondary)
                    .frame(
                        maxWidth: .infinity,
                        alignment: .topLeading
                    )
                    .padding(.leading)
                Text(typeText())
                    .font(.none)
                    .bold()
                    .foregroundColor(.secondary)
                    .frame(
                        maxWidth: .infinity,
                        alignment: .topLeading
                    )
                    .padding(.leading)
                List(lessons, id: \.self) { lesson in
                    VStack(alignment: .leading) {
                        Text("\(lesson.subjectName)")
                        Text("\(lesson.time), \(lesson.roomNumber), \(lesson.sybjectType), \(lesson.teacher)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Сегодня")
        }
        .onAppear {
            loadLessons()
        }
        .onChange(of: selectedWeekType) { _ in
            loadLessons()
        }
    }
    
    func loadLessons() {
        lessons = []
        if let db = connectToDatabase() {
            let query = """
                SELECT subject_name, time, room_number, subject_type, teacher
                FROM schedule
                WHERE day_of_week = '\(getCurrentWeekName())'
                AND week_type = '\(autoWeektype)'
                AND group_name = '\(selectedGroup)'
                AND sub_group_name = '\(selectedSubGroup)'
                """
            var statement: OpaquePointer?
            if sqlite3_prepare_v2(db, query, -1, &statement, nil) != SQLITE_OK {
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("error preparing select: \(errmsg)")
                return
            }
            while sqlite3_step(statement) == SQLITE_ROW {
                if let subjectName = sqlite3_column_text(statement, 0),
                   let time = sqlite3_column_text(statement, 1),
                   let roomNumber = sqlite3_column_text(statement, 2),
                   let subjectType = sqlite3_column_text(statement, 3),
                   let teacher = sqlite3_column_text(statement, 4){
                    let lesson = Lesson(
                        subjectName: String(cString: subjectName),
                        time: String(cString: time),
                        roomNumber: String(cString: roomNumber),
                        sybjectType: String(cString: subjectType),
                        teacher: String(cString: teacher)
                    )
                    lessons.append(lesson)
                }
            }
            sqlite3_finalize(statement)
            sqlite3_close(db)
        }
    }
    
}

struct Lesson: Hashable {
    let subjectName: String
    let time: String
    let roomNumber: String
    let sybjectType: String
    let teacher: String
}

func typeText() -> String {
    if getCurrentWeekName() == "Воскресенье" {
        return "Выходной"
    }
    else{
        return getAutoWeekType()
    }
}


