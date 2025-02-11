
import UIKit

final class MovieQuizPresenter:QuestionFactoryDelegate {
    
    var correctAnswers:Int = .zero
    let questionsAmount: Int = 10
    private var currentQuestionIndex:Int = .zero
    
    var currentQuestion: QuizQuestion?
    
    private let statisticService: StatisticServiceProtocol!
    private var questionFactory: QuestionFactoryProtocol?
    private weak var viewController: MovieQuizViewController?
    
    
    init(viewController: MovieQuizViewController) {
        self.viewController = viewController
        
        statisticService = StatisticService()
        
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        questionFactory?.loadData()
        viewController.showLoadingIndicator()
    }
    
    // MARK: - QuestionFactoryDelegate
    
    func didLoadDataFromServer() {
        viewController?.hideLoadingIndicator()
        questionFactory?.requestNextQuestion()
    }
    
    func didFailToLoadData(with error: Error) {
        let message = error.localizedDescription
        viewController?.showNetworkError(message: message)
    }
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        
        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.show(quiz: viewModel)
        }
    }
    
    // обрабатываем нажатие кнопки "Нет"
    func noButtonClicked() {
        didAnswer(isYes: false)
    }
    
    func yesButtonClicked() {
        didAnswer(isYes: true)
    }
    
    func didAnswer(isYes: Bool) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        let givenAnswer = isYes
        viewController?.showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    func didCorrectAnswer(isCorrect: Bool) {
        if isCorrect {
            correctAnswers += 1
        }
    }
    
    func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }
    
    func restartGame() {
        currentQuestionIndex = 0
        correctAnswers = 0
        questionFactory?.requestNextQuestion()
    }
    
    func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
    
    
    // конвертируем вопрос и возвращаем ViewModel
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        return QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
    }
    
    func showNextQuestionOrResults() {
        
        if self.isLastQuestion() {
            
            guard let viewController else {
                return print("showNextQuestionOrResults Guard")
            }
            // сохраняем статистику
            viewController.statisticService?.store(correct: correctAnswers, total: questionsAmount)
            
            // готовим данные для модели
            let message = makeResultsMessage()
            
            let quizResult = AlertModel(
                title: "Этот раунд окончен!",
                text: message,
                buttonText: "Сыграть еще раз",
                completion: viewController.restartQuiz)
            
            // передаем данные для модели
            viewController.alertPresenter?.showResult(result:quizResult)
            
        } else {
            self.switchToNextQuestion()
            self.questionFactory?.requestNextQuestion()
        }
        
        
    }
    
    func makeResultsMessage() -> String {
        
        //statisticService.store(correct: correctAnswers, total: questionsAmount)
        

        let resultText: String = "Ваш результат: \(correctAnswers)/\(questionsAmount)"
        let countGameText: String = "Количество сыгранных квизов: \(statisticService.gamesCount)"
        let bestScoreText: String = "Рекорд: \(statisticService.bestGame.correct)/\(statisticService.bestGame.total) (\(statisticService.bestGame.date.dateTimeString))"
        let middleScoreText: String = String(format: "Средняя точность: %.2f", statisticService.totalAccuracy*100) + "%"

        let resultMessage:String = [resultText, countGameText, bestScoreText, middleScoreText].joined(separator: "\n")
        return resultMessage
 
    }
    
    
    
}
