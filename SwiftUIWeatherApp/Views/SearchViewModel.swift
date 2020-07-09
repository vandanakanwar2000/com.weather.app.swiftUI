//
//  SearchViewModel.swift
//  SwiftUIWeatherApp
//
//  Created by Vandana Kanwar on 1/7/20.
//  Copyright © 2020 Vandana Kanwar. All rights reserved.
//

import Foundation
import MapKit
import SwiftUI
import Combine

final class LocationSearchViewModel: ObservableObject {
    @Published var query: String = ""
    @Published var locationNames: [String] = []
    @Published var locations: [Location] = []

    let searchHistoryLabel = LocalizedString.searchHistoryText.description
    let storage = Storage()

    private var pendingRequestWorkItem: DispatchWorkItem?

    var geocoder = CLGeocoder()
    var localSearch: MKLocalSearch?
    
     private var cancellable: AnyCancellable?

    init() {
        self.locations = fetchCachedLocations()
        self.locations.filter({ !($0.name ?? "").isEmpty }).forEach { item in
            locationNames.append(item.name ?? "")
        }
        
        if self.locations.isEmpty {
            search(searchString: query)
        }
    }

    func fetchCachedLocations() -> [Location] {
        return storage.fetch()
    }

    func localMapSearch(searchString: String) {
        let searchTerm = searchString.trimmingCharacters(in: CharacterSet.whitespaces)
        if searchTerm.isEmpty {
            return
        }

        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchTerm
        localSearch?.cancel()
        localSearch = MKLocalSearch(request: request)
        localSearch?.start { response, _ in
            self.showItemsForSearchResult(response)
        }
    }

    func showItemsForSearchResult(_ searchResult: MKLocalSearch.Response?) {
        self.locations = searchResult?.mapItems.map { Location(name: $0.name, placemark: $0.placemark) } ?? []
        self.locations.filter({ !($0.name ?? "").isEmpty }).forEach { item in
            locationNames.append(item.name ?? "")
        }
    }

    func search(searchString: String) {
        pendingRequestWorkItem?.cancel()
        showItemsForSearchResult(nil)
        locationNames = []
        let requestWorkItem = DispatchWorkItem { [weak self] in
            guard let self = self else { return }
            self.localMapSearch(searchString: searchString)
        }
        pendingRequestWorkItem = requestWorkItem
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(10),
                                      execute: requestWorkItem)
    }

    func save(_ location: Location) {
        storage.save(location)
    }

    func delete(location: Location) {
        storage.delete(location)
    }
    
    deinit {
        print("deinit")
    }
}
