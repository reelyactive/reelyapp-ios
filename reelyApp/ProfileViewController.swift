// ProfileViewController.swift
//
// Copyright (c) 2015 Auth0 (http://auth0.com)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import UIKit
import CoreGraphics

class ProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var firstName: UITextField!
    @IBOutlet weak var lastName: UITextField!
    @IBOutlet weak var containerHeight: NSLayoutConstraint!
    @IBOutlet weak var editImageButton: UIButton!

    let userHandler = UserHandler();
    let imagePicker = UIImagePickerController()
    
    @IBAction func editButtonClicked(sender: AnyObject) {
        imagePicker.allowsEditing = false;
        imagePicker.sourceType = .PhotoLibrary;
        
        presentViewController(imagePicker, animated: true, completion: nil);
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            avatar.contentMode = .ScaleAspectFill;
            avatar.image = pickedImage;
            userHandler.setImage(pickedImage);
        }
        
        dismissViewControllerAnimated(true, completion: nil);
    }
    
    weak var currentField: UITextField?
    var keyboardFrame: CGRect?
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        imagePicker.delegate = self;
        
        self.avatar.layer.cornerRadius = 100
        self.avatar.layer.masksToBounds = true
        self.avatar.layer.borderWidth = 12;
        self.avatar.layer.borderColor = UIColor(red:0.22, green:0.55, blue:0.71, alpha:1.00).CGColor;

        updateUI()
        
        let center = NSNotificationCenter.defaultCenter()
        center.addObserver(self, selector: "keyboardShown:", name: UIKeyboardWillShowNotification, object: nil)
        center.addObserver(self, selector: "keyboardHidden:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func keyboardShown(notification: NSNotification) {
        let info = notification.userInfo!
        self.keyboardFrame = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        self.keyboardFrame = self.view.convertRect(self.keyboardFrame!, fromView: nil)
        self.containerHeight.constant = 600 + self.keyboardFrame!.size.height
        if let field = self.currentField {
            self.scrollToField(field, keyboardFrame: self.keyboardFrame!)
        }
    }
    
    func keyboardHidden(notification: NSNotification) {
        self.containerHeight.constant = 600
        self.keyboardFrame = nil
    }
    
    @IBAction func editingBegan(sender: AnyObject) {
        self.currentField = sender as? UITextField
        if let field = self.currentField, let frame = self.keyboardFrame {
            self.scrollToField(field, keyboardFrame: frame)
        }
    }
    
    @IBAction func editingEnded(sender: AnyObject) {
        self.currentField = nil
    }
    
    @IBAction func nextField(sender: AnyObject) {
        let field = sender as! UITextField
        _ = field.tag
        var nextTag = field.tag + 1
        if !(600...603 ~= nextTag) {
            nextTag = 600
        }
        if let next = self.view.viewWithTag(nextTag) as? UITextField, let frame = self.keyboardFrame {
            next.becomeFirstResponder()
            self.scrollToField(next, keyboardFrame: frame)
        }
    }
    
    @IBAction func saveProfile(sender: AnyObject) {
        hideKeyboard()
        userHandler.setGivenName(firstName.text!);
        userHandler.setFamilyName(lastName.text!);
        print("NAME", firstName.text, lastName.text)
        self.performSegueWithIdentifier("main", sender: self)
    }
    
    private func hideKeyboard() {
        self.currentField?.resignFirstResponder()
    }
    
    private func scrollToField(field: UITextField, keyboardFrame: CGRect) {
        let scrollOffset = self.offsetForFrame(field.frame, keyboardFrame: keyboardFrame)
        self.scrollView.setContentOffset(CGPoint(x: 0, y: scrollOffset), animated: true)
    }
    
    private func offsetForFrame(frame: CGRect, keyboardFrame: CGRect) -> CGFloat {
        let bottom = frame.origin.y + frame.size.height
        let offset = bottom - keyboardFrame.origin.y
        if offset < 0 {
            return 0
        }
        return offset
    }
    
    private func updateUI() {
        self.avatar.contentMode = .ScaleAspectFill;
        self.avatar.image = self.userHandler.getImage();

        self.firstName.text = self.userHandler.getGivenName();
        self.lastName.text = self.userHandler.getFamilyName();
    }
}
