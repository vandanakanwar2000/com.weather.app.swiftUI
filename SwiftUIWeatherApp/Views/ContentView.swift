//
//  ContentView.swift
//  SwiftUIWeatherApp
//
//  Created by Vandana Kanwar on 29/6/20.
//  Copyright © 2020 Vandana Kanwar. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var fetch: WeatherDataModel
    
    @State private var shouldAnimate = true
    @State var isModal: Bool = false
    
    init() {
        UINavigationBar.appearance().backgroundColor = UIColor.init(hue: 11,
                                                                    saturation: 145,
                                                                    brightness: 1.0,
                                                                    alpha: 0.5)
    }
    
    var body: some View {
        NavigationView {
            ActivityIndicatorView(shouldAnimate: $fetch.loading) {
                ScrollView(.vertical) {
                    VStack {
                        Spacer()
                        if self.fetch.isErrorOcurred == false {
                            Divider().background(Color.blue)
                        }
                        if !self.fetch.datas.isEmpty {
                            CurrentWeatherView(model: self.fetch.datas.first!)
                            Spacer()
                        }
                        
                        if self.fetch.scrollingHeaderViewModel != nil {
                            HourlyView(model: self.fetch.scrollingHeaderViewModel!)
                            Spacer()
                        }
                        
                        if self.fetch.dailyWeather != nil {
                            DailyView(model: self.fetch.dailyWeather!)
                        }
                        
                        if self.fetch.isErrorOcurred == false {
                            Divider().background(Color.blue)
                        }
                        Text(self.fetch.weatherDescription ?? "")
                        
                        if self.fetch.isErrorOcurred == false {
                            Divider().background(Color.blue)
                        }
                        
                        Text(self.fetch.isErrorOcurred
                            ? "Something went wrong, Please check your network settings."
                            : "")
                            .font(.body)
                            .foregroundColor(.red)
                    }
                }.frame(minWidth: 0,
                        maxWidth: .infinity,
                        minHeight: 0,
                        maxHeight: .infinity,
                        alignment: Alignment.topLeading)
            }.padding()
                .navigationBarTitle("Weather", displayMode: .large)
                .navigationViewStyle(DefaultNavigationViewStyle())
                .navigationBarItems(trailing:
                    Button(action: {
                        self.isModal = true
                    }, label: {
                        Image(systemName: "magnifyingglass")
                            .font(.largeTitle)
                    }
                    ).foregroundColor(.blue)
            ).foregroundColor(.red)
        }.sheet(isPresented: $isModal,
                content: {
                    SearchView(isPresented: self.$isModal).environmentObject(self.fetch)
        })
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
