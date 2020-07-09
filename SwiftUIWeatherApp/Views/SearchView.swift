//
//  SearchView.swift
//  SwiftUIWeatherApp
//
//  Created by Vandana Kanwar on 1/7/20.
//  Copyright © 2020 Vandana Kanwar. All rights reserved.
//

import Foundation
import SwiftUI

struct SearchView: View {
    @EnvironmentObject var weatherDataModel: WeatherDataModel
    @ObservedObject var searchModel = LocationSearchViewModel()
    @Environment(\.presentationMode) var presentationMode
    
    @Binding var isPresented: Bool
    
    @State private var selectedLocation: Location?
    @State private var searchText = ""
   
    var body: some View {
        
        NavigationView {
            VStack {
                SearchBar(text: $searchText, onTextChanged: searchLocations)
                Spacer()
                List {
                    ForEach(searchModel.locations) { item in
                        VStack {
                            Text(item.name ?? "")
                                .foregroundColor(.blue)
                            
                        }
                        .deleteDisabled(false)
                        .onTapGesture {
                            self.selectedLocation = item
                            if item.location != nil {
                                self.weatherDataModel.fetchWeatherInfoFromCoordinates(location: item.location!.coordinate)
                                self.searchModel.save(item)
                                self.presentationMode.wrappedValue.dismiss()
                            }
                        }.listRowBackground(self.selectedLocation == item
                            ? Color.white
                            : Color(UIColor.systemGroupedBackground))
                    }.onDelete { index in
                        self.delete(indexSet: index)
                    }
                 .padding()
                }
            }
            .navigationBarTitle("Search", displayMode: .inline)
            .navigationBarHidden(false)
            .navigationBarBackButtonHidden(false)
            .navigationBarItems(trailing: EditButton())
            .navigationViewStyle(DefaultNavigationViewStyle())
        }
        .onDisappear { self.isPresented = false }
        .resignKeyboardOnDragGesture()
    }
    
    func delete(indexSet: IndexSet) {
        indexSet.sorted(by: > ).forEach { (i) in
            let deletedLocation = searchModel.locations[i]
            searchModel.delete(location: deletedLocation)
            searchModel.locations.remove(at: i)
        }
    }
    
    func searchLocations(for searchText: String) {
        if !searchText.isEmpty {
            searchModel.search(searchString: searchText)
        }
    }
}

extension UIApplication {
    func endEditing(_ force: Bool) {
        self.windows
            .filter{$0.isKeyWindow}
            .first?
            .endEditing(force)
    }
}

struct ResignKeyboardOnDragGesture: ViewModifier {
    var gesture = DragGesture().onChanged{_ in
        UIApplication.shared.endEditing(true)
    }
    func body(content: Content) -> some View {
        content.gesture(gesture)
    }
}

extension View {
    func resignKeyboardOnDragGesture() -> some View {
        return modifier(ResignKeyboardOnDragGesture())
    }
}


struct SearchBar: UIViewRepresentable {

    @Binding var text: String
    var onTextChanged: (String) -> Void
    
    class Coordinator: NSObject, UISearchBarDelegate {

        @Binding var text: String
       
        var onTextChanged: (String) -> Void

        init(text: Binding<String>, onTextChanged: @escaping (String) -> Void) {
            _text = text
            self.onTextChanged = onTextChanged
        }

        // Show cancel button when the user begins editing the search text
        func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
            searchBar.showsCancelButton = true
        }

        func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
            text = searchText
            onTextChanged(text)
        }

        func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
            text = ""
            searchBar.showsCancelButton = false
            searchBar.endEditing(true)
            // Send back empty string text to search view, trigger self.model.searchResults.removeAll()
            onTextChanged(text)
        }
    }

    func makeCoordinator() -> SearchBar.Coordinator {
        return Coordinator(text: $text, onTextChanged: onTextChanged)
    }

    func makeUIView(context: UIViewRepresentableContext<SearchBar>) -> UISearchBar {
        let searchBar = UISearchBar(frame: .zero)
        searchBar.delegate = context.coordinator
        searchBar.searchBarStyle = .minimal
        return searchBar
    }

    func updateUIView(_ uiView: UISearchBar, context: UIViewRepresentableContext<SearchBar>) {
        uiView.text = text
    }
}
