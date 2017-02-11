//
//  MoviesViewController.swift
//  movie-viewer
//
//  Created by Rodrigo Bell on 1/12/17.
//  Copyright © 2017 Rodrigo Bell. All rights reserved.
//

import UIKit
import AFNetworking
import MBProgressHUD

class MoviesViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UISearchBarDelegate {
    
    let userDefaults = UserDefaults.standard
        
    @IBOutlet weak var collectionView: UICollectionView!
    
    var searchBar = UISearchBar()
    @IBOutlet weak var filterButton: UIBarButtonItem!
    
    var movies: [NSDictionary] = []
    var filteredMovies: [NSDictionary]?
    var endpoint: String!
    var genreId: Int = -1
    
    let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
    var numPages = 1
    
    var isMoreDataLoading = false
    var loadingMoreView: ProgressIndicator?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.dataSource = self
        collectionView.delegate = self
        searchBar.delegate = self
        
        UIApplication.shared.statusBarStyle = .lightContent
        
        // Embed search bar in navigation controller
        searchBar.sizeToFit()
        searchBar.placeholder = "Search"
        searchBar.barStyle = UIBarStyle.black
        self.navigationItem.titleView = self.searchBar
        let textFieldAppearance = UITextField.appearance()
        textFieldAppearance.keyboardAppearance = .dark //.default//.light//.alert
        
        // Initialize a UIRefreshControl
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshControlAction(refreshControl:)), for: UIControlEvents.valueChanged)
        
        // Add refresh control to collection view
        collectionView.insertSubview(refreshControl, at: 0)
        
        // Set up Infinite Scroll loading indicator
        let frame = CGRect(x: 0, y: collectionView.contentSize.height, width: collectionView.bounds.size.width, height: ProgressIndicator.defaultHeight)
        loadingMoreView = ProgressIndicator(frame: frame)
        loadingMoreView!.isHidden = true
        collectionView.addSubview(loadingMoreView!)
        
        var insets = collectionView.contentInset;
        insets.bottom += ProgressIndicator.defaultHeight;
        collectionView.contentInset = insets
        
        // Load initial set of movies
        self.genreId = self.userDefaults.integer(forKey: "genreId")
        MBProgressHUD.showAdded(to: self.view, animated: true)
        loadMoviesFromAPI()
        MBProgressHUD.hide(for: self.view, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let filteredMovies = filteredMovies {
            return filteredMovies.count
        } else {
            return movies.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "movie-cell", for: indexPath) as! MovieCell
        
        let movie = filteredMovies![indexPath.row]
        
        let baseUrl = "https://image.tmdb.org/t/p/w342"
        
        if let posterPath = movie["poster_path"] as? String {
            let imageUrl = NSURL(string: baseUrl + posterPath)
            cell.posterView.setImageWith(imageUrl as! URL)
        }
        
        return cell
    }
    
    func loadMoviesFromAPI() {
        let numPagesString = String(self.numPages)
        
        var url: URL!
        
        if endpoint == "now_playing" {
            url = URL(string: "https://api.themoviedb.org/3/movie/\(endpoint!)?api_key=\(apiKey)&page=\(numPagesString)")!
        }
        else if endpoint == "top_rated" {
            var idString = ""
            if (genreId != -1) {
                idString = String(genreId)
            }
            
            url = URL(string: "https://api.themoviedb.org/3/discover/movie?api_key=\(apiKey)&sort_by=vote_average.desc&vote_count.gte=100&with_genres=\(idString)&page=\(numPagesString)")!
        }
        
        let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 10)
        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue.main)
        
        let task: URLSessionDataTask = session.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
            if let data = data {
                if let dataDictionary = try! JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary {
                    
                    self.movies.append(contentsOf: dataDictionary["results"] as! [NSDictionary])
                    self.filteredMovies = self.movies
                    
                    self.collectionView.reloadData()
                    
                    // Stop the loading indicator
                    self.loadingMoreView!.stopAnimating()
                    
                    self.isMoreDataLoading = false
                }
            }
        }
        task.resume()
    }
    
    func loadNewMoviesByGenre() {
        // Scroll view back to top and reload collection view so there's no indexing issues
        collectionView.setContentOffset(CGPoint.init(x: 0, y: -60), animated: true)
        collectionView.reloadData()
        
        // Reset existing movie data
        self.movies = []
        self.filteredMovies = movies
        self.numPages = 1
        
        // Load new movies given selected genre
        MBProgressHUD.showAdded(to: self.view, animated: true)
        loadMoviesFromAPI()
        MBProgressHUD.hide(for: self.view, animated: true)
    }
    
    // Makes a network request to get updated data
    // Updates the tableView with the new data
    // Hides the RefreshControl
    func refreshControlAction(refreshControl: UIRefreshControl) {
        searchBar.text = ""
        loadMoviesFromAPI()
        refreshControl.endRefreshing()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (!isMoreDataLoading) {
            // Calculate the position of one screen length before the bottom of the results
            let scrollViewContentHeight = collectionView.contentSize.height
            let scrollOffsetThreshold = scrollViewContentHeight - collectionView.bounds.size.height
            
            // When the user has scrolled past the threshold, start requesting
            if(scrollView.contentOffset.y > scrollOffsetThreshold && collectionView.isDragging) {
                self.numPages += 1
                isMoreDataLoading = true
                
                // Update position of loadingMoreView, and start loading indicator
                let frame = CGRect(x: 0, y: collectionView.contentSize.height, width: collectionView.bounds.size.width, height: ProgressIndicator.defaultHeight)
                loadingMoreView?.frame = frame
                loadingMoreView!.startAnimating()
                
                // ... Code to load more results ...
                loadMoviesFromAPI()
            }
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filteredMovies = searchText.isEmpty ? movies : movies.filter({(movie: NSDictionary) -> Bool in
            // If dataItem matches the searchText, return true to include it
            return (movie["title"] as! String).range(of: searchText, options: .caseInsensitive) != nil
        })
        
        collectionView.reloadData()
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.searchBar.showsCancelButton = true
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
        searchBar.text = ""
        searchBar.resignFirstResponder()
        self.filteredMovies = self.movies
        self.collectionView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
        searchBar.resignFirstResponder()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "detailSegue" {
            let cell = sender as! UICollectionViewCell
            let indexPath = collectionView.indexPath(for: cell)
            let movie = movies[indexPath!.row]
            
            let detailViewController = segue.destination as! DetailViewController
            detailViewController.movie = movie
        }
    }
    
}
