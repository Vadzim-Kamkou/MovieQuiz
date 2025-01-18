
import UIKit

class AlertPresenter {
    
    weak var delegate:AlertPresenterDelegate?
    
    func showResult (result:AlertModel) {
 
        // описываем вид алерта, здесь только заголовок и сообщение + стиль алерта
        let alertResult = UIAlertController(
            title: result.title,
            message: result.text,
            preferredStyle: .alert)
        
        // описываем действие по кнопке алерта, здесь
        let action = UIAlertAction(title: result.buttonText, style: .default) {_ in  result.completion()}
        
        alertResult.addAction(action)
        
        delegate?.didReceiveResultView(alertResult: alertResult, alertAction: action)
     
    }
}

