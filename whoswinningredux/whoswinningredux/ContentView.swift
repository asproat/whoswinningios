//
//  ContentView.swift
//  whoswinningredux
//
//  Created by Alan Sproat on 5/1/24.
//

import SwiftUI

struct ContentView: View {
    
    static let cardShadowWidth = 20.0
    static let cardPadding = 7.0
    
    @State var currentGame = GameScores()
    @State var winnerHighScore = true
    @State var activePlayerIndex = -2
    @State var playersPlusAddCount = 0
    @State var listExpanded = false
    @State var currentScoreList: [GamePlayerScore] = []
    
    @State var stackMaxWidth: CGFloat = 0.0
    @State var activePlayerRightSide: CGFloat = -1 * cardShadowWidth
    
    @State var showConfirmClose = false
    @State var showSaveGame = false
    @State var saveGameName = ""
    @State var saveGame = false
    @State var shareGame = false
    
    @State var showRemoveUser = false
    @State var showRemoveScore = false
    @State var removePlayer = -1
    @State var removeScore = -1
    
    @State var newScoreString = "0"
    @State var newScore = 0
    @State var newName = ""
    @State var repeatWarning = false
    
    @State var settingsWidth = 200.0
    @State var playerWidths : [CGFloat] = [CGFloat]()
    
    @State private var numberFormatter: NumberFormatter = {
        var nf = NumberFormatter()
        nf.numberStyle = .none
        return nf
    }()
    
    enum Field: Hashable {
        case name
        case score
    }
    
    @FocusState var fieldFocus:Field?
    
    @State var columnHeight = -1
    
    @State var fromHistory = false
    
    @State var gameSaveImage = UIImage()
    
    /*
    init() {
        
        if (UserDefaults().string(forKey: "currentGame") != nil) {
            do {
                // load stored game
                currentGame = try JSONDecoder().decode(GameScores.self,
                        from: UserDefaults().string(forKey: "currentGame")!.data(using: .utf8)!)
                
                //JSONDecoder().decode(GameScores.self,
                //        from: UserDefaults().string(forKey: "currentGame")!.data(using:.utf8)!)
                playersPlusAddCount = currentGame.players.count
                
            } catch ( _) {
                // never mind
            }
        }
    }
    */
    
    func updateImage() {
        gameSaveImage = UIImage()
        /*
         @State var canvas = Canvas(gameSaveImage.asAndroidBitmap())
         canvas.drawColor(Color.Gray.toArgb())
         @State var textPaint = Paint()
         textPaint.color = Color.Black.toArgb()
         textPaint.textSize = 180.0
         canvas.tex saveGameName, 100.0, 100.0, textPaint)
         */
    }
    
    func addScore(playerIndex: Int, newScore: Int) {
        currentGame.players[playerIndex].addScore(newScore: newScore)
        currentGame.saveToPrefs()
        currentScoreList = currentGame.players[playerIndex].scoreList
        listExpanded = true
        activePlayerIndex = -1
        //DispatchQueue.main.asyncAfter(deadline: .now() +  0.1) {
        activePlayerIndex = playerIndex
        //}
    }
    
    func addPlayer(newName: String, metrics: GeometryProxy) {
        var newPlayer = GamePlayer(name: newName, scoreList: [])
        //newPlayer.gameDate = currentGame.gameDate
        newPlayer.name = newName
        currentGame.players.append(newPlayer)
        currentGame.saveToPrefs()
        activePlayerIndex = currentGame.players.count - 1
        for playerIdx in 0..<playersPlusAddCount {
            playerWidths[playerIdx] = metrics.size.width * 0.150
        }
        playersPlusAddCount =
        currentGame.players.count
        currentScoreList = []
        listExpanded = false
        playerWidths.append(metrics.size.width * 0.3)
    }
    
