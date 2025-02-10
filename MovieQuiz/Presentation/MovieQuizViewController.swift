import UIKit

final class MovieQuizViewController:UIViewController,
                                    QuestionFactoryDelegate,
                                    AlertPresenterDelegate {
    
    // MARK: - @IBOutlet
    @IBOutlet weak private var counterLabel: UILabel!
    @IBOutlet weak private var imageView: UIImageView!
    @IBOutlet weak private var textLabel: UILabel!
    @IBOutlet weak private var yesButton: UIButton!
    @IBOutlet weak private var noButton: UIButton!
    @IBOutlet weak private var activityIndicator: UIActivityIndicatorView!
    
    private let presenter = MovieQuizPresenter()
    
    var correctAnswers:Int = .zero
    
    var questionFactory: QuestionFactoryProtocol?
    //private var currentQuestion: QuizQuestion?
    
    weak var alertPresenter: AlertPresenter?
    
    var statisticService: StatisticServiceProtocol?
    
    private var resultMessage: String = ""
    
    
    // MARK: - Lifecycle DidLoad
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        presenter.viewController = self
        
        // выводим первый вопрос
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 20
        
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        
        // инициируем статистику
        statisticService = StatisticService()
        
        showLoadingIndicator()
        questionFactory?.loadData()
    }
    
    // MARK: - QuestionFactoryDelegate
    func didReceiveNextQuestion(question: QuizQuestion?) {
        presenter.didReceiveNextQuestion(question: question)
    }
    
    func didLoadDataFromServer() {
        activityIndicator.isHidden = true
        questionFactory?.requestNextQuestion()
    }
    
    func didFailToLoadData(with error: Error) {
        showNetworkError(message: error.localizedDescription)
    }
    
    // MARK: - ActionPresenterDelegate
    func didReceiveResultView(alertResult: UIAlertController, alertAction: UIAlertAction) {
        self.present(alertResult, animated: true, completion: nil)
    }
    // MARK: - Actions
    @IBAction func noButtonClicked(_ sender: UIButton) {
        presenter.noButtonClicked()
    }
    
    // обрабатываем нажатие кнопки "Да"
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        presenter.yesButtonClicked()
    }
    
    // MARK: - Private Functions
    
    // вывод на экран вопроса
    func show(quiz step: QuizStepViewModel) {
        counterLabel.text = step.questionNumber
        imageView.image = step.image
        textLabel.text = step.question
    }
    
    // обрабатываем ответ пользователя
    func showAnswerResult(isCorrect: Bool) {
        
        // толщина рамки, повторно устанавливаем, т.к. при переключении вопросов showNextQuestionOrResults убираем рамку через borderWidth = 0
        imageView.layer.borderWidth = 8
        
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
            guard let self else { return }
            
            self.prepareToNextQuestionOrResults()
        }
    }
    
    // показываем следующий вопрос или алерт результата квиза
    func prepareToNextQuestionOrResults() {
        
        self.yesButton.isEnabled = true
        self.noButton.isEnabled = true
        imageView.layer.borderWidth = 0
        
        // готовим AlertPresenter
        let alertPresenter = AlertPresenter()
        alertPresenter.delegate = self
        self.alertPresenter = alertPresenter

        presenter.showNextQuestionOrResults()
         
    }
    
    func restartQuiz () {
        self.presenter.resetQuestionIndex()
        self.correctAnswers = 0
        self.questionFactory?.requestNextQuestion()
    }
    
    // показываем индикатор загрузки данных
    private func showLoadingIndicator() {
        activityIndicator.isHidden = false // говорим, что индикатор загрузки не скрыт
        activityIndicator.startAnimating() // включаем анимацию
        
    }
    
    // скрываем индикатор загрузки данных
    private func hideLoadingIndicator() {
        activityIndicator.isHidden = true
    }
    
    private func showNetworkError(message: String) {
        hideLoadingIndicator()
        let model = AlertModel(title: "Ошибка",
                               text: message,
                               buttonText: "Попробовать еще раз") { [weak self] in
            guard let self else { return }
            self.presenter.resetQuestionIndex()
            self.correctAnswers = 0
            self.questionFactory?.requestNextQuestion()
            
        }
        let alertPresenter = AlertPresenter()
        alertPresenter.delegate = self
        self.alertPresenter = alertPresenter
        alertPresenter.showResult(result:model)
    }
    
}
