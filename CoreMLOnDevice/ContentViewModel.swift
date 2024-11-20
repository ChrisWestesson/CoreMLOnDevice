//
//  ContentViewModel.swift
//  CoreMLOnDevice
//
//  Created by ChristianWestesson on 2024-11-20.
//


import SwiftUI
import CoreML

@Observable
@MainActor
class ContentViewModel {
    var userInput = UserInput()
    var predictionState: PredictionState = .waiting

    private var model: ChanceToGraduateModel?

    init() {
        loadModel()
    }
    
    private func loadModel() {
        do {
            model = try ChanceToGraduateModel(configuration: MLModelConfiguration())
        } catch {
            updateState(with: .failure(PredictionError.modelInitializationFailed.userMessage))
        }
    }


    private func updateState(with newState: PredictionState) {
            withAnimation {
                self.predictionState = newState
            }
    }

    func predictChanceToGraduate() {
        if model == nil {
            loadModel()
        }

        guard let model = model else {
            updateState(with: .failure(PredictionError.modelInitializationFailed.userMessage))
            return
        }

        do {
            let modelInput = ChanceToGraduateModelInput(
                Gender: userInput.gender.rawValue,
                EducationType: userInput.educationType.rawValue,
                AgeGroup: userInput.ageGroup.rawValue
            )

            let prediction = try model.prediction(input: modelInput)
            updateState(with: .success(prediction.CompletionRate))

        } catch {
            updateState(with: .failure(PredictionError.predictionFailed.userMessage))
        }
    }
}

extension ContentViewModel {
    struct UserInput: Equatable {
        var gender: Gender = .female
        var educationType: EducationType = .dataIT
        var ageGroup: AgeGroup = .under24
    }
    
    enum PredictionState {
        case waiting
        case success(Double)
        case failure(String)
    }

    enum PredictionError: Error {
        case modelInitializationFailed
        case predictionFailed

        var userMessage: String {
            switch self {
            case .modelInitializationFailed:
                return "Modellen kunde inte laddas."
            case .predictionFailed:
                return "Beräkningen misslyckades."
            }
        }
    }

    enum Gender: String, CaseIterable {
        case female = "Kvinna"
        case male = "Man"
    }

    enum AgeGroup: String, CaseIterable {
        case under24 = "-24 år"
        case age25to29 = "25-29 år"
        case age30to34 = "30-34 år"
        case age35to39 = "35-39 år"
        case age40to44 = "40-44 år"
        case over45 = "45+ år"
    }

    enum EducationType: String, CaseIterable {
        case dataIT = "Data/It"
        case economy = "Ekonomi, administration och försäljning"
        case wellness = "Friskvård och kroppsvård"
        case hospitality = "Hotell, restaurang och turism"
        case healthcare = "Hälso- och sjukvård samt socialt arbete"
        case journalism = "Journalistik och information"
        case law = "Juridik"
        case cultureMediaDesign = "Kultur, media och design"
        case agriculture = "Lantbruk, djurvård, trädgård, skog och fiske"
        case education = "Pedagogik och undervisning"
        case construction = "Samhällsbyggnad och byggteknik"
        case security = "Säkerhetstjänster"
        case engineering = "Teknik och tillverkning"
        case transport = "Transporttjänster"
        case other = "Övrigt"
    }
}
