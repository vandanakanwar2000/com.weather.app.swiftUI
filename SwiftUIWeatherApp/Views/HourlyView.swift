//
//  HourlyView.swift
//  SwiftUIWeatherApp
//
//  Created by Vandana Kanwar on 1/7/20.
//  Copyright © 2020 Vandana Kanwar. All rights reserved.
//

import Foundation
import SwiftUI

struct HourlyView: View {
    let model: ScrollingHeaderViewModel
    
    init(model: ScrollingHeaderViewModel) {
           self.model = model
       }
    
    var body: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 0) {
                ForEach(self.model.list) { item in
                    VStack {
                        Text(item.title)
                            .foregroundColor(.black)
                            .lineLimit(0)
                        Image(systemName: item.image).renderingMode(.template).foregroundColor(Color.blue)
                        Text(item.detail)
                        .foregroundColor(.black)
                    }.padding([.top, .bottom, .trailing])
                }
            }
            .padding(.all)
            .background(Color.clear)
        }
    }
}


struct HourlyView_Previews: PreviewProvider {
    static var previews: some View {
        HourlyView(model: ScrollingHeaderViewModel(list: [HeaderViewModel(title: "17.0", detail: "8.0", image: "cloud"),
                                                          HeaderViewModel(title: "16.0", detail: "8.0", image: "cloud")]))
    }
}
