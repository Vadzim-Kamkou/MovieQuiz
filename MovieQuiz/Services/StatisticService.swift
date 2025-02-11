
import UIKit

final class StatisticService: StatisticServiceProtocol {
    
    private let storage: UserDefaults = .standard
 
    // ключи UserDefaults
    private enum Keys: String {
        case gamesCount = "gamesCount"
        case totalAccuracy = "totalAccuracy"
        case correct = "correctAnswersInBestGame"
        case total = "totalQuestionsInBestGame"
        case date = "bestGameDate"
    }
    
    var gamesCount: Int {
        get {
            storage.integer(forKey: Keys.gamesCount.rawValue)
        }
        set {
            storage.set(newValue, forKey: Keys.gamesCount.rawValue)
        }
    }
    
    var totalAccuracy: Double {
        get {
            storage.double(forKey: Keys.totalAccuracy.rawValue)
        }
        set {
            storage.set(newValue, forKey: Keys.totalAccuracy.rawValue)
        }
    }
    
    var bestGame: GameResult {
        get {
            let correctAnswers: Int = storage.integer(forKey: Keys.correct.rawValue)
            let totalQuestionsInBestGame:Int = storage.integer(forKey: Keys.total.rawValue)
            let bestGameDate = storage.object(forKey: Keys.date.rawValue) as? Date ?? Date()
            
            return GameResult(correct: correctAnswers, total: totalQuestionsInBestGame, date: bestGameDate)
        }
        set {
            storage.set(newValue.correct, forKey: Keys.correct.rawValue)
            storage.set(newValue.total, forKey: Keys.total.rawValue)
            storage.set(newValue.date, forKey: Keys.date.rawValue)
        }
    }
    
 
    func store(correct count: Int, total amount: Int){
    
        // обновляем количество игр
        gamesCount += 1
        
        // обновляем точность
        let savedCorrectAnswersSum:Double = self.totalAccuracy*Double(gamesCount - 1)*10
        let newCorrectAnswersSum:Double = savedCorrectAnswersSum + Double(count)
        let newTotalAccuracy:Double = (newCorrectAnswersSum/(Double(gamesCount)*10))
        totalAccuracy = newTotalAccuracy
        
        // сравниваем какая игра лучше, если текущая лучше - сохраняем
        let currentGameResult:GameResult = GameResult(correct: count, total: amount, date: Date.now)
        
        if currentGameResult.isBetterThan(self.bestGame) {
            storage.set(currentGameResult.correct, forKey: "correctAnswersInBestGame")
            storage.set(currentGameResult.total, forKey: "totalQuestionsInBestGame")
            storage.set(currentGameResult.date, forKey: "bestGameDate")
        }
    }
}
