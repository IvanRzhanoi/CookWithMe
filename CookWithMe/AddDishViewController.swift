//
//  AddDishViewController.swift
//  CookWithMe
//
//  Created by Ivan Rzhanoi on 20/09/2018.
//  Copyright © 2018 Ivan Rzhanoi. All rights reserved.
//

import UIKit
import FirebaseStorage

class AddDishViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var dishImageView: UIImageView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var tagsTextField: UITextField!
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
        var imageReference = storageReference.child("images/\(dishName).jpeg")
        _ = imageReference.putData(data, metadata: nil, completion: { (metadata, error) in
            guard let metadata = metadata else {
                self.displayAlertMessage(messageToDisplay: error as! String)
                return
            }
            
            // URL for the saved image
            storageReference.downloadURL(completion: { (url, error) in
                guard let downloadURL = url else {
                    self.displayAlertMessage(messageToDisplay: "Couldn't properly load the image")
                    return
                }
                
                self.setDish()
            })
        })
        
        
        
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
                            //                            print(error!)
                            self.displayAlertMessage(messageToDisplay: error as! String)
                            return
                        }
                        if url != nil {
                            self.setupUser(imageURL: url!.absoluteString)
                            self.dismiss(animated: true, completion: nil)
                        }
                    })
                }
            }
        }
    }
    
    func uploadDish() {
        
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
