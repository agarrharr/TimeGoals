//
//  ContentView.swift
//  Time Goals
//
//  Created by Adam Garrett-Harris on 9/1/21.
//

import SwiftUI

struct TimeEntry: Decodable, Identifiable {
    var id: Int
    var guid: String?
    var wid: Int?
    var pid: Int?
    var billable: Bool?
    var start: Date?
    var duration: Int?
    var description: String?
    var duronly: Bool?
    var at: Date?
    var uid: Int?
}

struct ContentView: View {
    @State private var timeEntries: [TimeEntry] = []
    
    var body: some View {
        VStack {
            Button(action: { fetchTimeEntries() }, label: {
                Text("Get time entries")
            })
            List(timeEntries) { timeEntry in
                Text("\(timeEntry.id) \(timeEntry.description ?? "")")
            }
        }
    }
    
    func fetchTimeEntries() {
        guard let url = URL(string: "https://api.track.toggl.com/api/v8/time_entries") else {
            return
        }
        let apiToken = (Bundle.main.infoDictionary?["TOGGL_API_TOKEN"] as? String)!

        let utf8Token = "\(apiToken):api_token".data(using: .utf8)
        guard let base64EncodedToken = utf8Token?.base64EncodedString(options: Data.Base64EncodingOptions(rawValue: 0)) else {
            print("Error encoding Toggl token")
            return
        }
        let authorizationToken = "Basic \(base64EncodedToken)"

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue(authorizationToken, forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        URLSession.shared.dataTask(with: request) { data, response, taskError in
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200..<300).contains(httpResponse.statusCode),
                  let data = data else {
                print("Error getting HTTP response")
                fatalError()
            }
            
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            
            guard let response = try? decoder.decode([TimeEntry].self, from: data) else {
                print("Error decoding json")
                return
            }
            
            DispatchQueue.main.async {
                self.timeEntries = response
            }
        }.resume()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
