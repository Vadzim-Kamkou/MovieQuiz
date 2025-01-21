import UIKit
import Foundation

// sprint_05

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate, AlertPresenterDelegate {
   
    // ПЕРЕМЕННЫЕ
    @IBOutlet weak private var counterLabel: UILabel!
    @IBOutlet weak private var imageView: UIImageView!
    @IBOutlet weak private var textLabel: UILabel!
    @IBOutlet weak private var yesButton: UIButton!
    @IBOutlet weak private var noButton: UIButton!
    
    private var currentQuestionIndex = 0    // индекс текущего вопроса
    private var correctAnswers = 0          // cчётчик правильных ответов, начальное значение 0

    private let questionsAmount: Int = 10
    private var questionFactory: QuestionFactoryProtocol?
    private var currentQuestion: QuizQuestion?
    
    private var alertPresenter: AlertPresenter?
    
    // MARK: - Lifecycle DidLoad
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        // выводим первый вопрос
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 20
        
        let questionFactory = QuestionFactory()
        questionFactory.delegate = self
        self.questionFactory = questionFactory
        questionFactory.requestNextQuestion()
  
    }
    
    // MARK: - QuestionFactoryDelegate
    func didReceiveNextQuestion(question: QuizQuestion?) {
        
        guard let question = question else {
            return
        }

        currentQuestion = question
        let viewModel = convert(model: question)
        
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
        }
    }
    
    // MARK: - ActionPresenterDelegate
    func didReceiveResultView(alertResult: UIAlertController, alertAction: UIAlertAction) {
        
        self.present(alertResult, animated: true, completion: nil)
    }
    
    
// MARK: - Actions
    // обрабатываем нажатие кнопки "Нет"
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        
        guard let currentQuestion = currentQuestion else {
            return
        }
        
        let givenAnswer = false
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    // обрабатываем нажатие кнопки "Да"
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        
        guard let currentQuestion = currentQuestion else {
            return
        }
        
        let givenAnswer = true
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
// MARK: - Private Functions
    
    // конвертируем вопрос и возвращаем ViewModel
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        // создаем константу и вызываем конструктор
        let questionStep = QuizStepViewModel(
            // инициализируем картинку
            image: UIImage(named: model.image) ?? UIImage(),
            // забираем вопрос из моковых данных
            question: model.text,
            // высчитываем номер вопроса
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
        return questionStep
    }
    
    // вывод на экран вопроса
    private func show(quiz step: QuizStepViewModel) {
        counterLabel.text = step.questionNumber
        imageView.image = step.image
        textLabel.text = step.question
    }
    
    // обрабатываем ответ пользователя
    private func showAnswerResult(isCorrect: Bool) {

        imageView.layer.borderWidth = 8 // толщина рамки, повторно устанавливаем, т.к. при переключении вопросов showNextQuestionOrResults убираем рамку через borderWidth = 0
        
        if isCorrect {
            imageView.layer.borderColor = UIColor.ypGreen.cgColor
            correctAnswers += 1
        } else {
            imageView.layer.borderColor = UIColor.ypRed.cgColor
        }
        
        // блокируем кнопки ответов, до показа следующего вопроса
        self.yesButton.isEnabled = false
        self.noButton.isEnabled = false
        
        // запускаем задачу через 1 секунду c помощью диспетчера задач
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            [weak self] in
            guard let self = self else { return }
            self.showNextQuestionOrResults()
        }
    }
    
    // показываем следующий вопрос или алерт результата квиза
    private func showNextQuestionOrResults() {
        
        self.yesButton.isEnabled = true
        self.noButton.isEnabled = true
        imageView.layer.borderWidth = 0
        
        if currentQuestionIndex == questionsAmount - 1 {
            
            // готовим AlertPresenter
            let alertPresenter = AlertPresenter()
            alertPresenter.delegate = self
            self.alertPresenter = alertPresenter
            
            // готовим данные для модели
            let text = correctAnswers == questionsAmount 
                ? "Поздравляем, вы ответили на 10 из 10!"
                : "Вы ответили на \(correctAnswers) из 10, попробуйте ещё раз!"
            
            let quizResult = AlertModel(
                title: "Этот раунд окончен!",
                text: text,
                buttonText: "Сыграть еще раз", 
                completion: restartQuiz)
            
            // передаем данные для модели
            alertPresenter.showResult(result:quizResult)
         
        } else {
            currentQuestionIndex += 1
            questionFactory?.requestNextQuestion()
        }
    }
    
    private func restartQuiz () {
        self.currentQuestionIndex = 0
        self.correctAnswers = 0
        self.questionFactory?.requestNextQuestion()
    }
}
