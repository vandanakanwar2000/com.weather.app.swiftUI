//
//  DayList.swift
//  SwiftUISampleApp
//
//  Created by Vandana Kanwar on 30/6/20.
//  Copyright © 2020 Vandana Kanwar. All rights reserved.
//

import Foundation
import SwiftUI

struct DayList: View {
    
    private var topColor = Color(red: 146/255, green: 78/255, blue: 163/255)
    private var centerColor = Color(red: 64/255, green: 49/255, blue: 140/255)
    private var bottomColor = Color(red: 40/255, green: 30/255, blue: 90/255)
    
    @ObservedObject var viewModel = FetchToDo()
    
    
    init() {
        UINavigationBar.appearance().backgroundColor = UIColor(red: 40/255, green: 30/255, blue: 90/255, alpha: 1)
        UINavigationBar.appearance().largeTitleTextAttributes = [
            .foregroundColor: UIColor.white]
        UITableView.appearance().backgroundColor = UIColor.clear
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(gradient: Gradient(colors: [topColor,centerColor, bottomColor]), startPoint: .topLeading, endPoint: .bottom)
                    .edgesIgnoringSafeArea(.all)
                VStack {
                    ForEach(self.viewModel.datas) { value in
                        NavigationLink(destination: DetailView(title:"")){
                            DayInfoRow(model: value)
                        }
                    }
                    .listRowBackground(Color.clear)
                }
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: Alignment.topLeading)
                    
                .navigationBarTitle(Text("Weather App"),
                                    displayMode: .inline)
            }
            
        }.onAppear {
            self.viewModel.start()
        }
    }
    
}

struct DayListPreview: PreviewProvider {
    static var previews: some View {
        DayList()
    }
}


struct DetailRowModel: Identifiable {
    var id = UUID()
    var degree: Int
    var time: String
    var weather: WeatherType
}


struct DetailView: View {

    private var data: [DetailRowModel] {
        return [.init(degree: 12, time: "09:00", weather: .clouds),
                .init(degree: 13, time: "12:00", weather: .rain),
                .init(degree: 11, time: "15:00", weather: .clouds),
                .init(degree: 12, time: "17:00", weather: .rain)]
    }
     
    private let title: String
    
    
    
    init(title: String) {
        self.title = title
    }
    
    var body: some View {
        
        ZStack {
            LinearGradient(gradient: Gradient(colors: [.topColor,.centerColor,.bottomColor]), startPoint: .topLeading, endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)
            VStack {
                Spacer()
                HStack(spacing: 34) {
                    TimeWeatherRow(model: data[0])
                    TimeWeatherRow(model: data[1])
                    TimeWeatherRow(model: data[2])
                    TimeWeatherRow(model: data[3])
                }
                Spacer()
            }
            .navigationBarTitle(Text("Detail View"), displayMode: .inline)
        }
    }
    
}

struct DetailView_Previews: PreviewProvider {
    static var previews: some View {
        DetailView(title: "Sunday")
    }
}


struct TimeWeatherRow: View {
    
    let data: DetailRowModel
    init(model: DetailRowModel) {
        self.data = model
    }
    
    var body: some View {
        VStack {
            HStack {
                Text("\(data.degree)")
                    .font(.system(size: 40))
                    .foregroundColor(.white)
                Text("°")
                    .font(.system(size: 30))
                    .foregroundColor(.white)
                    .fontWeight(.medium)
                    .padding(.leading, -10).padding(.top, -24)
            }.padding(.bottom, -24)
            ZStack {
                Circle()
                    .stroke(Color.gray, lineWidth: 1)
                    .frame(width: 54, height: 64, alignment: .center)
                
                Image(systemName:data.weather.icon)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 30, height: 50, alignment: .center)
                    .foregroundColor(.white)
            }
            Text(data.time)
                .font(.system(size: 16))
                .foregroundColor(.white)
        }
    }
}

struct DayInfoRow: View {
    
    private var bottomColor = Color(red: 40/255, green: 30/255, blue: 90/255)
    let model: DayRowModel
    
    init(model: DayRowModel) {
        self.model = model
    }
    
    var body: some View {
        Group {
            HStack {
                //Day And Date
                VStack(alignment: .leading, spacing: 8) {
                    Text(model.day)
                        .font(.title)
                        .fontWeight(.light)
                        .foregroundColor(Color.red)
                        .multilineTextAlignment(.center)
                        .padding(.all)
                    Text(model.date).font(.system(size: 14)).foregroundColor(.gray)
                }.padding(EdgeInsets(top: 24, leading: 28, bottom: 24, trailing: 0))
                Spacer()
                Text(model.degree).font(.system(size: 24)).foregroundColor(Color.white).padding(.trailing, -6)
                Text("°").font(.system(size: 24)).foregroundColor(Color.white).padding(.trailing, 2).padding(.top, -10)
                Image(systemName: model.weather.icon)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 30, height: 50, alignment: .center)
                    .padding(.trailing,20)
                    .foregroundColor(Color.white)
            }
        }.background(LinearGradient(gradient: Gradient(colors: [self.bottomColor, Color.clear]), startPoint: .top, endPoint: .bottom).opacity(0.1))
            .background(Color.clear)
    }
}
