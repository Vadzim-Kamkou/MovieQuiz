
import UIKit

final class MovieQuizPresenter:QuestionFactoryDelegate {
    
    var correctAnswers:Int = .zero
    let questionsAmount: Int = 10
    private var currentQuestionIndex:Int = .zero
    
    var currentQuestion: QuizQuestion?
    
    
    private var questionFactory: QuestionFactoryProtocol?
    private weak var viewController: MovieQuizViewController?
    
    
    init(viewController: MovieQuizViewController) {
        self.viewController = viewController
        
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
            
            // готовим данные для модели
            guard let statisticMessage:String = viewController.statisticService?.store(correct: correctAnswers, total: questionsAmount) else {return}
            
            let quizResult = AlertModel(
                title: "Этот раунд окончен!",
                text: statisticMessage,
                buttonText: "Сыграть еще раз",
                completion: viewController.restartQuiz)
            
            // передаем данные для модели
            viewController.alertPresenter?.showResult(result:quizResult)
            
        } else {
            self.switchToNextQuestion()
            self.questionFactory?.requestNextQuestion()
        }
        
        
    }
    
    
    
}
