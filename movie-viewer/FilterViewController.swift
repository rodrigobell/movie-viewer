//
//  FilterViewController.swift
//  movie-viewer
//
//  Created by Rodrigo Bell on 2/7/17.
//  Copyright © 2017 Rodrigo Bell. All rights reserved.
//

import UIKit

class FilterViewController: UIViewController, UINavigationControllerDelegate {
    
    var genreIds: String!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.delegate = self
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        if let controller = viewController as? MoviesViewController {
            genreIds = "16"
            controller.genreIds = genreIds
        }
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
