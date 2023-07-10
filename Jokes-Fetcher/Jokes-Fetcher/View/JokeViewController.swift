//
//  JokeViewController.swift
//  Jokes-Fetcher
//
//  Created by Kapil Khedkar on 10/07/23.
//

import UIKit

class JokeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, JokePresenterDelegate {
    
    private let tableView: UITableView = {
        let table = UITableView()
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return table
    }()
    
    private var jokes = [Joke]()
    
    private let presenter = JokePresenter()
    
    var timeInterval: TimeInterval = 60.0 // 60 seconds
    var timer = Timer()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Jokes"
        
        // Table
        view.addSubview(tableView)
        tableView.dataSource = self
        tableView.delegate = self
        
        // Presenter
        presenter.setViewDelegate(delegate: self)
        presenter.getJokes()
        
        timer = Timer.scheduledTimer(timeInterval: timeInterval, target: self, selector: #selector(fireTimer), userInfo: nil, repeats: true)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    
    deinit {
        timer.invalidate()
    }
    
    @objc func fireTimer() {
        presenter.fetchNewJoke()
    }
    
    // Table Delegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return jokes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.text = jokes[indexPath.row].jokeText
        cell.selectionStyle = .none
        return cell
    }
    
    // Presenter Delegate
    func presentJokes(jokes: [Joke]) {
        self.jokes = jokes
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
}