    func showNextPlayer(i: Int = 0, lastPlayer: Int = -1) {
        var current = i
        let playerCount = currentGame.players.count
        let last = lastPlayer != -1 ? lastPlayer :
        Int.random(in: ((playerCount * 3)...(playerCount * 6)))
        
        DispatchQueue.main.asyncAfter(deadline: .now() +  0.1) {
            current+=1
            activePlayerIndex = current % currentGame.players.count
            if current < last {
                showNextPlayer(i: current, lastPlayer: last)
            }
        }
    }
    
    func resetCurrentGame(clearGame: Bool = true) {
        activePlayerIndex = -1
        playersPlusAddCount = 0
        currentScoreList = []
        listExpanded = false
        if(clearGame) {
            // not using apply in background because it may not finish before app is closed
            UserDefaults().removeObject(forKey: "currentGame")
            UserDefaults().synchronize()
            currentGame = GameScores()
        } else {
            do {
                // load stored game
                currentGame = try JSONDecoder().decode(GameScores.self,
                        from: UserDefaults().string(forKey: "currentGame")!.data(using:.utf8)!)
                playersPlusAddCount = currentGame.players.count
            } catch ( _) {
                currentGame = GameScores()
                // never mind
            }
        }
    }
    
    /*
     func saveGameNow() async {
     currentGame.gameName = saveGameName
     for player in currentGame.players {
     @State var playerId = dao.insertGamePlayer(player)
     for score in player.scoreList {
     score.gamePlayerId = playerId.toInt()
     dao.insertGamePlayerScore(score)
     }
     }
     
     // clear current game
     resetCurrentGame()
     showConfirmClose = false
     }
     */
    
    func settingsVerticalShadow(metrics: GeometryProxy,
                                activePlayerOffset: CGFloat = 0.0
    ) -> some View {
        Path { path in
            // top right corner of card
            path.move(to:
                        CGPoint(x: 0.0 +
                                //ContentView.cardPadding +
                                activePlayerOffset,
                                y: 0.0))
            // top right corner of shadow
            path.addLine(to:
                            CGPoint(x: 0.0 +
                                    //ContentView.cardPadding * 2 +
                                    ContentView.cardShadowWidth +
                                    activePlayerOffset,
                                    y: 0.0))
            // bottom right corner of shadow
            path.addLine(to:
                            CGPoint(x: 0.0 +
                                    //ContentView.cardPadding * 2 +
                                    ContentView.cardShadowWidth +
                                    activePlayerOffset,
                                    y: (metrics.size.height * 0.9 -
                                        ContentView.cardPadding * 2) +
                                    ContentView.cardShadowWidth
                                   ))
            
            // bottom left corner of card
            path.addLine(to:
                            CGPoint(x: 0.0 +
                                    activePlayerOffset,
                                    y: (metrics.size.height  * 0.9 -
                                        (ContentView.cardPadding))))
            // top left corner of card
            path.addLine(to:
                            CGPoint(x: 0.0 +
                                    //ContentView.cardPadding +
                                    activePlayerOffset,
                                    y: 0.0))
        }
        .fill(
            LinearGradient(colors: [ .gray, .clear],
                           startPoint: .leading,
                           endPoint: .trailing)
        )
        
    }
    
    func playerHorizontalShadow(playerIndex: Int) -> some View {
        Path { path in
            // bottom left corner of card
            path.move(to:
                        CGPoint(x: 0 + ContentView.cardPadding,
                                y: 0))
            // top right corner of shadow
            path.addLine(to:
                            CGPoint(x: playerWidths[playerIndex] +
                                    (activePlayerIndex == playerIndex ? 0.0 : (ContentView.cardShadowWidth -
                                                                               ContentView.cardPadding)) +
                                    ContentView.cardPadding,
                                    y: 0))
            // bottom right corner of shadow
            path.addLine(to:
                            CGPoint(x: playerWidths[playerIndex] +
                                    ContentView.cardShadowWidth + ContentView.cardPadding,
                                    y: ContentView.cardShadowWidth +
                                    (activePlayerIndex == playerIndex ? ContentView.cardShadowWidth : 0.0)
                                   )
            )
            
            // bottom left corner of shadow
            path.addLine(to:
                            CGPoint(x: 0.0 + ContentView.cardPadding,
                                    y: ContentView.cardShadowWidth))
            // top right corner of card
            path.addLine(to:
                            CGPoint(x: 0 + ContentView.cardPadding,
                                    y: 0))
        }
        .fill(
            LinearGradient(colors: [ .gray, .white], startPoint: .top, endPoint: .bottom)
        )
        
    }
    
