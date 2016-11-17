//
//  LoginViewController.swift
//  FireLocationTracker
//
//  Created by Lawrence Martin on 2016-11-17.
//  Copyright © 2016 centennial. All rights reserved.
//

import Foundation
import UIKit
import FirebaseAuth


class LoginViewController: UIViewController {

    @IBOutlet weak var email_txt: UITextField!

    @IBOutlet weak var password_txt: UITextField!


    @IBAction func signUp_btn(sender: AnyObject) {
        let emailTextField = self.email_txt.text
        let passwordTextField = self.password_txt.text
        
        FIRAuth.auth()?.createUserWithEmail(emailTextField!, password: passwordTextField!, completion: { (user:FIRUser?, error:NSError?) in
            if error != nil {
                print(error?.description)
            }else{
                self.performSegueWithIdentifier("mapViewSegue", sender: self)
            }
        })
        
    }

    @IBAction func signIn_btn(sender: AnyObject) {
        
                let emailTextField = self.email_txt.text
                let passwordTextField = self.password_txt.text
        
                FIRAuth.auth()?.signInWithEmail(emailTextField!, password: passwordTextField!, completion: { (user:FIRUser?, error:NSError?) in
                    if error != nil {
                        print(error?.description)
                    }else{
                        self.performSegueWithIdentifier("mapViewSegue", sender: self)
                    }
                    
                })
        
    }

}