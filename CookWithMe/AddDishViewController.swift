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

class AddDishViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var dishImageView: UIImageView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var tagsTextField: UITextField!
    @IBOutlet weak var diffultyTextField: UITextField!
    @IBOutlet weak var ingredientsTextView: UITextView!
    @IBOutlet weak var instructionsTextView: UITextView!
    
//    var userUID: String!
//    var emailText: String!
//    var passwordText: String!
    var imagePicker: UIImagePickerController!
//    var username: String!


    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
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
        
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    func uploadImage() {
        
        guard let dishName = nameTextField.text else {
            displayAlertMessage(messageToDisplay: "Please give your dish a name")
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
        
        guard let difficulty = Int(diffultyTextField.text!) else {
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
        
        let storage = Storage.storage()
        var data = Data()
        data = UIImageJPEGRepresentation(image, 0.4)!
        
        // Creating storage reference for the storage service
        let storageReference = storage.reference()
        let imageReference = storageReference.child("images/\(dishName).jpeg")
        _ = imageReference.putData(data, metadata: nil, completion: { (metadata, error) in
            guard metadata != nil else {
                self.displayAlertMessage(messageToDisplay: error as! String)
                return
            }
            
            // Image Reference, URL for the saved image
            storageReference.downloadURL(completion: { (url, error) in
                guard let downloadURL = url else {
                    self.displayAlertMessage(messageToDisplay: "Couldn't properly load the image")
                    return
                }
                
                self.uploadDish(name: dishName, imageReference: downloadURL, tagsString: tagsUsed, difficulty: difficulty, ingredientsString: ingredientsUsed, instructions: instructionsUsed)
            })
        })
    }
    
    func uploadDish(name: String, imageReference: URL, tagsString: String, difficulty: Int, ingredientsString: String, instructions: String) {
        let collection = Firestore.firestore().collection("dishes")
        
        // Splitting
        let tags = tagsString.components(separatedBy: " ")
        let ingredients = ingredientsString.components(separatedBy: CharacterSet.newlines)
        
        
        let dish = Dish(name: name, imageReference: imageReference, tags: tags, difficulty: difficulty, averageRating: nil, ingredients: ingredients, instructions: instructions)
        
        collection.addDocument(data: dish.dictionary)
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
