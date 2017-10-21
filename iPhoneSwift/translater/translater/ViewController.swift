//
//  ViewController.swift
//  translater
//
//  Created by Tomoya Arakawa on 2017/10/21.
//  Copyright © 2017年 Tomoya Arakawa. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBAction func goBack(_ segue:UIStoryboardSegue) {}
    
    @IBAction func goNext(_ sender:UIButton) {
        let next = storyboard!.instantiateViewController(withIdentifier: "translate")
        self.present(next,animated: true, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

