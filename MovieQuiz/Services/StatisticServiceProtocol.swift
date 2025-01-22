//
//  StatisticServiceProtocol.swift
//  MovieQuiz
//
//  Created by Vadzim on 21.01.25.
//

import UIKit

protocol StatisticServiceProtocol {
    
    var gamesCount: Int { get }
    var bestGame: GameResult { get }
    var totalAccuracy: Double { get }
    
    func store(correct count: Int, total amount: Int) -> String
}
