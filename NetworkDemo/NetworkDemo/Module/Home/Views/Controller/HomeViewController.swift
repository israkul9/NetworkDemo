//
//  HomeViewController.swift
//  NetworkDemo
//
//  Created by Israkul Tushaer-81 on 11/1/24.
//

import UIKit
import SwiftyJSON
import Alamofire
import Combine
class HomeViewController: UIViewController {
    
    var subscription = Set<AnyCancellable>()
    
    var viewModel: HomeViewModel!
    
    @IBOutlet weak var homeTableView: UITableView! {
        didSet {
           // homeTableView.isHidden = true
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let apiWithEndpoint = "https://api.themoviedb.org/3/search/movie?api_key=38e61227f85671163c275f9bd95a8803&query=marvel"
        setupTableView()
        viewModel = HomeViewModel()
        viewModel.getData(baseUrl: apiWithEndpoint)
        bindData()
    }
    
    func bindData(){
        viewModel.movieListSubject.sink { completion in
            print(completion)
        } receiveValue: { [weak self] movie in
            guard let self = self else { return }
            self.viewModel.movieListDataSource = movie
            DispatchQueue.main.async {
                // reload tableView
                self.homeTableView.reloadData()
            }
            
        }.store(in: &subscription)

    }
    
    func setupTableView(){
        self.homeTableView.delegate = self
        self.homeTableView.dataSource  = self
        self.homeTableView.register(UINib(nibName: MovieCell.className, bundle: nil), forCellReuseIdentifier: MovieCell.className)
    }
}

extension HomeViewController :  UITableViewDelegate , UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.movieListDataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MovieCell.className , for: indexPath) as? MovieCell else {
            return UITableViewCell()
        }
         let movie = self.viewModel.movieListDataSource[indexPath.row]
        cell.configureCell(movie: movie)
       
        return cell
    }
    
    
}
