
import UIKit

struct AlertModel {
    var title: String
    var text: String
    var buttonText: String
    var completion: () -> Void
  
    init(title: String, text: String, buttonText: String, completion: @escaping () -> Void) {
        self.title = title
        self.text = text
        self.buttonText = buttonText
        self.completion = completion
    }
}
