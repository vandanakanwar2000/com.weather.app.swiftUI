//
//  ActivityIndicator.swift
//  SwiftUIWeatherApp
//
//  Created by Vandana Kanwar on 1/7/20.
//  Copyright © 2020 Vandana Kanwar. All rights reserved.
//

import Foundation
import SwiftUI
import UIKit

struct ActivityIndicator: UIViewRepresentable {

    let style: UIActivityIndicatorView.Style
    
    @Binding var shouldAnimate: Bool

    private let spinner: UIActivityIndicatorView = {
        $0.hidesWhenStopped = true
        return $0
    }(UIActivityIndicatorView(style: .medium))

    func makeUIView(context: UIViewRepresentableContext<ActivityIndicator>) -> UIActivityIndicatorView {
        spinner.style = style
        return spinner
    }

    func updateUIView(_ uiView: UIActivityIndicatorView, context: UIViewRepresentableContext<ActivityIndicator>) {
        shouldAnimate ? uiView.startAnimating() : uiView.stopAnimating()
    }

    func configure(_ indicator: (UIActivityIndicatorView) -> Void) -> some View {
        indicator(spinner)
        return self
    }
}


struct ActivityIndicatorView<Content> : View where Content : View {
    
    @Binding var shouldAnimate : Bool
    var content: () -> Content
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .center) {
                if (!self.shouldAnimate) {
                    self.content()
                } else {
                    self.content()
                        .disabled(true)
                        .blur(radius: 3)
                    
                    VStack {
                        Text("Loading....")
                        ActivityIndicator(style: .large, shouldAnimate: self.$shouldAnimate)
                            .configure {
                                $0.color = UIColor.init(hue: 11, saturation: 145, brightness: 1.0, alpha: 0.5)
                        }
                    }
                    .frame(width: geometry.size.width/2.0, height: 200.0)
                    .background(Color.secondary.colorInvert())
                    .foregroundColor(Color.primary)
                    .cornerRadius(20)
                }
            }
        }
    }
}
