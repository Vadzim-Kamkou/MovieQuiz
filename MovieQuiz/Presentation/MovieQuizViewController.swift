import UIKit
import Foundation

// sprint_05

final class MovieQuizViewController: UIViewController {
 
    // СТРУКТУРЫ
    
    // вопрос
    struct QuizQuestion {
      let image: String         // строка с названием фильма, совпадает с названием картинки в Assets
      let text: String          // строка с вопросом о рейтинге фильма
      let correctAnswer: Bool   // правильный ответ на вопрос true-false
    }
    
    // вью модель для состояния "Вопрос показан"
    struct QuizStepViewModel {
      let image: UIImage            // картинка с афишей фильма
      let question: String          // вопрос о рейтинге квиза
      let questionNumber: String    // строка с порядковым номером этого вопроса (ex. "1/10")
    }
    
    // вью модель для состояния "Результат квиза"
    struct QuizResultsViewModel {
      let title: String             // строка с заголовком алерта
      let text: String              // строка с текстом о количестве набранных очков
      let buttonText: String        // текст для кнопки алерта
    }
    
    // ПЕРЕМЕННЫЕ

    @IBOutlet weak private var counterLabel: UILabel!
    @IBOutlet weak private var imageView: UIImageView!
    @IBOutlet weak private var textLabel: UILabel!
    @IBOutlet weak private var yesButton: UIButton!
    @IBOutlet weak private var noButton: UIButton!
    
    private var currentQuestionIndex = 0    // индекс текущего вопроса
    private var correctAnswers = 0          // cчётчик правильных ответов, начальное значение 0

    // массив вопросов
    private let questions: [QuizQuestion] = [
        QuizQuestion(image: "The Godfather", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
        QuizQuestion(image: "The Dark Knight", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
        QuizQuestion(image: "Kill Bill", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
        QuizQuestion(image: "The Avengers", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
        QuizQuestion(image: "Deadpool", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
        QuizQuestion(image: "The Green Knight", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
        QuizQuestion(image: "Old", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: false),
        QuizQuestion(image: "The Ice Age Adventures of Buck Wild", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: false),
        QuizQuestion(image: "Tesla", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: false),
        QuizQuestion(image: "Vivarium", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: false)
    ]
    
    // ФУНКЦИИ
    
    // модификации после загрузки приложения
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // выводим первый вопрос
        imageView.layer.masksToBounds = true // даём разрешение на рисование рамки
        imageView.layer.cornerRadius = 20 // радиус скругления углов рамки
        let currentQuestion = questions[currentQuestionIndex]
        let currentQuestionViewModel = convert(model: currentQuestion)
        show(quiz: currentQuestionViewModel)
    }
     
    // обрабатываем нажатие кнопки "Нет"
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        let currentQuestion = questions[currentQuestionIndex]
        let givenAnswer = false
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    // обрабатываем нажатие кнопки "Да"
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        let currentQuestion = questions[currentQuestionIndex]
        let givenAnswer = true
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    // конвертируем вопрос и возвращаем ViewModel
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        // создаем константу и вызываем конструктор
        let questionStep = QuizStepViewModel(
            // инициализируем картинку
            image: UIImage(named: model.image) ?? UIImage(),
            // забираем вопрос из моковых данных
            question: model.text,
            // высчитываем номер вопроса
            questionNumber: "\(currentQuestionIndex + 1)/\(questions.count)")
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
            self.showNextQuestionOrResults()
        }
    }
    
    // показываем следующий вопрос или алерт результата квиза
    private func showNextQuestionOrResults() {
        
        self.yesButton.isEnabled = true
        self.noButton.isEnabled = true
        imageView.layer.borderWidth = 0
        
        if currentQuestionIndex == questions.count - 1 {
            let quizResult = QuizResultsViewModel(
                title: "Этот раунд окончен!",
                text: "Ваш результат: \(correctAnswers)/\(questions.count)",
                buttonText: "Сыграть еще раз")
            
                showResult(quiz: quizResult)
        } else {
            currentQuestionIndex += 1
            
            let currentQuestion = questions[currentQuestionIndex]
            let currentQuestionViewModel = convert(model: currentQuestion)
            show(quiz: currentQuestionViewModel)
        }
    }
    
    // вывод на экран алерта результата квиза и начинаем квиз заново
    private func showResult(quiz result: QuizResultsViewModel) {

        let alert = UIAlertController(
            title: result.title,
            message: result.text,
            preferredStyle: .alert)
        
        let action = UIAlertAction(title: result.buttonText, style: .default) { _ in
            self.currentQuestionIndex = 0
            self.correctAnswers = 0
            
            // заново показываем первый вопрос
            let firstQuestion = self.questions[self.currentQuestionIndex]
            let viewModel = self.convert(model: firstQuestion)
            self.show(quiz: viewModel)
        }
        
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
}
