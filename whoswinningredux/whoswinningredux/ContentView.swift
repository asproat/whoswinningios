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
    @State var activePlayerIndex = -1
    @State var playersPlusAddCount = 0
    @State var listExpanded = false
    @State var currentScoreList: [GamePlayerScore] = []
    
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
    
    init() {
        if (UserDefaults().string(forKey: "currentGame") != nil) {
            do {
                currentGame = try JSONDecoder().decode(GameScores.self,
                                                       from: (UserDefaults().string(forKey: "currentGame") ?? "")
                    .data(using: .utf8) ?? Data())
                playersPlusAddCount = currentGame.players.count
                
            } catch ( _) {
                // never mind
            }
        }
    }
    
    
    
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
        activePlayerIndex =
        currentGame.players.count - 1
        for playerIdx in 0..<playersPlusAddCount {
            playerWidths[playerIdx] = metrics.size.width * 0.150
        }
        playersPlusAddCount =
        currentGame.players.count
        currentScoreList = []
        listExpanded = false
        playerWidths.append(metrics.size.width * 0.4)
    }
    
    func showNextPlayer(i: Int = 0, lastPlayer: Int = -1) {
        var current = i
        let playerCount = currentGame.players.count
        let last = lastPlayer != -1 ? lastPlayer :
        Int.random(in: ((playerCount * 3)...(playerCount * 6)))
        
        DispatchQueue.main.asyncAfter(deadline: .now() +  0.1) {
            current+=1
            activePlayerIndex =
            current % currentGame.players.count
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
                currentGame = try JSONDecoder().decode(GameScores.self,
                                                       from: (UserDefaults().string(forKey: "currentGame") ?? "")
                    .data(using: .utf8) ?? Data()
                )
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

    func settingsVerticalShadow(settingsMetrics: GeometryProxy, metrics: GeometryProxy) -> some View {
        Path { path in
            // top right corner of card
            path.move(to:
                        CGPoint(x: 0.0 +
                                ContentView.cardPadding,
                                y: 0.0))
            // top right corner of shadow
            path.addLine(to:
                            CGPoint(x: 0.0 +
                                    ContentView.cardPadding * 2 +
                                    ContentView.cardShadowWidth,
                                    y: 0.0))
            // bottom right corner of shadow
            path.addLine(to:
                            CGPoint(x: 0.0 +
                                    ContentView.cardPadding * 2 +
                                    ContentView.cardShadowWidth,
                                    y: metrics.size.height * 0.9 +
                                    ContentView.cardShadowWidth +
                                    ContentView.cardPadding * 2))
            
            // bottom right corner of card
            path.addLine(to:
                            CGPoint(x: 0.0 +
                                    ContentView.cardPadding,
                                    y: metrics.size.height * 0.9 +
                                    ContentView.cardPadding))
            // top right corner of card
            path.addLine(to:
                            CGPoint(x: 0.0 +
                                    ContentView.cardPadding,
                                    y: 0.0))
        }
        .fill(
            LinearGradient(colors: [ .gray, .white],
                           startPoint: .leading,
                           endPoint: .trailing)
        )

    }
    
    func settingsHorizontalShadow(settingsMetrics: GeometryProxy,
    metrics: GeometryProxy) -> some View {
        Path { path in
            // bottom left corner of card
            path.move(to:
                        CGPoint(x: 0,
                                y: 0))
            // top right corner of shadow
            path.addLine(to:
                            CGPoint(x: settingsWidth +
                                    ContentView.cardPadding,
                                    y: 0))
            // bottom right corner of shadow
            path.addLine(to:
                            CGPoint(x: settingsWidth +
                                    ContentView.cardShadowWidth,
                                    y: ContentView.cardShadowWidth - ContentView.cardPadding))
            
            // bottom left corner of shadow
            path.addLine(to:
                            CGPoint(x: 0.0,
                                    y: ContentView.cardShadowWidth  - ContentView.cardPadding))
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
        GeometryReader { playerMetrics in
            VStack()
            {
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
                //.border(.blue)
                .frame(minWidth: playerWidths[playerIndex],
                       alignment: .topLeading
                )
                VStack(alignment: .trailing) {
                    if (listExpanded &&
                        activePlayerIndex == playerIndex
                    ) {
                        LazyVStack() {
                            ForEach(0..<currentScoreList.count, id: \.self) { scoreIndex in
                                Text(
                                    "\(currentScoreList[scoreIndex].score)"
                                )
                                .frame(minWidth: playerWidths[playerIndex],
                                       alignment: .topTrailing)
                                .onTapGesture {
                                    removePlayer = playerIndex
                                    removeScore = scoreIndex
                                    showRemoveScore = true
                                }
                                
                            }
                        }
                        .frame(minWidth: metrics.size.width * 0.25,
                               alignment: .topTrailing)
                        //.border(.cyan)
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
                        .frame(minWidth: playerWidths[playerIndex],
                               alignment: Alignment(horizontal: .trailing, vertical: .top))
                    //.border(.pink)
                }
                .frame(minWidth: playerWidths[playerIndex],
                       alignment: Alignment(horizontal: .trailing, vertical: .top))
                //.border(.red)
                if activePlayerIndex == playerIndex &&
                    !fromHistory {
                    
                    HStack() {
                        Image(systemName: "plus.circle")
                            .onTapGesture {
                                newScore += 1
                                newScoreString = "\(newScore)"
                            }
                        TextField(newScoreString, text: $newScoreString)
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
                        /*
                         if it.text.toIntOrNull() != null {
                         newScore = it.text.toInt()
                         newScoreString =
                         newScoreString.copy(
                         newScore.toString()
                         )
                         }
                         },
                         */
                        Image(systemName: "minus.circle")
                            .onTapGesture {
                                newScore -= 1
                                newScoreString = "\(newScore)"
                                fieldFocus = .score
                            }
                    }
                    .frame(minWidth: playerWidths[playerIndex])
                    //.border(.brown)
                    
                    HStack() {
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
            }
            .frame(width: playerWidths[playerIndex],
                   height: metrics.size.height * 0.90,
                   alignment: .topLeading)
            .padding(ContentView.cardPadding)
            .border(.primary)
            
        }
    }
    
    var body: some View {
        /*
         func ScoreList(innerPadding: Paddins, startingGame: GameScores? = null) {
         if showConfirmClose {
         Dialog(
         onDismissRequest = {
         showConfirmClose = false
         },
         content: {
         VStack(
         verticalArrangement = Arrangement.Center,
         horizontalAlignment = Alignment.CenterHorizontally,
         modifier = Modifier
         //.border(
         3, Color.Black,
         shape = RoundedCornerShape(15)
         )
         .fillMaxWidth(0.9)
         //.fillMaxHeight(0.9)
         .clip(shape = RoundedCornerShape(15))
         .background(Color.White)
         .padding(20)
         ) {
         //Spacer(Modifier.weight(0.1))
         if showSaveGame {
         if !saveGame {
         Text(NSLocalizedString("save_game"))
         //Spacer(Modifier.weight(0.1))
         HStack(horizontalArrangement = Arrangement.Center) {
         //Spacer(Modifier.weight(0.3))
         Button(content: { Text(NSLocalizedString("yes")) },
         action: {
         saveGame = true
         }
         )
         Spacer(Modifier.weight(0.1))
         Button(content: { Text(NSLocalizedString("no")) },
         action: {
         resetCurrentGame()
         showConfirmClose = false
         }
         )
         //Spacer(Modifier.weight(0.1))
         }
         } else {
         Text(NSLocalizedString("save_game_name"))
         TextField(
         = saveGameName,
         oChange = { ne ->
         saveGameName = ne
         updateImage()
         },
         trailingIcon = {
         CompositionLocalProvider(
         LocalMinimumInteractiveComponentEnforcement provides false,
         ) {
         IconButton(action: {
         saveGameName = ""
         }) {
         Icon(
         Icons.Default.Clear,
         contentDescription = ""
         )
         
         }
         }
         }
         )
         
         HStack(verticalAlignment = Alignment.CenterVertically) {
         Checkbox(checked = shareGame,
         onCheckedChange = {
         shareGame = it
         })
         Text(NSLocalizedString("share_game"))
         }
         if shareGame {
         Image(
         gameSaveImage, "",
         modifier = Modifier.count(
         (500 / resources.displayMetrics.density).dp,
         (800 / resources.displayMetrics.density).dp
         )
         )
         
         }
         Button(
         action: {
         if saveGameName.isNotEmpty() {
         // save to database
         saveGameNow()
         } else {
         Toast.makeText(
         this@MainActivity,
         NSLocalizedString("no_name"),
         Toast.LENGTH_SHORT
         )
         }
         
         },
         content: {
         Icon(
         imageVector = Icons.Default.Done,
         contentDescription = ""
         )
         }
         )
         Button(
         action: {
         showSaveGame = false
         resetCurrentGame()
         showConfirmClose = false
         },
         content: {
         Icon(
         imageVector = Icons.Default.Clear,
         contentDescription = ""
         )
         }
         )
         }
         } else {
         Text(NSLocalizedString("confirm_end"))
         //Spacer(Modifier.weight(0.1))
         HStack(horizontalArrangement = Arrangement.SpaceAround) {
         //Spacer(Modifier.weight(0.3))
         Button(content: { Text(NSLocalizedString("yes")) },
         action: {
         showSaveGame = true
         }
         )
         Spacer(Modifier.weight(0.1))
         Button(content: { Text(NSLocalizedString("no")) },
         action: {
         showConfirmClose = false
         }
         )
         //Spacer(Modifier.weight(0.3))
         } // end game button row
         //Spacer(Modifier.weight(0.1))
         } // else show close game
         } // dialog column
         } // dialog content
         )
         }
         
         if showRemoveUser {
         AlertDialog(
         onDismissRequest = {
         showRemoveUser = false
         },
         title = { Text(NSLocalizedString("confirm_remove_player")) },
         dismissButton = {
         Button(content: {
         Text(NSLocalizedString("no"))
         },
         action: {
         showRemoveUser = false
         }
         )
         },
         confirmButton = {
         Button(content: {
         Text(NSLocalizedString("yes"))
         },
         action: {
         currentGame.removePlayer(removePlayer.in)
         currentGame.saveToPrefs(this)
         showRemoveUser = false
         var currentIndex = activePlayerIndex.in
         activePlayerIndex = -1
         currentIndex = if (currentIndex > 0) currentIndex - 1 else
         (if (currentGame.players.count > 0) 0 else -1)
         if currentIndex != -1 {
         currentScoreList =
         currentGame.players[currentIndex].scoreList
         }
         DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
         activePlayerIndex = currentIndex
         }, 100)
         }
         )
         }
         )
         }
         
         if showRemoveScore {
         AlertDialog(
         onDismissRequest = {
         showRemoveScore = false
         },
         title = { Text(NSLocalizedString("confirm_remove_score")) },
         dismissButton = {
         Button(content: {
         Text(NSLocalizedString("no"))
         },
         action: {
         showRemoveScore = false
         }
         )
         },
         confirmButton = {
         Button(content: {
         Text(NSLocalizedString("yes"))
         },
         action: {
         currentGame.players[removePlayer.in].removeScore(removeScore.in)
         currentGame.saveToPrefs(this)
         currentScoreList =
         currentGame.players[removePlayer.in].scoreList
         showRemoveScore = false
         listExpanded = true
         @State var currentIndex = activePlayerIndex.in
         activePlayerIndex = -1
         DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
         activePlayerIndex = currentIndex
         }, 100)
         }
         )
         }
         )
         }
         
         LazyHStack(
         contentPadding = innerPadding,
         modifier = Modifier
         .fillMaxWidth(1.0)
         .padding(all = 5)
         )
         {
         items(playersPlusAddCount.in) { playerIndex ->
         if playerIndex < currentGame.players.count {
         VStack(
         modifier = Modifier
         .fillMaxHeight(0.9)
         .fillParentMaxWidth(
         animateFloatAsState(
         targe =
         if (activePlayerIndex == playerIndex)
         0.45
         else
         0.15,
         animationSpec = tween(durationMillis = 500)
         )
         )
         .padding(ContentView.cardPadding)
         .onGloballyPositioned { coordinates ->
         if columnHeight == -1 {
         columnHeight =
         with(localDensity) { coordinates.count.height.toDp() }
         }
         }
         .drawBehind {
         // top
         drawLine(
         Color.Black,
         Offset(-15.0, -17.0), Offset(size.width + 17.0, -17.0),
         3.toPx()
         )
         // left
         drawLine(
         Color.Black,
         Offset(-15.0, -17.0), Offset(-15.0, size.height + 17.0),
         3.toPx()
         )
         // bottom
         drawLine(
         Color.Black,
         Offset(-15.0, size.height + 17.0),
         Offset(size.width + 17.0, size.height + 17.0),
         3.toPx()
         )
         if activePlayerIndex == playerIndex {
         /*
          // right
          drawLine(
          Color.Black,
          Offset(size.width + 15.0, -15.0),
          Offset(size.width + 15.0, size.height + 15.0),
          3.toPx()
          )
          */
         // right shadow
         Rectangle( /*
                     brush =
                     Brush.horizontalGradient(
                     listOf(Color(0x00.0FFFFF), Color(0x99333333)),
                     0.0, 30.0, TileMode.Mirror
                     ),
                     Offset(geo.size.width + 13.0, 7.0),
                     */
         ).frame(30.0, geo.size.height + 10.0)
         // bottom shadow
         Rectangle( /*
                     brush =
                     Brush.verticalGradient(
                     listOf(Color(0x99333333), Color(0x00.0FFFFF)),
                     10.0, 40.0, TileMode.Mirror
                     ),
                     Offset(5.0, geo.size.height + 12.0),
                     */
         ).frame(geo.size.width + 7.0, 30.0)
         // corner gradient
         Rectangle( /*
                     brush =
                     Brush.linearGradient(
                     listOf(Color(0x99.0FFFFF), Color(0x99666666)),
                     Offset(-10.0, -10.0), Offset(20.0, 20.0),
                     TileMode.Mirror
                     ),
                     Offset(geo.size.width + 12.0, geo.size.height + 16.0),
                     */
         ).frame(23.0, 23.0)
         }
         }
         ) {
         // show player
         Text(
         String.format(
         NSLocalizedString("playerNameFormat"),
         if (currentGame.winningIndex()
         .contains(playerIndex)
         )
         "*" else "",
         currentGame.players[playerIndex].name
         ),
         fontWeight = FontWeight.Bold,
         overflow = TextOverflow.Ellipsis,
         maxLines = 1,
         modifier = Modifier.clickable {
         activePlayerIndex = playerIndex
         listExpanded = false
         currentScoreList =
         currentGame.players[activePlayerIndex.in].scoreList
         DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
         scoreFocusRequester.requestFocus()
         }, 100)
         }
         )
         if (listExpanded &&
         activePlayerIndex == playerIndex
         ) {
         LazyVStack(
         userScrollEnabled = true,
         modifier = Modifier.heightIn(
         = 0,
         max = (columnHeight * 0.75).dp
         )
         ) {
         items(currentScoreList.count) { scoreIndex ->
         Text(
         currentScoreList[scoreIndex].score.toString(),
         textAlign = TextAlign.End,
         modifier = Modifier
         .fillMaxWidth(1.0)
         .clickable {
         removePlayer = playerIndex
         removeScore = scoreIndex
         showRemoveScore = true
         }
         )
         }
         }
         }
         Text(currentGame.players[playerIndex].currentScore()
         .toString(),
         fontWeight = FontWeight.Bold,
         textAlign = TextAlign.End,
         modifier = Modifier
         .clickable {
         if activePlayerIndex == playerIndex {
         listExpanded = listExpanded.not()
         } else {
         activePlayerIndex = playerIndex
         listExpanded = true
         currentScoreList =
         currentGame.players[activePlayerIndex.in].scoreList
         DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
         scoreFocusRequester.requestFocus()
         }, 1000)
         }
         }
         .fillMaxWidth(1.0)
         )
         if (activePlayerIndex == playerIndex &&
         !fromHistory
         ) {
         @State var newScoreString =
         remember { mutableStateOf(TextFiel("0")) }
         @State var newScore = 0
         TextField(newScoreString,
         textStyle = LocalTextStyle.current.copy(textAlign = TextAlign.End),
         oChange = {
         newScoreString = it
         newScore = it.text.toInt()
         },
         /*
          if it.text.toIntOrNull() != null {
          newScore = it.text.toInt()
          newScoreString =
          newScoreString.copy(
          newScore.in.toString()
          )
          }
          },
          */
         keyboardOptions = KeyboardOptions.Default.copy(
         keyboardType = KeyboardType.Number
         ),
         leadingIcon = {
         IconButton(action: {
         newScore.in += 1
         newScoreString =
         newScoreString.copy(
         newScore.in.toString(),
         selection = TextRange(
         0,
         newScore.in.toString().length
         )
         )
         }
         ) {
         Icon(Icons.Default.Add, "")
         }
         },
         trailingIcon = {
         Icon(painterResource(R.drawable.minus),
         contentDescription = "",
         modifier = Modifier
         .clickable {
         newScore.in -= 1
         newScoreString =
         newScoreString.copy(
         newScore.in.toString(),
         selection = TextRange(
         0,
         newScore.in.toString().length
         )
         )
         }
         )
         },
         modifier = Modifier
         .fillMaxWidth(1.0)
         .onKeyEvent {
         if it.nativeKeyEvent.keyCode == KeyEvent.KEYCODE_ENTER {
         addScore(
         playerIndex,
         newScore.in
         )
         newScore = 0
         newScoreString =
         newScoreString.copy(
         newScore.in.toString()
         )
         false
         }
         true
         }
         .focusRequester(scoreFocusRequester)
         .onFocusChanged { focusState ->
         if focusState.isFocused {
         @State var text = newScoNSLocalizedString("toString")()
         newScoreString =
         newScoreString.copy(
         selection = TextRange(
         0,
         text.length
         )
         )
         }
         }
         )
         HStack(
         horizontalArrangement = Arrangement.SpaceAround).fillMaxWidth(1.0) {
         Button(
         action: {
         addScore(playerIndex, newScore.in)
         newScore = 0
         newScoreString = newScoreString.copy(
         newScore.in.toString()
         )
         },
         content: {
         Icon(
         imageVector = Icons.Default.Done,
         contentDescription = ""
         )
         }
         )
         Button(
         action: {
         removePlayer = playerIndex
         showRemoveUser = true
         },
         content: {
         Icon(
         imageVector = Icons.Default.Clear,
         contentDescription = ""
         )
         }
         )
         }
         }
         }
         }
         }
         item {
         // new player
         @State var newName = ""
         @State var repeatWarning = false
         VStack(
         modifier = Modifier
         .fillMaxHeight(0.9)
         .fillParentMaxWidth(
         animateFloatAsState(
         targe =
         if (activePlayerIndex == -1)
         0.40
         else
         0.15,
         animationSpec = tween(durationMillis = 500)
         )
         )
         .padding(all = 5)
         .drawBehind {
         // top
         drawLine(
         Color.Black,
         Offset(-15.0, -15.0), Offset(size.width + 17.0, -15.0),
         3.toPx()
         )
         // right
         drawLine(
         Color.Black,
         Offset(size.width + 15.0, -15.0),
         Offset(size.width + 15.0, size.height + 15.0),
         3.toPx()
         )
         // bottom
         drawLine(
         Color.Black,
         Offset(-15.0, size.height + 15.0),
         Offset(size.width + 17.0, size.height + 15.0),
         3.toPx()
         )
         // left
         drawLine(
         Color.Black,
         Offset(-15.0, -15.0), Offset(-15.0, size.height + 15.0),
         3.toPx()
         )
         
         if activePlayerIndex == -1 {
         // right shadow
         Rectangle( /*
                     brush =
                     Brush.horizontalGradient(
                     listOf(Color(0x00.0FFFFF), Color(0x99333333)),
                     0.0, 30.0, TileMode.Mirror
                     ),
                     Offset(geo.size.width + 13.0, 7.0),
                     */
         ).frame(30.0, geo.size.height + 10.0)
         // bottom shadow
         Rectangle( /*
                     brush =
                     Brush.verticalGradient(
                     listOf(Color(0x99333333), Color(0x00.0FFFFF)),
                     10.0, 40.0, TileMode.Mirror
                     ),
                     Offset(5.0, geo.size.height + 12.0),
                     */
         ).frame(geo.size.width + 7.0, 30.0)
         // corner gradient
         Rectangle( /*
                     brush =
                     Brush.linearGradient(
                     listOf(Color(0x99.0FFFFF), Color(0x99666666)),
                     Offset(-10.0, -10.0), Offset(20.0, 20.0),
                     TileMode.Mirror
                     ),
                     Offset(geo.size.width + 12.0, geo.size.height + 16.0),
                     */
         ).frame(23.0, 23.0)
         }
         },
         content: {
         if activePlayerIndex.in != -1 {
         Image(
         painterResource(id = R.drawable.user),
         "",
         modifier = Modifier.clickable {
         activePlayerIndex = -1
         DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
         if !fromHistory {
         nameFocusRequester.requestFocus()
         }
         }, 100)
         }
         )
         } else {
         if !fromHistory {
         
         Text(NSLocalizedString("winner_label")).padding(5)
         HStack(verticalAlignment = Alignment.CenterVertically) {
         Text(NSLocalizedString("low_score"),
         style = TextStyle(fontSize = 14.sp)).padding(5)
         Switch(checked = winnerHighScore,
         onCheckedChange = {
         winnerHighScore = it
         currentGame.highScoreWinner =
         winnerHighScore
         currentGame.saveToPrefs(this@MainActivity)
         // reset winner
         if currentGame.players.count > 0 {
         activePlayerIndex = 0
         DispatchQueue.main.asyncAfter(deadline: .now() + 2.0)
         {
         activePlayerIndex = -1
         }
         }
         }
         )
         Text(NSLocalizedString("high_score"),
         style = TextStyle(fontSize = 14.sp)).padding(5)
         }
         BasicTextField(
         newName,
         textStyle = LocalTextStyle.current.merge(
         TextStyle(fontSize = 25.sp)
         ),
         keyboardOptions = KeyboardOptions.Default.copy(
         capitalization = KeyboardCapitalization.Words
         ),
         oChange = { currentName: String ->
         newName = currentName
         repeatWarning =
         currentGame.players.firstOrNull {
         it.name.startsWith(currentName)
         } != null
         },
         modifier = Modifier
         .width(IntrinsicSize.Min)
         .onKeyEvent {
         if it.nativeKeyEvent.keyCode == KeyEvent.KEYCODE_ENTER {
         addPlayer(newName)
         }
         false
         }
         .focusRequester(nameFocusRequester)
         )
         
         {
         TextFieldDefaults.DecorationBox(
         contentPadding = Paddins(3),
         = newName,
         enabled = true,
         placeholder = {
         Text(
         NSLocalizedString("name_hint"),
         style = LocalTextStyle.current.merge(
         TextStyle(fontSize = 25.sp)
         )
         )
         },
         innerTextField = it,
         singleLine = true,
         interactionSource = remember { MutableInteractionSource() },
         visualTransformation = VisualTransformation.None,
         trailingIcon = {
         IconButton(action: {
         newName = ""
         }) {
         Icon(
         Icons.Default.Clear,
         contentDescription = ""
         )
         }
         }
         )
         }
         if repeatWarning {
         Text(
         NSLocalizedString("name_exists")).width(IntrinsicSize.Min)
         }
         if newName.isNotEmpty() {
         Button(
         {
         addPlayer(newName)
         },
         content: {
         Icon(
         imageVector = Icons.Default.Done,
         contentDescription = ""
         )
         }).align(alignment = Alignment.CenterHorizontally)
         }
         }
         Button(
         action: {
         if fromHistory {
         resetCurrentGame(false)
         } else {
         
         if currentGame.players.firstOrNull() != null {
         showConfirmClose = true
         showSaveGame = false
         saveGameName = ""
         saveGame = false
         shareGame = false
         updateImage()
         }
         }
         },
         content: {
         Image(painterResource(R.drawable.finish), "")
         }).align(alignment = Alignment.CenterHorizontally)
         
         if !fromHistory {
         Button(
         action: {
         if currentGame.players.firstOrNull() != null {
         // pick random number between 3 times and 6 times number of players
         activePlayerIndex = 0
         showNextPlayer()
         }
         },
         content: {
         Text(NSLocalizedString("choose_first"))
         }).align(alignment = Alignment.CenterHorizontally)
         }
         }
         })
         }
         }
         }
         
         */
        GeometryReader { metrics in
            ScrollView()
            {
                HStack {
                    ForEach(0..<playersPlusAddCount, id: \.self) { playerIndex in
                        playerColumn(playerIndex: playerIndex, metrics: metrics)
                    }
                    VStack() {
                        GeometryReader{ settingsMetrics in
                            ZStack(alignment: .topLeading) {
                                
                                VStack() {
                                    if activePlayerIndex == -1 {
                                        /*
                                         
                                         // right shadow
                                         Rectangle(                                     brush =
                                         Brush.horizontalGradient(
                                         listOf(Color(0x00.0FFFFF), Color(0x99333333)),
                                         0.0, 30.0, TileMode.Mirror
                                         ),
                                         Offset(geo.size.width + 13.0, 7.0),
                                         ).frame(30.0, geo.size.height + 10.0)
                                         // bottom shadow
                                         Rectangle(
                                         brush =
                                         Brush.verticalGradient(
                                         listOf(Color(0x99333333), Color(0x00.0FFFFF)),
                                         10.0, 40.0, TileMode.Mirror
                                         ),
                                         Offset(5.0, geo.size.height + 12.0),
                                         ).frame(geo.size.width + 7.0, 30.0)
                                         // corner gradient
                                         Rectangle(
                                         brush =
                                         Brush.linearGradient(
                                         listOf(Color(0x99.0FFFFF), Color(0x99666666)),
                                         Offset(-10.0, -10.0), Offset(20.0, 20.0),
                                         TileMode.Mirror
                                         ),
                                         Offset(geo.size.width + 12.0, geo.size.height + 16.0),
                                         ).frame(23.0, 23.0)
                                         */
                                    }
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
                                            //.border(.purple, width: 12)
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
                                            //.border(.gray)
                                            
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
                                        }
                                        
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
                                                Image(systemName:  "flag.checkered")
                                            })
                                    }
                                }
                                .coordinateSpace(name: "Settings")
                                .frame(maxWidth: settingsWidth, maxHeight: metrics.size.height * 0.90,
                                       alignment: .topLeading
                                )
                                .padding(ContentView.cardPadding)
                                .border(.primary)
                                .zIndex(1)
                                settingsHorizontalShadow(settingsMetrics: settingsMetrics,
                                metrics: metrics)
                                .zIndex(2)
                                    .offset(x: ContentView.cardPadding,
                                        y: metrics.size.height * 0.9 + ContentView.cardPadding * 2)
                                    .frame(width: settingsWidth + ContentView.cardShadowWidth,
                                           height: ContentView.cardShadowWidth - ContentView.cardPadding)

                                settingsVerticalShadow(settingsMetrics: settingsMetrics,
                                metrics: metrics)
                                .zIndex(2)
                                .offset(x: settingsWidth + ContentView.cardPadding,
                                        y: ContentView.cardPadding)
                                .frame(width: ContentView.cardShadowWidth)
                            }
                        }

                        }
                    .frame(maxWidth: metrics.size.width * 0.95,
                           minHeight: metrics.size.height * 0.95,
                           maxHeight: metrics.size.height * 0.95,
                           alignment: .topLeading
                    )

                }
                //.border(.orange)
                /*
                 .fillParentMaxWidth(
                 animateFloatAsState(
                 targe =
                 if (activePlayerIndex == -1)
                 0.40
                 else
                 0.15,
                 animationSpec = tween(durationMillis = 500)
                 )
                 )
                 */
                .padding(5)
                /*
                 .drawBehind {
                 // top
                 drawLine(
                 Color.Black,
                 Offset(-15.0, -15.0), Offset(size.width + 17.0, -15.0),
                 3.toPx()
                 )
                 // right
                 drawLine(
                 Color.Black,
                 Offset(size.width + 15.0, -15.0),
                 Offset(size.width + 15.0, size.height + 15.0),
                 3.toPx()
                 )
                 // bottom
                 drawLine(
                 Color.Black,
                 Offset(-15.0, size.height + 15.0),
                 Offset(size.width + 17.0, size.height + 15.0),
                 3.toPx()
                 )
                 // left
                 drawLine(
                 Color.Black,
                 Offset(-15.0, -15.0), Offset(-15.0, size.height + 15.0),
                 3.toPx()
                 )
                 }
                 */
            }
            .frame(maxHeight: metrics.size.height * 0.95,
                   alignment: .topLeading)
            //.border(.red)
            .onChange(of: activePlayerIndex, {
                if activePlayerIndex == -1 {
                    settingsWidth = 200.0
                } else {
                    settingsWidth = metrics.size.width * 0.150
                }
                for playerIndex in 0..<playersPlusAddCount {
                    if playerIndex == activePlayerIndex {
                        playerWidths[playerIndex] = metrics.size.width * 0.4
                    } else {
                        playerWidths[playerIndex] = metrics.size.width * 0.150
                    }
                }
                fieldFocus = .score
                DispatchQueue.main.async {
                    UIApplication.shared.sendAction(#selector(UIResponder.selectAll(_:)), to: nil, from: nil, for: nil)
                }
                
            })
        }
    }
}

#Preview {
    ContentView()
}
