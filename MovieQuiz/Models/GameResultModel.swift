//
//  GameResultModel.swift
//  MovieQuiz
//
//  Created by Vadzim on 21.01.25.
//

import Foundation

struct GameResult {
    let correct: Int
    let total: Int
    let date: Date
    
    func isBetterThan (_ another: GameResult) -> Bool {
        correct > another.correct
    }
}
