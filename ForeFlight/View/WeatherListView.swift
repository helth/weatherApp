//
//  ContentView.swift
//  ForeFlight
//
//  Created by Frederik Helth on 21/01/2024.
//

import SwiftUI
import CoreData

struct WeatherListView: View {
    
    // We need to access the managed object context in order to manipulate data model content.
    @Environment(\.managedObjectContext) var moc
    @State private var searchString: String = ""
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \WeatherData.name, ascending: false)]) var data: FetchedResults<WeatherData>
    
    @State private var isShowingAlert = false
    @State private var alertInput = ""
    
    @State var activated: Bool = false
    
    var body: some View {
        NavigationStack {
            
            // Seems like a hack. I would assume another solution would
            // be better for programmatically changing view
            NavigationLink(destination: WeatherDetailedView(ident: self.alertInput), isActive: $activated) {
                EmptyView()
            }
            
            
            VStack {
                List {
                    ForEach(Array(data.enumerated()), id: \.element.id) { index, item in
                        NavigationLink(destination: WeatherDetailedView(ident: item.name ?? "Unknown")) {
                            Text(item.name ?? "Unknown")
                                       }
                                   }
                    .onDelete(perform: deleteItem) // Add swipe-to-delete functionality
                }
            }.textFieldAlert(isShowing: $isShowingAlert, text: $alertInput , title: "Add airport", onDismiss: addNewItem)
            
            .navigationTitle("Weather Forecast").toolbar {
                ToolbarItem(placement: .bottomBar) {
                    Button("Add airpdort") {
                        self.isShowingAlert.toggle()
                        // self.activated = true
                    }
                }
            }
            
        }.onAppear(perform: {
            if isFirstLaunch() {
                addNewItemByString(ident: "kaus")
                addNewItemByString(ident: "KPWM")
            }
        })
    }
    
    func deleteItem(at offsets: IndexSet){
        for offset in offsets {
            let item = data[offset]
            moc.delete(item)
        }
    
        try? moc.save()
    }
    
    func addNewItem(){
        print("https://qa.foreflight.com/weather/report/\(self.alertInput)")
        if let url = URL(string: "https://qa.foreflight.com/weather/report/\(self.alertInput)") {
            let headers = ["ff-coding-exercise": "1"]
            fetchData(from: url, headers: headers, cachePolicy: .returnCacheDataElseLoad) { (result: Result<WeatherModel, NetworkError>) in
                switch result {
                case .success( _):
                    do {
                        let weatherData = WeatherData(context: moc)
                        weatherData.id = UUID()
                        weatherData.name = self.alertInput
                        
                        try moc.save()
                        self.activated = true
                        self.isShowingAlert.toggle()
                        
                    }catch{
                        print("Could not save data: \(error.localizedDescription)")
                    }
                    
                case .failure(let error):
                    print("Error: \(error)")
                }
            }
        }else{
            print("URL is not valid ")
        }
    }
    
    func addNewItemByString(ident: String){
        print("https://qa.foreflight.com/weather/report/\(ident)")
        if let url = URL(string: "https://qa.foreflight.com/weather/report/\(ident)") {
            let headers = ["ff-coding-exercise": "1"]
            fetchData(from: url, headers: headers, cachePolicy: .returnCacheDataElseLoad) { (result: Result<WeatherModel, NetworkError>) in
                switch result {
                case .success( _):
                    do {
                        let weatherData = WeatherData(context: moc)
                        weatherData.id = UUID()
                        weatherData.name = ident
                        
                        try moc.save()
                        
                    }catch{
                        print("Could not save data: \(error.localizedDescription)")
                    }
                    
                case .failure(let error):
                    print("Error: \(error)")
                }
            }
        }else{
            print("URL is not valid ")
        }
    }
    
    func isFirstLaunch() -> Bool {
        return !UserDefaults.standard.bool(forKey: "hasLaunchedBefore")
    }

    func setFirstLaunchFlag() {
        UserDefaults.standard.set(true, forKey: "hasLaunchedBefore")
    }

    
}

struct TextFieldAlert<Presenting>: View where Presenting: View {

    @Binding var isShowing: Bool
    @Binding var text: String
    let presenting: Presenting
    let title: String
    let onDismiss: () -> Void

    var body: some View {
        GeometryReader { (deviceSize: GeometryProxy) in
            ZStack {
                self.presenting
                    .disabled(isShowing)
                VStack {
                    Text(self.title)
                    TextField("Enter airport ident", text: self.$text).disableAutocorrection(true).autocapitalization(.none)
                    Divider()
                    HStack(spacing: 10) {
                        Button(action: {
                            withAnimation {
                                onDismiss()
                            }
                        }) {
                            Text("Create")
                        }
                        Button(action: {
                            withAnimation {
                                isShowing = false
                            }
                        }) {
                            Text("Cancel")
                        }
                    }
                }
                .padding()
                .background(Color.white)
                .frame(
                    width: deviceSize.size.width*0.7,
                    height: deviceSize.size.height*0.7
                )
                .shadow(radius: 1)
                .opacity(self.isShowing ? 1 : 0)
            }
        }
    }

}

extension View {

    func textFieldAlert(isShowing: Binding<Bool>,
                        text: Binding<String>,
                        title: String,
                        onDismiss: @escaping () -> Void) -> some View {
        TextFieldAlert(isShowing: isShowing,
                       text: text,
                       presenting: self,
                       title: title,
                       onDismiss: onDismiss)
    }

}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        return WeatherListView();
    }
}
