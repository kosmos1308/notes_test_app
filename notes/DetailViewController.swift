//
//  DetailViewController.swift
//  notes
//
//  Created by pavel on 27.09.21.
//


import UIKit

class DetailViewController: UIViewController {
    
    public var completion: ((String, String) -> Void)?
    public var note: String = ""
    
    private let textView = UITextView()
    private let alert = UIAlertController()
    private let textEditingView = UIView()
    private var sizePickerView = UIPickerView()
    private var segmentControl = UISegmentedControl()

    var heightKeyboard = CGFloat()
    var fontAttr = UIFont(name: "Avenir", size: 25)
    var fontColorAttr = UIColor.white
    var sizeLetter: CGFloat = 25
    var nameFont: String = String()
    
    let defaults = UserDefaults.standard
    var index: Int = 1000
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        createTextView()
        createSaveButton()
        addObserverOnNotification()
        createSegmentControl()
        createSizePickerView() //create pickerView (size font)
        sizePickerView.selectRow(29, inComponent: 0, animated: false)
        view.backgroundColor = .black
        
//        defaults.string(forKey: "title")
//        defaults.string(forKey: "text")
    }
    
    
    //MARK: - create "Save" button
    func createSaveButton() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(clickSaveButton))
        navigationController?.navigationBar.tintColor = .systemOrange
    }
    
    
    //MARK: - click "Save" button
    @objc func clickSaveButton() {
        showAlert()
    }
    
    
    //MARK: - create TextView
    func createTextView() {
        let heightNavBar = navigationController?.navigationBar.bounds.size.height //height navigationBar
        guard let height = heightNavBar else {return}

        textView.frame = CGRect(x: 0, y: Int(height + 60), width: Int(view.bounds.size.width), height: Int(view.bounds.height - height - 90))
        textView.backgroundColor = #colorLiteral(red: 0.1726491451, green: 0.1723766625, blue: 0.1811300516, alpha: 1)
        textView.textColor = .white
        textView.font = UIFont(name: "Avenir Heavy", size: 25)
        textView.contentInset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        textView.text = note //text in textView
        textView.layer.cornerRadius = 15
        textView.layer.masksToBounds = true
        textView.delegate = self
        view.addSubview(textView)
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        textView.resignFirstResponder()
    }
    
    
    //MARK: - Notification add observer(hide and show keyboard) + action
    func addObserverOnNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(adjustScrollView), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(adjustScrollView), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    
    @objc func adjustScrollView(notification: Notification) {
        guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else {return}
        let keyboardScreenEndFrame = keyboardValue.cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, to: view.window)
        heightKeyboard = keyboardViewEndFrame.height //height keyboard
        
        if notification.name == UIResponder.keyboardWillHideNotification {
            textView.contentInset = .zero
            hideTextEditingView() // hide textEditingview
        } else {
            textView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height - view.safeAreaInsets.bottom + 32, right: 0)
            showTextEditingView() // show textEditingview
        }
        textView.scrollIndicatorInsets = textView.contentInset
    }
    
    
    //MARK: - show and hide textEditengView when show or hide keyboard
    func showTextEditingView() {
        textEditingView.isHidden = false
        textEditingView.frame = CGRect(x: 0, y: Int(view.bounds.height - heightKeyboard - 32), width: Int(view.bounds.width), height: 32)
        textEditingView.backgroundColor = #colorLiteral(red: 0.8784784675, green: 0.8782911897, blue: 0.8869490623, alpha: 1)
        view.addSubview(textEditingView)
    }
    
    
    func hideTextEditingView() {
        textEditingView.isHidden = true
    }
    
    
    //MARK: - create sizePickerView
    func createSizePickerView() {
        sizePickerView = UIPickerView(frame: CGRect(x: Int(view.bounds.width/5 * 4 + 1), y: 0, width: Int(view.bounds.width/5), height: 38))
        sizePickerView.backgroundColor = #colorLiteral(red: 0.8784784675, green: 0.8782911897, blue: 0.8869490623, alpha: 1)
        sizePickerView.delegate = self
        sizePickerView.dataSource = self
        textEditingView.addSubview(sizePickerView)
    }
    
    
    //MARK: - create segment control (change size font)
    func createSegmentControl() {
        let index = ["   BOLD   ", "   HEAVY  ", "   LIGHT  ", "  OBLIQUE "]
        segmentControl.frame = CGRect(x: 0, y: Int(textEditingView.bounds.height - 32), width: Int(view.bounds.width/5 * 4), height: Int(textEditingView.bounds.height))
        segmentControl = UISegmentedControl(items: index)
        segmentControl.backgroundColor = .clear
        segmentControl.selectedSegmentIndex = 1
        textEditingView.addSubview(segmentControl)
    }
    
    
    //MARK: - show alert and popToRootViewController
    func showAlert() {
        let alert = UIAlertController(title: "Name note", message: "Enter name note, please", preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = "Name note"
        }
        let ok = UIAlertAction(title: "OK", style: .default) { [self] action in
            guard let textFiedText = alert.textFields?.first?.text else {return}
            if textFiedText.isEmpty == false {
                self.navigationController?.popToRootViewController(animated: true)
                if let text = self.textView.text {
                    self.completion?(textFiedText.uppercased(), text) //completion
                    self.defaults.set(textFiedText.uppercased(), forKey: "title\(index)") //save title
                    self.defaults.set(text, forKey: "text\(index)") //save text
                }
            } else {
                return
            }
        }
        alert.addAction(ok)
        present(alert, animated: true, completion: nil)
    }
}


