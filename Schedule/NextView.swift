//
//  NextView.swift
//  Schedule
//
//  Created by Obi-Van Kenobi on 2.03.23.
//
import SQLite3
import SwiftUI
import Foundation

enum Tabs : String {
    case Сегодня
    case Расписание
}


struct NextView: View {
    
    @State var selectedTab: Tabs = .Сегодня
    
    var selectedGroup: String // группа выбранная на первой странице
    @State private var selectedWeekType = getAutoWeekType() // выбранный тип недели
    //@State private var lessons = [Lesson]()// array to store lesson names
    @State private var autoWeektype = getAutoWeekType()
    
    var body: some View {
            TabView(selection: $selectedTab) {
                // Вкладка с контентом
                    TodayView(selectedGroup: selectedGroup)
                    .tabItem {
                        Image(systemName: "star")
                        Text("Текущий день")
                    }.tag(Tabs.Сегодня)
                
                // Вкладка с настройками
                    ScheduleView(selectedGroup: selectedGroup)
                    .tabItem {
                        Image(systemName: "house.fill")
                        Text("Вся неделя")
                    }.tag(Tabs.Расписание)
                    
                //Вкладка с сайта
                    NewsWebView(urlString: "https://news.bstu.by")
                    .tabItem{
                        Image(systemName: "display.and.arrow.down")
                        Text("Новости")
                    }
            }
            .navigationBarHidden(true)
        }
        
}


struct NextView_Previews: PreviewProvider {
    @State static var selectedGroup = "ПО6"
    
    static var previews: some View {
        NextView(selectedGroup:selectedGroup )
            
    }
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
    let daysFromSeptemberFirst = Int(Date().timeIntervalSince(septemberFirst)) / (24 * 60 * 60) + 1 // добавляем 1 день, чтобы учесть 1 сентября
    let currentWeekNumber = Int((Double(daysFromSeptemberFirst) / 7.0).rounded(.up))
    //print(currentWeekNumber)// округляем до ближайшего целого числа
    if currentWeekNumber % 2 == 0 {
        return "Верхняя неделя"
    } else {
        return "Нижняя неделя"
    }
}


