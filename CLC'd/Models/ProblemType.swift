//
//  ProblemType.swift
//  CLC'd
//
//  Created by Peidong Chen on 5/21/25.
//
enum ProblemType: String, CaseIterable, Codable, Identifiable {
    case daily = "Daily"
    case easy = "Easy"
    case medium = "Medium"
    case hard = "Hard"
    case random = "Random"
    
    var id: String { rawValue }
    
    var apiDifficulty: String? {
        switch self {
        case .easy: return "EASY"
        case .medium: return "MEDIUM"
        case .hard: return "HARD"
        default: return nil
        }
    }
}
