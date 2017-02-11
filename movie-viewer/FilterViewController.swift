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
    
    let userDefaults = UserDefaults.standard

    var genres: [NSDictionary]?
    var genreId: Int = -1

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        
        self.genreId = self.userDefaults.integer(forKey: "genreId")
        
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
            
            // Uncheck previous genre selection if new genre was selected
            let prevIndex = self.userDefaults.integer(forKey: "genreIndex")
            if (selectedIndex != prevIndex) {
                let prevPath = NSIndexPath(row: prevIndex, section: 0)
                let prevCell = tableView.cellForRow(at: prevPath as IndexPath)
                prevCell?.accessoryType = .none
            }
            
            
            userDefaults.set(selectedIndex, forKey: "genreIndex")
            
            if (selectedIndex != 0) {
                let indexPath = NSIndexPath(row: 0, section: 0)
                let allCell = tableView.cellForRow(at: indexPath as IndexPath)
                allCell?.accessoryType = .none
            }
            
            self.genreId = genres?[selectedIndex]["id"]! as! Int
            userDefaults.set(genreId, forKey: "genreId")
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
                    
                    // Add any category to include all genres
                    let anyGenre: NSDictionary = [
                        "id": -1,
                        "name": "Any"
                    ]
                    self.genres?.insert(anyGenre as NSDictionary, at: 0)
                    
                    self.tableView.reloadData()
                    
                    let genreIndex = self.userDefaults.integer(forKey: "genreIndex")
                    let indexPath = NSIndexPath(row: genreIndex, section: 0)
                    let allCell = self.tableView.cellForRow(at: indexPath as IndexPath)
                    allCell?.accessoryType = .checkmark
                }
            }
        }
        task.resume()
    }
    
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        if let vc = viewController as? MoviesViewController {
            if (vc.genreId != self.genreId) {
                vc.genreId = self.genreId
                vc.loadNewMoviesByGenre()
            }
        }
    }

}
