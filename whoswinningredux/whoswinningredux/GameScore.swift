//
//  GameScore.swift
//  whoswinningredux
//
//  Created by Alan Sproat on 5/24/24.
//

import Foundation
import SwiftData

struct GameScores: Codable {
    let gameName : String
    var highScoreWinner : Bool
    
    let gameDate : Date
    
    var players : [GamePlayer]
    
    init(gameName: String = "", highScoreWinner: Bool = true, gameDate: Date = Date(), players: [GamePlayer] = [GamePlayer]()) {
        self.gameName = gameName
        self.highScoreWinner = highScoreWinner
        self.gameDate = gameDate
        self.players = players
    }
    
    private enum CodingKeys: String, CodingKey {
        case gameName
        case highScoreWinner
        case gameDate
        case players
    }
        
    init(from decoder:Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        gameName = try values.decode(String.self, forKey: .gameName)
        highScoreWinner = try values.decode(Bool.self, forKey: .highScoreWinner)
        gameDate = try values.decode(Date.self, forKey: .gameDate)
        players = try values.decode([GamePlayer].self, forKey: .players)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(gameName, forKey: .gameName)
        try container.encode(highScoreWinner, forKey: .highScoreWinner)
        try container.encode(gameDate, forKey: .gameDate)
        try container.encode(players, forKey: .players)
    }
    
    mutating func removePlayer(userIndex: Int) {
        players.remove(at: userIndex)
    }
    
    func winningIndex() -> [Int] {
        var winners = [Int]()
        var winningScore = highScoreWinner ? 0 : Int.min
        let scoreAdjustment = highScoreWinner ? 1 : -1
        
        for playerIndex in 0..<players.count {
            if (players[playerIndex].currentScore() * scoreAdjustment > winningScore) {
                winners.removeAll()
                winners.append(playerIndex)
                winningScore = players[playerIndex].currentScore() * scoreAdjustment
            } else if (players[playerIndex].currentScore() * scoreAdjustment == winningScore) {
                winners.append(playerIndex)
            }
        }
        
        return winners
    }

    func standings() -> String {
        var standings = "\(NSLocalizedString("standings", comment: "")):\n\n"
        let scoreAdjustment = highScoreWinner ? 1 : -1
        let sortedPlayers = players.sorted{
                a, b in
                return a.currentScore() * scoreAdjustment > b.currentScore() * scoreAdjustment
            }
        for player in sortedPlayers {
            standings.append("\(player.name): \(player.currentScore())\n")
        }
        
        return standings
    }

    func saveToPrefs() {
        
        do {
            UserDefaults().set(String(data: try JSONEncoder().encode(self), encoding: .utf8),
                    forKey: "currentGame")
            UserDefaults().synchronize()
        } catch {
            
        }
    }
    
}

struct GamePlayer: Codable {
    var name: String
    var scoreList : [GamePlayerScore]
    
    mutating func addScore(newScore: Int) {
        scoreList.append(GamePlayerScore(_id: 0, gamePlayerId: 0, score: newScore))
    }
    
    mutating func removeScore(scoreIndex: Int) {
        scoreList.remove(at: scoreIndex)
    }
    
    func currentScore() -> Int {
        var scoreTotal = 0
        
        for score in scoreList {
            scoreTotal += score.score
        }
        
        return scoreTotal
    }
}

struct GamePlayerScore: Codable, Hashable {
    let _id: Int
    let gamePlayerId: Int
    var score: Int

    mutating func setInitialScore(newScore: Int) {
        score = newScore
    }
}

