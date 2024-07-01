//
//  GameScore.swift
//  whoswinningredux
//
//  Created by Alan Sproat on 5/24/24.
//

import Foundation
import SwiftData
import RealmSwift

@Model
class GameScores: Codable {
    
    var gameName = ""
    var highScoreWinner = true
    
    @Attribute(.unique)
    var gameDate = Date()
    
    var players = [GamePlayer]()
    
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
        
    required init(from decoder:Decoder) throws {
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
    
    func removePlayer(userIndex: Int) {
        players.remove(at: userIndex)
    }
    
    func winningIndex() -> [Int] {
        var winners = [Int]()
        var winningScore = 0
        var scoreAdjustment = highScoreWinner ? 1 : -1
        
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
    
    func saveToPrefs() {
        let prefs = UserDefaults.standard
        
        do {
            prefs.set(try JSONEncoder().encode(self), forKey: "currentGame")
            
            // not using apply in background to aovid losing data if the app closes suddenly
            prefs.synchronize()
        } catch (let e) {
            
        }
    }
    
    /*
     func prepRoom(context: Context) : AppDatabase {
     return Room.databaseBuilder(
     context,
     AppDatabase::class.java, "database-name"
     ).build()
     }
     
     func prepRealm(context: Context) {
     Realm.init(context)
     let realmConfig = RealmConfiguration.Builder()
     .name("whoswinning.realm")
     .schemaVersion(1)
     .build()
     Realm.setDefaultConfiguration(realmConfig);
     }
     
     func dateString(epochSeconds: Long) : String {
     let epochLocalInstant = Instant.ofEpochSecond(epochSeconds).atZone(ZonedDateTime.now().zone)
     
     return (String.format("%04d%02d%02d%02d%02d%02d",
     epochLocalInstant.year,
     epochLocalInstant.month,
     epochLocalInstant.dayOfMonth,
     epochLocalInstant.hour,
     epochLocalInstant.minute,
     epochLocalInstant.second,
     )
     )
     }
     */
}

class GamePlayer: Codable {
    var name = ""
    var scoreList = [Int]()
    
    func addScore(newScore: Int) {
        scoreList.append(newScore)
    }
    
    func removeScore(scoreIndex: Int) {
        scoreList.remove(at: scoreIndex)
    }
    
    func currentScore() -> Int {
        var scoreTotal = 0
        
        for score in scoreList {
            scoreTotal += score
        }
        
        return scoreTotal
    }
}
