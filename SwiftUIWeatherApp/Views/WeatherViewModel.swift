//
//  WeatherViewModel.swift
//  SwiftUIWeatherApp
//
//  Created by Vandana Kanwar on 1/7/20.
//  Copyright © 2020 Vandana Kanwar. All rights reserved.
//

import Foundation
import Combine
import CoreLocation

struct DayWeather: Codable, Identifiable {
    var id = UUID()
    let name: String?
    let dt: TimeInterval
    var date: Date {
        return Date(timeIntervalSince1970: dt)
    }
    let temp: String
    let maxTemp: String
    let minTemp: String
    let description: String?
    let weatherType: String?
    let sunRise: Int?
    let sunSet: Int?
    let icon: String?
}

struct DailyWeather: Codable, Identifiable {
    var id = UUID()
    let list: [ForcastViewModel]
}

struct ForcastViewModel: Codable, Identifiable {
    var id = UUID()
    let title: String
    let detail: String
    let image: String
    let subTitle: String
}

struct ScrollingHeaderViewModel: Codable, Identifiable {
    var id = UUID()
    let list: [HeaderViewModel]
}

struct HeaderViewModel: Codable, Identifiable {
    var id = UUID()
    var title: String
    var detail: String
    var image: String
}

enum WeatherType: String {
    case snow, rain, sun, clouds, clear
    
    var icon: String {
        switch self {
        case .clouds:
            return "cloud"
        case .rain:
            return "cloud.rain"
        case .snow:
            return "cloud.snow"
        case .sun:
            return "sun.min"
        case .clear:
            return "sun.max"
        }
    }
}


class WeatherDataModel: NSObject, ObservableObject {
    @Published var datas: [DayWeather] = []
    @Published var dailyWeather: DailyWeather?
    @Published var scrollingHeaderViewModel: ScrollingHeaderViewModel?
    @Published var weatherDescription: String?
    @Published var isErrorOcurred = false
    @Published var loading = false
    private let history = Storage()
    private var locationManager: CLLocationManager!
    private var geocoder = CLGeocoder()
    let service = WeatherService()
    
    override init() {
        self.loading = true
        super.init()
        locationManager = CLLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 100
        locationManager.requestAlwaysAuthorization()
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
        currentLocation()
    }
    
    private func geocode(location: CLLocation) {
        geocoder.cancelGeocode()
        geocoder = CLGeocoder()
        
        geocoder.reverseGeocodeLocation(location) { (placemarks, _) -> Void in
            if let placemark = placemarks?.first {
                self.history.save(Location(name: placemark.locality,
                                           location: location,
                                           placemark: placemark))
                
                self.fetchWeatherInfoFromCoordinates(location: location.coordinate)
            } else {
                /// Load last selected location if failed to reverse geocoding
                let locations = self.history.fetch()
                if !locations.isEmpty,
                    let location = locations.first,
                    let locationCoordinate = location.location?.coordinate {
                    self.fetchWeatherInfoFromCoordinates(location: locationCoordinate)
                }
            }
        }
    }
    
    func fetchWeatherInfoFromCoordinates(location: CLLocationCoordinate2D) {
        self.loading = true
        service.getCurrentWeather(at: location, requestType: ActivityType.weather, result: CurrentWeather.self) { result in
            switch result {
            case let .success(response):
                print("success \(response)")
                let weatherType = WeatherType(rawValue: response.weather.first?.main.lowercased() ?? "")
                let dayWeather = DayWeather(name: response.name, dt: response.dt,
                                            temp: LocalizedString.temperatureString(Int(response.main.temp)).description,
                                            maxTemp: LocalizedString.temperatureString(Int(response.main.tempMax)).description,
                                            minTemp: LocalizedString.temperatureString(Int(response.main.tempMin)).description,
                                            description: response.weather.first?.description,
                                            weatherType: response.weather.first?.main,
                                            sunRise: response.sys.sunrise,
                                            sunSet: response.sys.sunset,
                                            icon: weatherType?.icon)
                self.datas = [dayWeather]
                self.weatherDescription = LocalizedString.details(response.date.dayOfTheWeek,
                                                                  Int(response.main.temp),
                                                                  Int(response.main.tempMax)).description
            case .failure:
                print("Failure")
            }
        }
        
        
        service.getCurrentWeather(at: location, requestType: ActivityType.dailyForecast, result: DailyForcastResponse.self) { result in
            switch result {
            case let .success(response):
                print("success \(response)")
                var dailyForcastViewModels: [ForcastViewModel] = []
                guard let list = response.list, !list.isEmpty else { return }
                
                list.forEach { model in
                    let icon = model.weather?.first?.main.lowercased() ?? ""
                    let weatherType = WeatherType(rawValue: icon)
                    let viewModel = ForcastViewModel(title: model.date.dayOfTheWeek,
                                                     detail: LocalizedString.temperatureString(Int(model.temp?.max ?? 0.0)).description,
                                                     image: weatherType?.icon ?? "",
                                                     subTitle: LocalizedString.temperatureString(Int(model.temp?.min ?? 0.0)).description)
                    
                    dailyForcastViewModels.append(viewModel)
                }
                self.dailyWeather = DailyWeather(list: dailyForcastViewModels)
                
            case .failure:
                print("Failure")
            }
        }
        
        service.getCurrentWeather(at: location, requestType: ActivityType.forecast, result: ForcastResponse.self) { result in
            switch result {
            case let .success(response):
                print("success \(response)")
                var headerViewModels: [HeaderViewModel] = []
                guard !response.list.isEmpty else { return }
                
                response.list.forEach { model in
                    let icon = model.weather.first?.main.lowercased() ?? ""
                    let weatherType = WeatherType(rawValue: icon)
                    
                    let viewModel = HeaderViewModel(title: model.date.hourOfTheDay,
                                                    detail: LocalizedString.temperatureString(Int(model.main.temp)).description,
                                                    image: weatherType?.icon ?? "")
                    headerViewModels.append(viewModel)
                }
                self.scrollingHeaderViewModel = ScrollingHeaderViewModel(list: headerViewModels)
                self.loading = false
                self.isErrorOcurred = false
            case .failure:
                print("Failure")
            }
        }
    }
}

extension WeatherDataModel: CLLocationManagerDelegate {
    
    func currentLocation() {
        let status = CLLocationManager.authorizationStatus()
        handleLocationAuthorizationStatus(status: status)
    }
    
    // Respond to the result of the location manager authorization status
    func handleLocationAuthorizationStatus(status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.startUpdatingLocation()
        default:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager,
                         didChangeAuthorization status: CLAuthorizationStatus) {
        handleLocationAuthorizationStatus(status: status)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let userLocation = locations.last else { return }
        let latitude = userLocation.coordinate.latitude
        let longitude = userLocation.coordinate.longitude
        
        let location = CLLocation(latitude: latitude,
                                  longitude: longitude)
        self.loading = true
        geocode(location: location)
    }
    
    func locationManager(_: CLLocationManager, didFailWithError _: Error) {
        self.loading = false
        self.isErrorOcurred = true
    }
}
