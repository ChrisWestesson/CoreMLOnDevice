//
//  ContentView.swift
//  CoreMLOnDevice
//
//  Created by ChristianWestesson on 2024-11-19.
//
import SwiftUI
import CoreML

struct ContentView: View {
    @State private var viewModel = ContentViewModel()

    var body: some View {
        ZStack {
            Color(.systemGray6).edgesIgnoringSafeArea(.all)
            VStack {
                headerSection
                pickerSection
                Spacer()
                predictionResult
            }
            .padding()
            .onAppear {
                viewModel.predictChanceToGraduate()
            }
            .onChange(of: viewModel.userInput) {
                viewModel.predictChanceToGraduate()
            }
        }
    }

    private var headerSection: some View {
        VStack {
            Text("Kommer du att lyckas?")
                .font(.title)
                .fontWeight(.bold)

            Text("Beräkna din chans att ta examen från YH")
                .font(.headline)
            
            Text("Ange kön, åldersgrupp och utbildningskategori")
        }
    }

    private var pickerSection: some View {
        VStack {
            Picker("Kön", selection: $viewModel.userInput.gender) {
                ForEach(ContentViewModel.Gender.allCases, id: \.self) { gender in
                    Text(gender.rawValue).tag(gender)
                }
            }
            .pickerStyle(.segmented)

            Picker("Åldersgrupp", selection: $viewModel.userInput.ageGroup) {
                ForEach(ContentViewModel.AgeGroup.allCases, id: \.self) { ageGroup in
                    Text(ageGroup.rawValue).tag(ageGroup)
                }
            }
            .pickerStyle(.wheel)

            Picker("Utbildningskategori", selection: $viewModel.userInput.educationType) {
                ForEach(ContentViewModel.EducationType.allCases, id: \.self) { educationType in
                    Text(educationType.rawValue).tag(educationType)
                }
            }
            .pickerStyle(.wheel)
            
            Text("\(viewModel.userInput.educationType.rawValue)")
                .font(.footnote)
                .foregroundColor(.gray)
        }
    }
    
    private var predictionResult: some View {
        VStack {
            switch viewModel.predictionState {
            case .waiting:
                Text("Beräknar...")
                    .foregroundColor(.gray)
            case .success(let rate):
                resultView(for: rate)
            case .failure(let error):
                Text(error)
                    .foregroundColor(.red)
                    .fontWeight(.bold)
            }
        }
    }
    
    private func resultView(for rate: Double) -> some View {
        VStack {
            Text("\(String(format: "%.2f", rate)) %")
                .font(.title)
                .fontWeight(.bold)
            
            Text("En \(viewModel.userInput.gender.rawValue) i åldersgruppen \(viewModel.userInput.ageGroup.rawValue) som studerar inom vald kategori på yrkeshögskola beräknas ha \(String(format: "%.2f", rate)) % chans att ta examen.")
            
            Text("*Beräkningen görs på statistik från SCB")
                .font(.footnote)
                .padding(.top)
        }
    }
}

#Preview {
    ContentView()
}
