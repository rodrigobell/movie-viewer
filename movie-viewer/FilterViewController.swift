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
    var genreId: String?

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
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath as IndexPath) {
            cell.accessoryType = .none
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath as IndexPath) {
            cell.accessoryType = .checkmark
                        
            let selectedIndex = indexPath.row
            if (selectedIndex == 0) {
                self.genreId = ""
            } else {
                let indexPath = NSIndexPath(row: 0, section: 0)
                let allCell = tableView.cellForRow(at: indexPath as IndexPath)
                allCell?.accessoryType = .none
                
                let g = genres?[selectedIndex]["id"]! as! Int
                self.genreId = String(g)
            }
        }
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
                    
                    let anyGenre = [
                        "id": "-1",
                        "name": "Any"
                    ]
                    self.genres?.insert(anyGenre as NSDictionary, at: 0)
                    
                    self.tableView.reloadData()
                    
                    let indexPath = NSIndexPath(row: 0, section: 0)
                    let allCell = self.tableView.cellForRow(at: indexPath as IndexPath)
                    allCell?.accessoryType = .checkmark
                }
            }
        }
        task.resume()
    }
    
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        if let vc = viewController as? MoviesViewController {
            if let genreId = genreId {
                vc.genreId = self.genreId!
            }
        }
    }

}