    func settingsHorizontalShadow() -> some View {
        Path { path in
            // bottom left corner of card
            path.move(to:
                        CGPoint(x: 0,
                                y: 0))
            // top right corner of shadow
            path.addLine(to:
                            CGPoint(x: settingsWidth - ContentView.cardPadding,
                                    y: 0))
            // bottom right corner of shadow
            path.addLine(to:
                            CGPoint(x: settingsWidth +
                                    ContentView.cardShadowWidth,
                                    y: ContentView.cardShadowWidth))
            
            // bottom left corner of shadow
            path.addLine(to:
                            CGPoint(x: 0.0,
                                    y: ContentView.cardShadowWidth))
            // top right corner of card
            path.addLine(to:
                            CGPoint(x: 0,
                                    y: 0))
        }
        .fill(
            LinearGradient(colors: [ .gray, .white], startPoint: .top, endPoint: .bottom)
        )
        
    }
    
    func playerColumn(playerIndex: Int, metrics: GeometryProxy) -> some View {
        VStack(alignment: .leading) {
            // show player
            Text(
                String(format:
                        NSLocalizedString("playerNameFormat", comment: ""),
                       currentGame.winningIndex().contains(playerIndex) ? "*" : "",
                       currentGame.players[playerIndex].name
                      )
            )
            .truncationMode(.tail)
            .lineLimit(1)
            .fontWeight(.bold)
            .onTapGesture {
                activePlayerIndex = playerIndex
                listExpanded = false
                currentScoreList =
                currentGame.players[activePlayerIndex].scoreList
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    fieldFocus = .score
                }
            }
            .padding(3)
            .frame(alignment: .topLeading)
            
            VStack(alignment: .trailing) {
                if (listExpanded &&
                    activePlayerIndex == playerIndex
                ) {
                    LazyVStack(alignment: .trailing) {
                        ForEach(0..<currentScoreList.count, id: \.self) { scoreIndex in
                            Text(
                                "\(currentScoreList[scoreIndex].score)"
                            )
                            .onTapGesture {
                                removePlayer = playerIndex
                                removeScore = scoreIndex
                                showRemoveScore = true
                            }
                            .frame(alignment: .trailing)
                        }
                    }
                    .frame(alignment: .trailing)
                }
                Text("\(currentGame.players[playerIndex].currentScore())")
                    .fontWeight(.bold)
                    .onTapGesture {
                        if activePlayerIndex == playerIndex {
                            listExpanded.toggle()
                        } else {
                            activePlayerIndex = playerIndex
                            listExpanded = true
                            currentScoreList =
                            currentGame.players[activePlayerIndex].scoreList
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                                fieldFocus = .score
                            }
                        }
                    }
            }
            .padding(ContentView.cardPadding)
            .frame(minWidth: playerWidths[playerIndex] - ContentView.cardPadding * 2,
                   maxWidth: playerWidths[playerIndex] - ContentView.cardPadding * 2,
                   alignment: Alignment(horizontal: .trailing, vertical: .top))
            