//MARK: - UITextViewDelegate
extension DetailViewController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if segmentControl.selectedSegmentIndex == 0 && text.count > 0 {
            nameFont = "Avenir Black"
            fontAttr = UIFont(name: nameFont, size: sizeLetter)
            let attributedString = NSMutableAttributedString(string: text, attributes: [NSAttributedString.Key.font : self.fontAttr, NSAttributedString.Key.foregroundColor: self.fontColorAttr])
            self.textView.textStorage.insert(attributedString, at: range.location)
            let cursor = NSRange(location: self.textView.selectedRange.location+1, length: 0)
            textView.selectedRange = cursor
            return false
        } else if segmentControl.selectedSegmentIndex == 1 && text.count > 0 {
            fontColorAttr = .white
            nameFont = "Avenir Heavy"
            fontAttr = UIFont(name: nameFont, size: sizeLetter)
            let attributedString = NSMutableAttributedString(string: text, attributes: [NSAttributedString.Key.font : self.fontAttr, NSAttributedString.Key.foregroundColor: self.fontColorAttr])
            self.textView.textStorage.insert(attributedString, at: range.location)
            let cursor = NSRange(location: self.textView.selectedRange.location+1, length: 0)
            textView.selectedRange = cursor
            return false
        } else if segmentControl.selectedSegmentIndex == 2 && text.count > 0 {
            fontColorAttr = .white //white
            nameFont = "Avenir Light"
            fontAttr = UIFont(name: nameFont, size: sizeLetter)
            let attributedString = NSMutableAttributedString(string: text, attributes: [NSAttributedString.Key.font : self.fontAttr, NSAttributedString.Key.foregroundColor: self.fontColorAttr])
            self.textView.textStorage.insert(attributedString, at: range.location)
            let cursor = NSRange(location: self.textView.selectedRange.location+1, length: 0)
            textView.selectedRange = cursor
            return false
        } else if segmentControl.selectedSegmentIndex == 3 && text.count > 0 {
            fontColorAttr = .white //white
            nameFont = "Avenir Oblique"
            fontAttr = UIFont(name: nameFont, size: sizeLetter)
            let attributedString = NSMutableAttributedString(string: text, attributes: [NSAttributedString.Key.font : self.fontAttr, NSAttributedString.Key.foregroundColor: self.fontColorAttr])
            self.textView.textStorage.insert(attributedString, at: range.location)
            let cursor = NSRange(location: self.textView.selectedRange.location+1, length: 0)
            textView.selectedRange = cursor
            return false
        }
        return true
    }
}

//MARK: - UIPickerViewDelegate, UIPickerViewDataSource
extension DetailViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        return 73
    }
    
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        sizeLetter = CGFloat(row + 1)
    }
    
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let title = "\(row + 1)"
        
        return title
    }
}
