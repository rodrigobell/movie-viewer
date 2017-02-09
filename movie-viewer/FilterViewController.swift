//
//  FilterViewController.swift
//  movie-viewer
//
//  Created by Rodrigo Bell on 2/7/17.
//  Copyright © 2017 Rodrigo Bell. All rights reserved.
//

import UIKit

class FilterViewController: UIViewController, UINavigationControllerDelegate, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!

    var genres: [NSDictionary]?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        
        loadGenresFromAPI()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let genres = genres {
            return genres.count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "filter-cell", for: indexPath)
        
        let genre = genres?[indexPath.row]
        
        if let name = genre?["name"] as? String {
            cell.textLabel?.text = name
        }
        
        return cell
    }

    func loadGenresFromAPI() {
        let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
        
        var url: URL!
        
        url = URL(string: "https://api.themoviedb.org/3/genre/movie/list?api_key=\(apiKey)")!
        
        let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 10)
        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue.main)
        
        let task: URLSessionDataTask = session.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
            if let data = data {
                if let dataDictionary = try! JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary {

                    self.genres = dataDictionary["genres"] as? [NSDictionary]
                    
                    self.tableView.reloadData()
                }
            }
        }
        task.resume()
    }
    
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
//        if let controller = viewController as? MoviesViewController {
//            genreIds = "16"
//            controller.genreIds = genreIds
//        }
    }

}
