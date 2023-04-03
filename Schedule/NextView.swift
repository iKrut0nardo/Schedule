//
//  NextView.swift
//  Schedule
//
//  Created by Obi-Van Kenobi on 2.03.23.
//
import SQLite3
import SwiftUI
import Foundation

struct NextView: View {
    
    @State var selection = 1
    
    var selectedGroup: String // группа выбранная на первой странице
    @State private var selectedWeekType = getAutoWeekType() // выбранный тип недели
    @State private var lessons = [Lesson]()// array to store lesson names
    @State private var autoWeektype = getAutoWeekType()
    
    var body: some View {
        TabView(selection: $selection) {
            // Вкладка с контентом
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
                    Text(getAutoWeekType())
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
                            Text("\(lesson.time), \(lesson.roomNumber), \(lesson.sybjectType)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                }
            .onAppear {
                loadLessons()
            }
            .onChange(of: selectedWeekType) { _ in
                loadLessons()
            }
            .tabItem {
                Image(systemName: "square.grid.2x2.fill")
                Text("Текущий день")
            }.tag(1)
            // Вкладка с настройками
            VStack{
                List {
                    Picker("Week Type", selection: $selectedWeekType) {
                        Text("Верхняя неделя").tag("Верхняя неделя")
                        Text("Нижняя неделя").tag("Нижняя неделя")
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    ForEach(Weekday.allCases, id: \.self) { weekday in
                        Section(header: Text(weekday.rawValue)) {
                            ForEach(getLessonsForWeekday(weekday: weekday), id: \.self) { lesson in
                                VStack(alignment: .leading) {
                                    Text("\(lesson.subjectName)")
                                    Text("\(lesson.time), \(lesson.roomNumber), \(lesson.sybjectType)")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    }
                    
                }
                
            }
            .tabItem {
                Image(systemName: "star")
                Text("Вся неделя")
            }.tag(2)
        }
        .navigationTitle(selection == 1 ? "Сегодня" : "Расписание")
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.large)
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    func loadLessons() {
        lessons = []
        if let db = connectToDatabase() {
            let query = """
                SELECT subject_name, time, room_number, subject_type
                FROM schedule
                WHERE day_of_week = '\(getCurrentWeekName())'
                AND week_type = '\(autoWeektype)'
                AND group_name = '\(selectedGroup)'
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
                   let subjectType = sqlite3_column_text(statement, 3) {
                    let lesson = Lesson(
                        subjectName: String(cString: subjectName),
                        time: String(cString: time),
                        roomNumber: String(cString: roomNumber),
                        sybjectType: String(cString: subjectType)
                    )
                    lessons.append(lesson)
                }
            }
            sqlite3_finalize(statement)
            sqlite3_close(db)
        }
    }
    
    func getLessonsForWeekday(weekday: Weekday) -> [Lesson] {
        var lessons = [Lesson]()
        if let db = connectToDatabase() {
            let query = """
                SELECT subject_name, time, room_number, subject_type
                FROM schedule
                WHERE day_of_week = '\(weekday.rawValue)'
                AND week_type = '\(selectedWeekType)'
                AND group_name = '\(selectedGroup)'
                """
            var statement: OpaquePointer?
            if sqlite3_prepare_v2(db, query, -1, &statement, nil) != SQLITE_OK {
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("error preparing select: \(errmsg)")
                return lessons
            }
            while sqlite3_step(statement) == SQLITE_ROW {
                if let subjectName = sqlite3_column_text(statement, 0),
                   let time = sqlite3_column_text(statement, 1),
                   let roomNumber = sqlite3_column_text(statement, 2),
                   let subjectType = sqlite3_column_text(statement, 3) {
                    let lesson = Lesson(
                        subjectName: String(cString: subjectName),
                        time: String(cString: time),
                        roomNumber: String(cString: roomNumber),
                        sybjectType: String(cString: subjectType)
                    )
                    lessons.append(lesson)
                }
            }
            sqlite3_finalize(statement)
            sqlite3_close(db)
        }
        return lessons
    }

}



struct NextView_Previews: PreviewProvider {
    @State static var selectedGroup = "ПО6"
    
    static var previews: some View {
        NextView(selectedGroup:selectedGroup )
            
    }
}

struct Lesson: Hashable {
    let subjectName: String
    let time: String
    let roomNumber: String
    let sybjectType: String
}

func getCurrentWeekName() -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "EEEE"
    dateFormatter.locale = Locale(identifier: "ru_RU")
    let currentWeekdayName = dateFormatter.string(from: Date())
    return currentWeekdayName.capitalized
}

enum Weekday: String, CaseIterable {
    case monday = "Понедельник"
    case tuesday = "Вторник"
    case wednesday = "Среда"
    case thursday = "Четверг"
    case friday = "Пятница"
    case saturday = "Суббота"
}

func getAutoWeekType() -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd"
    let septemberFirst = dateFormatter.date(from: "2023-09-01")! // задаем 1 сентября
    let daysFromSeptemberFirst = Int(Date().timeIntervalSince(septemberFirst)) / (24 * 60 * 60)
    let currentWeekNumber = daysFromSeptemberFirst / 7 + 1 // вычисляем номер текущей недели
    if currentWeekNumber % 2 == 1 {
        return "Верхняя неделя"
    } else {
        return "Нижняя неделя"
    }
}

