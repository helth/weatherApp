//
//  WeatherDetailedView.swift
//  ForeFlight
//
//  Created by Frederik Helth on 21/01/2024.
//

import SwiftUI
import CoreData

struct KeyValueRow: View {
    let key: String
    let value: String

    var body: some View {
        HStack {
            Text(key)
            Spacer()
            Text(value)
        }
    }
}

struct WeatherDetailedView: View {
    @State private var weatherModels: [WeatherModel] = []
    var ident: String
    @State private var timer: Timer?
    
        var body: some View {
            
            if(weatherModels.isEmpty){
                ProgressView().onAppear(perform: {
                    loadData(cachePolicy: CachePolicy.reloadIgnoringLocalCacheData)
                })
            }else{
                
                TabView {
                
                    
                    List(weatherModels, id: \.report.conditions.dateIssued) { weatherModel in
                        Section(header: Text("Conditions")) {
                            Text("Date Issued: \(weatherModel.report.conditions.dateIssued)")
                            Text("Location: Lat \(weatherModel.report.conditions.lat), Lon \(weatherModel.report.conditions.lon)")
                            Text("Temperature: \(weatherModel.report.conditions.tempC) °C")
                            Text("Wind Speed: \(weatherModel.report.conditions.wind.speedKts) kts")
                            Text("Pressure: \(weatherModel.report.conditions.pressureHg) inHg")
                            Text("Relative Humidity: \(weatherModel.report.conditions.relativeHumidity)%")
                            Text("Flight Rules: \(weatherModel.report.conditions.flightRules)")
                        }

                        Section(header: Text("Cloud Layers")) {
                            ForEach(weatherModel.report.conditions.cloudLayers, id: \.altitudeFt) { cloudLayer in
                                Text("Coverage: \(cloudLayer.coverage), Altitude: \(cloudLayer.altitudeFt) ft, Ceiling: \(cloudLayer.ceiling ? "Yes" : "No")")
                            }
                        }

                        Section(header: Text("Visibility")) {
                            Text("Distance: \(weatherModel.report.conditions.visibility.distanceSm) SM")
                            Text("Prevailing Visibility: \(weatherModel.report.conditions.visibility.prevailingVisSm) SM")
                        }

                    }
                                .tabItem {
                                    Label("Conditions", systemImage: "cloud")
                                }

                    List(weatherModels, id: \.report.forecast.dateIssued) { weatherModel in
                        Section(header: Text("Forecast")) {
                            Text("Date Issued: \(weatherModel.report.forecast.dateIssued)")
                            Text("Text: \(weatherModel.report.forecast.text)")
                            Text("Location: Lat \(weatherModel.report.forecast.lat), Lon \(weatherModel.report.forecast.lon)")
                        }

                    }
                                .tabItem {
                                    Label("Forecast", systemImage: "cloud.rain")
                                }
                        }.onAppear(perform: {
                            self.timer = Timer.scheduledTimer(withTimeInterval: 10, repeats: true) { timer in
                                // This closure will be called every 10 seconds
                                loadData(cachePolicy: CachePolicy.reloadIgnoringLocalCacheData)
                            }
                        })

                        // Timer invalidation in onDisappear
                        .onDisappear(perform: {
                            self.timer?.invalidate()
                            self.timer = nil
                        })
            
            }
        }
    
    private func loadData(cachePolicy: CachePolicy) {
        if let url = URL(string: "https://qa.foreflight.com/weather/report/\(self.ident)") {
            let headers = ["ff-coding-exercise": "1"]
            fetchData(from: url, headers: headers, cachePolicy: cachePolicy) { (result: Result<WeatherModel, NetworkError>) in
                switch result {
                case .success(let data):
                    
                    DispatchQueue.main.async {
                        weatherModels = [data]  // Assuming WeatherModel is an array
                        print("Data loaded.")
                    }
                    
                case .failure(let error):
                    // Handle error, e.g., show an error message
                    print("Error: \(error)")
                }
            }
        }else{
            print("URL is not valid ")
        }
    }
}

/*
struct WeatherDetailedView_Previews: PreviewProvider {
    static var previews: some View {
        return WeatherDetailedView();
    }
}
*/
