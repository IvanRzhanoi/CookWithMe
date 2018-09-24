//
//  AddDishViewController.swift
//  CookWithMe
//
//  Created by Ivan Rzhanoi on 20/09/2018.
//  Copyright © 2018 Ivan Rzhanoi. All rights reserved.
//

import UIKit
import FirebaseFirestore
import FirebaseStorage
import SwiftKeychainWrapper

class AddDishViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate {
    
    @IBOutlet weak var dishImageView: UIImageView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var tagsTextField: UITextField!
    @IBOutlet weak var difficultyTextField: UITextField!
    @IBOutlet weak var ingredientsTextView: UITextView!
    @IBOutlet weak var instructionsTextView: UITextView!
    @IBOutlet weak var toolBarBottomConstraint: NSLayoutConstraint!
    
    let loadingView = UIView()
    let activityIndicator = UIActivityIndicatorView()
    let loadingLabel = UILabel()
    var imagePicker: UIImagePickerController!
    var difficultyPicker: UIPickerView!
    
    let difficultyPickerValues = ["1", "2", "3", "4", "5"]
    let ingredientsPlaceholder = "Add ingredients with new lines \nlike this"
    let instructionsPlaceholder = "Add instructions for preparing your meal\nwith new lines as well"

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        
        difficultyPicker = UIPickerView()
        difficultyPicker.dataSource = self
        difficultyPicker.delegate = self
        
        difficultyTextField.inputView = difficultyPicker
        difficultyTextField.text = difficultyPickerValues[0]
        
        ingredientsTextView.delegate = self
        instructionsTextView.delegate = self
        ingredientsTextView.text = ingredientsPlaceholder
        instructionsTextView.text = instructionsPlaceholder
        ingredientsTextView.textColor = UIColor.lightGray
        instructionsTextView.textColor = UIColor.lightGray
        
        ingredientsTextView.selectedTextRange = ingredientsTextView.textRange(from: ingredientsTextView.beginningOfDocument, to: ingredientsTextView.beginningOfDocument)
        instructionsTextView.selectedTextRange = instructionsTextView.textRange(from: instructionsTextView.beginningOfDocument, to: instructionsTextView.beginningOfDocument)
        
        NotificationCenter.default.addObserver(self, selector: #selector(AddDishViewController.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(AddDishViewController.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        self.ingredientsTextView.layer.borderColor = UIColor.lightGray.cgColor
        self.ingredientsTextView.layer.borderWidth = 0.3
        self.ingredientsTextView.layer.cornerRadius = 8
        self.instructionsTextView.layer.borderColor = UIColor.lightGray.cgColor
        self.instructionsTextView.layer.borderWidth = 0.3
        self.instructionsTextView.layer.cornerRadius = 8
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
            dishImageView.image = image
        } else {
            print("Image wasn't selected")
            displayAlertMessage(messageToDisplay: "Image was not selected")
        }
        
        picker.dismiss(animated: true, completion: nil)
        guard let image = info[UIImagePickerControllerEditedImage] as? UIImage else {
            print("No image found")
            return
        }
        
        // print out the image size as a test
        print(image.size)
        
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return difficultyPickerValues.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return difficultyPickerValues[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int){
        difficultyTextField.text = difficultyPickerValues[row]
        self.view.endEditing(true)
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        // Combine the textView text and the replacement text to
        // create the updated text string
        let currentText:String = textView.text
        let updatedText = (currentText as NSString).replacingCharacters(in: range, with: text)
        
        // If updated text view will be empty, add the placeholder
        // and set the cursor to the beginning of the text view
        if updatedText.isEmpty {
            if textView == ingredientsTextView {
                textView.text = ingredientsPlaceholder
            } else {
                textView.text = instructionsPlaceholder
            }
            
            textView.textColor = UIColor.lightGray
            textView.selectedTextRange = textView.textRange(from: textView.beginningOfDocument, to: textView.beginningOfDocument)
        }
            
            // Else if the text view's placeholder is showing and the
            // length of the replacement string is greater than 0, set
            // the text color to black then set its text to the
            // replacement string
        else if textView.textColor == UIColor.lightGray && !text.isEmpty {
            textView.textColor = UIColor.black
            textView.text = text
        }
            
            // For every other case, the text should change with the usual
            // behavior...
        else {
            return true
        }
        
        // ...otherwise return false since the updates have already
        // been made
        return false
    }
    
    func textViewDidChangeSelection(_ textView: UITextView) {
        if self.view.window != nil {
            if textView.textColor == UIColor.lightGray {
                textView.selectedTextRange = textView.textRange(from: textView.beginningOfDocument, to: textView.beginningOfDocument)
            }
        }
    }

    @objc func keyboardWillShow(notify: NSNotification) {
        if let userInfo = notify.userInfo {
            let keyboardFrame = userInfo[UIKeyboardFrameEndUserInfoKey] as? CGRect

            UIView.animate(withDuration: 5) {
                self.toolBarBottomConstraint.constant = -keyboardFrame!.height
                self.view.layoutIfNeeded()
            }
        }
    }

