//
//  ViewController.swift
//  AlertViewController
//
//  Created by Michael Inger on 26/07/2017.
//  Copyright © 2017 stringCode ltd. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBAction func doStuffAction(_ sender: UIButton) {
        let style: UIAlertControllerStyle = sender.tag == 0 ? .alert : .actionSheet
        let alert = ImageAlertController(image: UIImage(named: "alert"), size: CGSize(width: 44, height: 44), title: "Tesing", message: "Wubba lubba dub dub", preferredStyle: style)

        if sender.tag > 0 {
            alert.popoverPresentationController?.sourceView = sender
            alert.popoverPresentationController?.sourceRect = sender.bounds
            alert.modalPresentationStyle = .popover
        }

        // Add actions
        let action = UIAlertAction(title: "Cancel", image: UIImage(named: "close"), style: .cancel, handler: nil)
        alert.addAction(UIAlertAction(title: "Default", style: .default, handler: nil))
        alert.addAction(UIAlertAction(title: "Destroy", style: .destructive, handler: nil))
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }

}

