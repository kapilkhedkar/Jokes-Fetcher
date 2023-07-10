//
//  JokePresenter.swift
//  Jokes-Fetcher
//
//  Created by Kapil Khedkar on 10/07/23.
//

import Foundation
import UIKit

protocol JokePresenterDelegate: AnyObject {
    func presentJokes(jokes: [Joke])
}

typealias PresenterDelegate = JokePresenterDelegate & UIViewController

class JokePresenter {

    weak var delegate: PresenterDelegate?
    
    private func saveJokesList(jokes: [Joke])
    {
        do {
            let encodedData = try JSONEncoder().encode(jokes)
            let userDefaults = UserDefaults.standard
            userDefaults.set(encodedData, forKey: "jokes-list")
        } catch {
            // Failed to encode Joke to Data
        }
    }
    
    private func getJokesList()->[Joke]
    {
        let userDefaults = UserDefaults.standard
        if let savedData = userDefaults.object(forKey: "jokes-list") as? Data {
            do{
                let jokesList = try JSONDecoder().decode([Joke].self, from: savedData)
                return jokesList
            } catch {
                // Failed to convert Data to Joke
                return [Joke]()
            }
        }
        return [Joke]()
    }
    
    public func getJokes()
    {
        let jokesList = getJokesList()
        if jokesList.count == 0 {
            fetchNewJoke()
        } else {
            let jokesList = getJokesList()
            self.delegate?.presentJokes(jokes: jokesList)
        }
    }
    
    public func fetchNewJoke() {
        
        guard let url = URL(string: "https://geek-jokes.sameerkumar.website/api") else { return }
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            guard let data = data, error == nil else {
                return
            }

            do {
                let jokeText = try JSONDecoder().decode(String.self, from: data)
                let newJoke = Joke(jokeText: jokeText)
                
                var jokesList = self!.getJokesList()
                if jokesList.count == 10 {
                    // Delete first inserted joke
                    jokesList.removeFirst()
                }
                jokesList.append(newJoke)
                self?.saveJokesList(jokes: jokesList)
                
                self?.delegate?.presentJokes(jokes: jokesList)
            }
            catch {
                print(error)
            }
        }
        task.resume()
    }
    
    public func setViewDelegate(delegate: PresenterDelegate) {
        self.delegate = delegate
    }

}