    @objc func keyboardWillHide(notify: NSNotification) {
        UIView.animate(withDuration: 5) {
            self.toolBarBottomConstraint.constant = 0
            self.view.layoutIfNeeded()
        }
    }
    
    func uploadImage() {
        guard let dishName = nameTextField.text else {
            displayAlertMessage(messageToDisplay: "Please give your dish a name")
            return
        }
        
        guard let uid = KeychainWrapper.standard.string(forKey: "uid") else {
            displayAlertMessage(messageToDisplay: "Couldn't get your user identification. Maybe you are not logged in")
            return
        }
        
        guard let image = dishImageView.image else {
            displayAlertMessage(messageToDisplay: "An image needs to be selected")
            return
        }
        
        guard let tagsUsed = tagsTextField.text else {
            displayAlertMessage(messageToDisplay: "Please give your dish a category or two")
            return
        }
        
        guard let difficulty = Int(difficultyTextField.text!) else {
            displayAlertMessage(messageToDisplay: "Please tell how difficult is your dish")
            return
        }
        
        guard let ingredientsUsed = ingredientsTextView.text else {
            displayAlertMessage(messageToDisplay: "Please list the ingredients")
            return
        }
        
        guard let instructionsUsed = instructionsTextView.text else {
            displayAlertMessage(messageToDisplay: "Please tell, how the dish is supposed to be cooked")
            return
        }
        
        if let imageData = UIImageJPEGRepresentation(image, 0.4) {
            let imageUID = NSUUID().uuidString
            let metadata = StorageMetadata()
            metadata.contentType = "image/jpeg"
            let storageItem = Storage.storage().reference().child(imageUID)
            storageItem.putData(imageData, metadata: metadata) { (metadata, error) in
                if error != nil {
                    print("did not upload image")
                    self.displayAlertMessage(messageToDisplay: "Did not upload the image")
                } else {
                    print("uploaded")
                    storageItem.downloadURL(completion: { (url, error) in
                        if error != nil {
                            print(error!)
//                            self.displayAlertMessage(messageToDisplay: error as! String)
                            self.displayAlertMessage(messageToDisplay: "Couldn't properly load the image")
                            return
                        }
                        if url != nil {
//                            self.setupUser(imageURL: url!.absoluteString)
                            self.uploadDish(name: dishName, posterUID: uid, imageReference: (url?.absoluteString)!, tagsString: tagsUsed, difficulty: difficulty, ingredientsString: ingredientsUsed, instructionsString: instructionsUsed)
                        }
                    })
                }
            }
        }
    }
    
    func uploadDish(name: String, posterUID: String, imageReference: String, tagsString: String, difficulty: Int, ingredientsString: String, instructionsString: String) {
        let collection = Firestore.firestore().collection("dishes")
        
        // Splitting
//        let tags = tagsString.components(separatedBy: " ")
        let tags = tagsString.hashtags()
        let ingredients = ingredientsString.components(separatedBy: CharacterSet.newlines)
        let instructions = instructionsString.components(separatedBy: CharacterSet.newlines)
        
        let dish = Dish(name: name, posterUID: posterUID, imageReference: imageReference, tags: tags, difficulty: difficulty, ratings: nil, favorites: nil, ingredients: ingredients, instructions: instructions)
        
        collection.addDocument(data: dish.dictionary)
        self.navigationController?.popViewController(animated: true)
    }
    
    func displayAlertMessage(messageToDisplay: String) {
        let alertController = UIAlertController(title: "Alert", message: messageToDisplay, preferredStyle: .alert)
        
        let OKAction = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction!) in
            // Code in this block will trigger when OK button tapped.
            print("Ok button tapped");
        }
        
        alertController.addAction(OKAction)
        self.present(alertController, animated: true, completion:nil)
    }

    @IBAction func takePhoto(_ sender: Any) {
        let vc = UIImagePickerController()
        vc.sourceType = .camera
        vc.allowsEditing = true
        vc.delegate = self
        present(vc, animated: true)
    }
    
    @IBAction func pickPhoto(_ sender: Any) {
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func dismissKeyboard(_ sender: Any) {
        view.endEditing(true)
    }
    
    @IBAction func uploadDish(_ sender: Any) {
        // TODO: Rename code flow to more reasonable
        uploadImage()
    }
}

extension String {
    func hashtags() -> [String] {
        if let regex = try? NSRegularExpression(pattern: "#[a-z0-9]+", options: .caseInsensitive) {
            let string = self as NSString
            return regex.matches(in: self, options: [], range: NSRange(location: 0, length: string.length)).map {
                string.substring(with: $0.range).replacingOccurrences(of: "#", with: "").lowercased()
            }
        }
        return []
    }
}
