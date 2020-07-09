//
//  DailyView.swift
//  SwiftUIWeatherApp
//
//  Created by Vandana Kanwar on 1/7/20.
//  Copyright © 2020 Vandana Kanwar. All rights reserved.
//

import Foundation
import SwiftUI

struct DailyView: View {
    
   let model: DailyWeather
    
    init(model: DailyWeather) {
        self.model = model
    }
    
    var body: some View {
        ScrollView(.vertical) {
            VStack {
                ForEach(self.model.list) { item in
                    VStack(alignment: .leading) {
                        HStack {
                            Text(item.title)
                                .lineLimit(1)
                        .foregroundColor(.black)
                                .frame(minWidth: 0,
                                maxWidth: 100,
                                minHeight: 0,
                                maxHeight: .infinity,
                                alignment: Alignment.topLeading)
                            
                            HStack {
                                Image(systemName: item.image).renderingMode(.template).foregroundColor(.blue)
                            }
                            Spacer()
                            Text("Max")
                                .foregroundColor(.black)
                            Divider()
                            Text(item.detail)
                                .foregroundColor(.black)
                            Spacer()
                            Text("Min")
                                .foregroundColor(.black)
                            Divider()
                            Text(item.subTitle) .foregroundColor(.black)
                        }.listRowBackground(Color.clear)
                    }.frame(minWidth: 0,
                            maxWidth: .infinity,
                            minHeight: 0,
                            maxHeight: .infinity,
                            alignment: Alignment.topLeading)
                }
            }
            .padding(.all)
            .background(Color.clear)
        }
    }
}

struct DailyView_Previews: PreviewProvider {
    static var previews: some View {
        DailyView(model: DailyWeather(list: [ForcastViewModel(title: "Monday",
                                                              detail: "16°C",
                                                              image: "cloud.rain",
                                                              subTitle: "8°C"),
        ForcastViewModel(title: "Friday",
        detail: "16°C",
        image: "cloud",
        subTitle: "15°C")]))
    }
}
