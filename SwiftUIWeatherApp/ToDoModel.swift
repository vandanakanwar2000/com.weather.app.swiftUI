//
//  ToDoModel.swift
//  SwiftUISampleApp
//
//  Created by Vandana Kanwar on 29/6/20.
//  Copyright © 2020 Vandana Kanwar. All rights reserved.
//

import Foundation


struct TodoModel: Codable, Identifiable {
    public var id: Int
    public var title: String
    public var completed: Bool
}




struct DayRowModel: Identifiable {
    var id = UUID()
    var day: String
    var date: String
    var degree: String
    var weather: WeatherType
}

class FetchToDo: ObservableObject {
  // 1.
     @Published var todos = [TodoModel]()
    
     @Published var datas: [DayRowModel] = []
    
    private var mockData: [DayRowModel] {
        return [.init(day: "Sunday", date: "10 Jun", degree: "19", weather: .sun),
                .init(day: "Monday", date: "11 Jun", degree: "12", weather: .rain),
                .init(day: "Wednesday", date: "12 Jun", degree: "15", weather: .sun),
                .init(day: "Thursday", date: "13 Jun", degree: "-2", weather: .snow),
                .init(day: "Friday", date: "14 Jun", degree: "-4", weather: .snow),]
    }
    
     
    init() {
       //fetchData()
    }
    
    func start() {
           datas = mockData
       }
       
    func fetchTodoList() {
        let url = URL(string: "https://jsonplaceholder.typicode.com/todos")!
        // 2.
        URLSession.shared.dataTask(with: url) {(data, response, error) in
            do {
                if let todoData = data {
                    // 3.
                    let decodedData = try JSONDecoder().decode([TodoModel].self, from: todoData)
                    DispatchQueue.main.async {
                        self.todos = decodedData
                    }
                } else {
                    print("No data")
                }
            } catch {
                print("Error")
            }
        }.resume()
    }
}


