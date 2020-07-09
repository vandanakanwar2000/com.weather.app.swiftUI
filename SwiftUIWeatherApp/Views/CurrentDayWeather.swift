//
//  CurrentDayWeather.swift
//  SwiftUIWeatherApp
//
//  Created by Vandana Kanwar on 30/6/20.
//  Copyright © 2020 Vandana Kanwar. All rights reserved.
//

import Foundation
import SwiftUI

struct CurrentWeatherView: View {
    
   let model: DayWeather
    
    init(model: DayWeather) {
        self.model = model
    }
    
    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            
            Text(model.name ?? "")
                .font(.largeTitle)
                .fontWeight(.heavy)
                .foregroundColor(.blue)
                .multilineTextAlignment(.center)
            
            HStack {
                Text(model.description ?? "")
                    .font(.title)
                    .fontWeight(.semibold)
                    .foregroundColor(Color.gray)
                    .multilineTextAlignment(.center)
                Image(systemName: model.icon ?? "").renderingMode(.template) .foregroundColor(Color.blue)
            }
            
            Text(model.temp)
                .font(.largeTitle)
                .fontWeight(.heavy)
                .foregroundColor(.blue)
                .multilineTextAlignment(.center)
                .padding([.leading, .bottom, .trailing])
            HStack {
                Text("Max Temp:")
                    .font(.footnote)
                    .fontWeight(.semibold)
                    .foregroundColor(.blue)
                    .multilineTextAlignment(.leading)
                
                Text("\(model.maxTemp)")
                    .font(.footnote)
                    .fontWeight(.medium)
                
                Text("Min Temp:")
                    .font(.footnote)
                    .fontWeight(.bold)
                    .foregroundColor(.blue)
                    .multilineTextAlignment(.trailing)
                
                Text("\(model.minTemp)")
                    .font(.footnote)
                    .fontWeight(.medium)
            }
            .padding(.all)
         Divider().background(Color.blue)
        }.padding(.all)
        .background(Color.clear)
    }
}

struct CurrentWeatherView_Previews: PreviewProvider {
    
    static var previews: some View {
        CurrentWeatherView(model: DayWeather(name: "Sydney",
                                             dt: 1593492207,
                                             temp: "17.4",
                                             maxTemp: "18.33",
                                             minTemp: "16.33",
                                             description: "scattered clouds",
                                             weatherType: "clouds",
                                             sunRise: 1593464455,
                                             sunSet: 1593500185,
                                             icon: WeatherType.clouds.icon))
    }
}
