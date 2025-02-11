
import UIKit

final class AlertPresenter {
    
    weak var delegate:AlertPresenterDelegate?
    
    func showResult(result:AlertModel) {
        // описываем вид алерта
        let alertResult = UIAlertController(
            title: result.title,
            message: result.text,
            preferredStyle: .alert)
        
        // описываем действие по кнопке алерта,
        let action = UIAlertAction(title: result.buttonText, style: .default) {_ in  result.completion()}
        
        alertResult.addAction(action)
        
        delegate?.didReceiveResultView(alertResult: alertResult, alertAction: action)
    }
}

