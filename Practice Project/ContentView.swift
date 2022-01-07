//
//  ContentView.swift
//  Practice Project
//
//  Created by Kamil on 29/12/2021.
//

import CoreML
import SwiftUI

struct ContentView: View {
    
    @State private var wakeUp = defaultWakeTime
    @State private var sleepAmount = 8.0
    @State private var coffeeAmount = 1
    
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var showingAlert = false
    
    static var defaultWakeTime: Date {
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        return Calendar.current.date(from: components) ?? Date.now
    }
    
    
    
    var body: some View {
        
        
        NavigationView {
            
            Form {
                Section {
                    DatePicker("Please enter a time", selection: $wakeUp, displayedComponents: .hourAndMinute)
                        .labelsHidden()
                        .onReceive([self.wakeUp].publisher.first()) { value in
                            self.calculateBedtime()
                        }
                } header: {
                    Text("When do you want to wake up?")
                        .font(.headline)
                }
                
                Section {
                    Stepper("\(sleepAmount.formatted()) hours", value: $sleepAmount, in: 4...12, step: 0.25)
                } header: {
                    Text("Desired amount of sleep")
                        .font(.headline)
                }
                
                Section {
                    Picker("Daily cups of coffee intake", selection: $coffeeAmount) {
                        ForEach(0..<21) {
                            Text($0 == 1 ? "\($0) cup" : "\($0) cups")
                        }
                    }
                    .pickerStyle(.wheel)
                    .onReceive([self.coffeeAmount].publisher.first()) {value in
                        self.calculateBedtime()
                    }
                } header: {
                    Text("Daily cups of coffee intake")
                        .font(.headline)
                }
                Section {
                    Text("\(alertMessage)")
                        .font(.title.bold())
                } header: {
                    Text("\(alertTitle)")
                }
                
            }
            .navigationTitle("BetterRest")
        }
    }
    func calculateBedtime() {
        do {
            let config = MLModelConfiguration()
            let model = try SleepCalculator(configuration: config)
            
            let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
            let hour = (components.hour ?? 0) * 60 * 60
            let minute = (components.minute ?? 0) * 60
            
            let prediction = try model.prediction(wake: Double(hour + minute), estimatedSleep: sleepAmount, coffee: Double(coffeeAmount))
            
            let sleepTime = wakeUp - prediction.actualSleep
            alertTitle = "Your ideal bedtime is..."
            alertMessage = sleepTime.formatted(date: .omitted, time: .shortened)
        } catch {
            alertTitle = "Error"
            alertMessage = "Sorry, there was a problem calculating your bedtime"
        }
        showingAlert = true
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
