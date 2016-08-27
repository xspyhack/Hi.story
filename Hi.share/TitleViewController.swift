//
//  TitleViewController.swift
//  Hi.story
//
//  Created by bl4ckra1sond3tre on 6/19/16.
//  Copyright © 2016 bl4ckra1sond3tre. All rights reserved.
//

import UIKit

class TitleViewController: UIViewController {
    
    @IBOutlet weak var titleTextField: UITextField!
    var pickAction: ((title: String) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        title = "Input Title"
        view.backgroundColor = UIColor.clearColor()
        titleTextField.backgroundColor = UIColor.clearColor()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        titleTextField.becomeFirstResponder()
        preferredContentSize = CGSize(width: view.bounds.width, height: 100.0)
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        if let title = titleTextField.text where !title.isEmpty {
            pickAction?(title: title)
        }
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesBegan(touches, withEvent: event)
        
        view.endEditing(true)
    }

}

extension TitleViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
