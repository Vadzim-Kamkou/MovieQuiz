
import UIKit

protocol AlertPresenterDelegate: AnyObject {
    func didReceiveResultView (alertResult: UIAlertController, alertAction: UIAlertAction)
}