            VStack() {
                if activePlayerIndex != playerIndex {
                    Spacer()
                } else if !fromHistory {
                    HStack() {
                        Image(systemName: "plus.circle")
                            .onTapGesture {
                                newScore += 1
                                newScoreString = "\(newScore)"
                            }
                        TextField(newScoreString, text: $newScoreString)
                            .onChange(of: newScoreString, initial: true) { oldScoreString, newScoreString in
                                newScore = Int(newScoreString) ?? newScore
                            }
                            .lineLimit(1)
                            .multilineTextAlignment(.trailing)
                            .focused($fieldFocus, equals: .score)
                            .onReceive(NotificationCenter.default.publisher(for: UITextField.textDidBeginEditingNotification)) { obj in
                                if let textField = obj.object as? UITextField {
                                    textField.selectedTextRange = textField.textRange(from: textField.beginningOfDocument, to: textField.endOfDocument)
                                }
                            }
                            .onSubmit {
                                newScore = Int(newScoreString) ?? 0
                                addScore(
                                    playerIndex: playerIndex,
                                    newScore: newScore
                                )
                                newScore = 0
                                newScoreString = "\(newScore)"
                                fieldFocus = .score
                            }
                            .keyboardType(.numberPad)
                        Image(systemName: "minus.circle")
                            .onTapGesture {
                                newScore -= 1
                                newScoreString = "\(newScore)"
                                fieldFocus = .score
                            }
                    }
                    .alert("confirm_remove_player", isPresented: $showRemoveUser) {
                        Button("no") {
                            showRemoveUser = false
                        }
                        
                        Button("yes") {
                            currentGame.removePlayer(userIndex: activePlayerIndex )
                            playerWidths.remove(at: activePlayerIndex)
                            currentGame.saveToPrefs()
                            playersPlusAddCount -= 1
                            showRemoveUser = false
                            var currentIndex = activePlayerIndex
                            currentIndex = currentIndex > 0 ?
                            (currentIndex - 1) :
                            ((currentGame.players.count > 0) ? 0 : -1)
                            if (currentIndex != -1) {
                                currentScoreList =
                                currentGame.players[currentIndex].scoreList
                            }
                            
                            activePlayerIndex = currentIndex
                            stackMaxWidth -= metrics.size.width * 0.15
                            playerWidths[activePlayerIndex] = metrics.size.width * 0.3
                            calculateRightSide(metrics: metrics)
                            
                        }
                    }
                    
                    Button(
                        action: {
                            newScore = Int(newScoreString) ?? 0
                            addScore(playerIndex: playerIndex, newScore: newScore)
                            newScore = 0
                            newScoreString = "0"
                            fieldFocus = .score
                            DispatchQueue.main.async {
                                UIApplication.shared.sendAction(#selector(UIResponder.selectAll(_:)), to: nil, from: nil, for: nil)
                            }
                        },
                        label: {
                            Image(systemName: "checkmark")
                        }
                    )
                    Spacer()
                    Button(
                        action: {
                            removePlayer = playerIndex
                            showRemoveUser = true
                        },
                        label: {
                            Image(systemName: "trash")
                        }
                    )
                }
                
            }
            .padding(ContentView.cardPadding)
        }
        .frame(maxWidth: playerWidths[playerIndex],
               minHeight: metrics.size.height * 0.9,
               alignment: .topLeading)
        
    }
    
    func calculateRightSide(metrics: GeometryProxy) {
        if activePlayerIndex == -1 {
            activePlayerRightSide = -1.0 * metrics.size.width * 0.5
        } else {
            activePlayerRightSide = -1.0 *
            (CGFloat(playerWidths.count - 1 -
                     activePlayerIndex) *
             (metrics.size.width * 0.15))
        }
    }
    
    var body: some View {
        GeometryReader { metrics in
            ScrollView()
            {
                HStack(alignment: .top, spacing: 0) {
                    ForEach(0..<playersPlusAddCount, id: \.self) { playerIndex in
                        //if playerIndex < currentGame.players.count {
                        VStack(spacing: 0) {
                            playerColumn(playerIndex: playerIndex, metrics: metrics)
                                .border(.primary)
                                .zIndex(10)
                                .frame(maxWidth: playerWidths[playerIndex],
                                       minHeight: metrics.size.height * 0.90,
                                       alignment: .topLeading)
                            playerHorizontalShadow(playerIndex: playerIndex)
                                .frame(width: playerWidths[playerIndex] - ContentView.cardPadding,
                                       height: ContentView.cardShadowWidth )
                            
                            
                        }
                        .frame(maxWidth: playerWidths[playerIndex],
                               maxHeight: metrics.size.height * 0.90 + ContentView.cardShadowWidth)
                        //}
                    }
                    VStack() {
                        GeometryReader{ settingsMetrics in
                            ZStack(alignment: .topLeading) {
                                
                                VStack() {
                                    if activePlayerIndex != -1 {
                                        Image(uiImage: UIImage(named:"user")!)
                                            .onTapGesture {
                                                activePlayerIndex = -1
                                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                                    if !fromHistory {
                                                        fieldFocus = .score
                                                    }
                                                }
                                            }
                                            .frame(width: settingsWidth, alignment: .trailing)
                                    } else {
                                        if !fromHistory {
                                            
                                            Text(NSLocalizedString("winner_label", comment: "")).padding(5)
                                            HStack(alignment: .center) {
                                                Text(NSLocalizedString("low_score", comment: ""))
                                                    .font(.system(size:15)).padding(5)
                                                Toggle (isOn: $winnerHighScore,
                                                        label: { Text("") }
                                                )
                                                .onChange(of: winnerHighScore)
                                                { was, it in
                                                    winnerHighScore = it
                                                    currentGame.highScoreWinner =
                                                    winnerHighScore
                                                    currentGame.saveToPrefs()
                                                    // reset winner
                                                    if currentGame.players.count > 0 {
                                                        activePlayerIndex = 0
                                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1)
                                                        {
                                                            activePlayerIndex = -1
                                                        }
                                                    }
                                                }
                                                Text(NSLocalizedString("high_score", comment:""))
                                                    .font(.system(size: 14)).padding(5)
                                            }
                                            .frame(width: settingsWidth,
                                                   alignment: .topLeading)
                                            TextField(NSLocalizedString("name_hint",
                                                                        comment: ""), text: $newName)
                                            .focused($fieldFocus, equals: .name)
                                            .font(.system(size: 25))
                                            .onSubmit {
                                                addPlayer(newName: newName, metrics: metrics)
                                                newName = ""
                                            }
                                            .onChange(of: newName) { oldName, currentName in
                                                newName = currentName
                                                repeatWarning =
                                                currentGame.players.first { it in
                                                    it.name.starts(with: currentName)
                                                } != nil
                                            }
                                            
                                            if repeatWarning {
                                                Text(NSLocalizedString("name_exists", comment: ""))
                                            }
                                            Button(
                                                action: {
                                                    addPlayer(newName: newName, metrics: metrics)
                                                    newName = ""
                                                },
                                                label: {
                                                    Image(systemName:  "checkmark")
                                                }
                                            )
                                            .disabled(newName.isEmpty)
                                        }
                                        
                                        if !fromHistory {
                                            Button(
                                                action: {
                                                    if !currentGame.players.isEmpty {
                                                        // pick random number between 3 times and 6 times number of players
                                                        activePlayerIndex = 0
                                                        showNextPlayer()
                                                    }
                                                },
                                                label: {
                                                    Text(NSLocalizedString("choose_first", comment: ""))
                                                })
                                            .padding(10)
                                        }
                                        
                                        Spacer()
                                        
                                        Button(
                                            action: {
                                                if fromHistory {
                                                    resetCurrentGame(clearGame: false)
                                                } else {
                                                    
                                                    if !currentGame.players.isEmpty {
                                                        showConfirmClose = true
                                                        showSaveGame = false
                                                        saveGameName = ""
                                                        saveGame = false
                                                        shareGame = false
                                                        updateImage()
                                                    }
                                                }
                                            },
                                            label: {
                                                Image(systemName: "flag.checkered")
                                            })
                                        .padding(10)
                                    }
                                }
                                .coordinateSpace(name: "Settings")
                                .padding(ContentView.cardPadding)
                                .frame(minWidth: settingsWidth, maxWidth: settingsWidth,
                                       minHeight: metrics.size.height * 0.9,
                                       maxHeight: metrics.size.height * 0.9,
                                       alignment: .top
                                )
                                .border(.primary)
                                .zIndex(1)
                                
                                settingsHorizontalShadow()
                                    .zIndex(2)
                                    .offset(x: ContentView.cardPadding,
                                            y: metrics.size.height * 0.9)
                                    .frame(minWidth: settingsWidth +
                                           ContentView.cardShadowWidth,
                                           maxWidth: settingsWidth +
                                           ContentView.cardShadowWidth,
                                           minHeight: ContentView.cardShadowWidth,
                                           maxHeight: ContentView.cardShadowWidth)
                                
                                settingsVerticalShadow(metrics: metrics)
                                    .zIndex(3)
                                    .offset(x: settingsWidth,
                                            y: ContentView.cardPadding)
                                    .frame(width: ContentView.cardShadowWidth,
                                           height: metrics.size.height * 0.9 +
                                           ContentView.cardShadowWidth * 2)
                                settingsVerticalShadow(metrics: metrics)
                                    .zIndex(0)
                                    .offset(x: activePlayerRightSide,
                                            y: ContentView.cardPadding)
                                    .frame(width: ContentView.cardShadowWidth,
                                           height: metrics.size.height * 0.9 +
                                           ContentView.cardShadowWidth * 2)
                                    .background(.clear)
                            }
                            .frame(maxWidth: settingsWidth + ContentView.cardShadowWidth)
                        }
                        
                    }
                    .background(.clear)
                    .frame(maxWidth: settingsWidth + ContentView.cardShadowWidth,
                           minHeight: metrics.size.height * 0.95,
                           maxHeight: metrics.size.height * 0.95,
                           alignment: .topLeading
                    )
                    
                }
                .frame(maxWidth: stackMaxWidth)
            }
            .padding(3)
            .frame(minWidth: metrics.size.width * 0.95,
                   maxHeight: metrics.size.height * 0.95,
                   alignment: .topLeading)
            .onAppear() {
                
                do {
                    // load stored game
                    if let storedGame = UserDefaults().string(forKey: "currentGame") {
                        currentGame = try JSONDecoder().decode(GameScores.self,
                                        from: storedGame.data(using: .utf8)!)
                        playersPlusAddCount = currentGame.players.count
                        playerWidths = [CGFloat](repeating: metrics.size.width * 0.15,
                                                 count: playersPlusAddCount)
                    } else {
                        currentGame = GameScores()
                    }
                } catch ( _) {
                    // never mind
                }

                if activePlayerIndex == -2 {
                    activePlayerIndex = -1
                }
                
            }
            .onChange(of: activePlayerIndex, {
                calculateRightSide(metrics: metrics)
                
                stackMaxWidth = ContentView.cardShadowWidth
                if activePlayerIndex == -1 {
                    settingsWidth = 200.0
                } else {
                    settingsWidth = metrics.size.width * 0.150
                }
                stackMaxWidth += settingsWidth
                for playerIndex in 0..<playersPlusAddCount {
                    if playerIndex == activePlayerIndex {
                        playerWidths[playerIndex] = metrics.size.width * 0.3
                        stackMaxWidth += metrics.size.width * 0.3
                    } else {
                        playerWidths[playerIndex] = metrics.size.width * 0.150
                        stackMaxWidth += metrics.size.width * 0.150
                    }
                }
                fieldFocus = .score
                DispatchQueue.main.async {
                    print("shw: \(ContentView.cardShadowWidth) sw: \(settingsWidth) smw: \(stackMaxWidth)")
                    UIApplication.shared.sendAction(#selector(UIResponder.selectAll(_:)), to: nil, from: nil, for: nil)
                }
                
            })
        }
    }
}

#Preview {
    ContentView()
}
