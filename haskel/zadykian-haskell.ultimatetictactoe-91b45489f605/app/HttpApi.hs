{-# LANGUAGE TypeOperators #-}
{-# LANGUAGE DataKinds #-}

module HttpApi where


import Servant.API
import Servant.Swagger.UI (SwaggerSchemaUI)

import GameBoard
import AtomicCell
import BoardSegmentState
import Data.Either
import Data.List
import Data.Maybe
import Player
import GameState 
import PlayerTurn 
import Data.UUID (UUID)
import Data.Proxy (Proxy(..))


import Debug.Trace
{-|
    Декларация HTTP Api, содержащая сигнатуры всех методов.
-}
type HttpApi =
    {-|
        Создать новую игру на сервере.
        Клиенту возвращается UUID созданной игры.
    -}
    "CreateNewGame"
        :> Post '[JSON] UUID

    {-|
        Получить состояние игры по идентификатору.
        В случае отсутствия на сервере игры с переданным UUID клиенту возвращается код 400 BadRequest.
    -}
    :<|> "GetGameState"
        :> Header "Game-Uuid" UUID
        :> Get '[JSON] GameState

    {-|
        Применить ход к состоянию игры.
        В случае передачи некорректного хода клиенту возвращается код 400 BadRequest.
    -}
    :<|> "ApplyTurnToGameState"
        :> Header "Game-Uuid" UUID
        :> ReqBody '[JSON] PlayerTurn
        :> Post '[JSON] GameState

    :<|> "BotMove"
        :> Header "Game-Uuid" UUID
        :> ReqBody '[JSON] PlayerTurn
        :> Post '[JSON] GameState   

{-|
    API для доступа к SwaggerUI.
-}
type SwaggerApi = SwaggerSchemaUI "swagger-ui" "swagger.json"

{-|
    Общий API приложения (методы для взаимодействия с игрой + swagger).
-}
type HttpApiWithSwagger = HttpApi :<|> SwaggerApi

{-|
    Прокси API сервера.
-}
apiProxy :: Proxy HttpApiWithSwagger
apiProxy = Proxy


--Bot

allWinLines :: [[Int]]
allWinLines = [[0, 1, 2], [3, 4, 5], [6, 7, 8], [0, 3, 6], [1, 4, 7], [2, 5, 8], [0, 4, 8], [2, 4, 6]]

--проверка на свободность всех трех элементов для победной линии   
checkWinLine :: [Int] -> GameState -> Player -> Int -> Either String [Int]
checkWinLine cells gs player move = do
   case tryApplyTurn (PlayerTurn (map toEnum [cells!!move, 0]) (player)) gs of
    Left error -> do
     Left $ error
    Right modifiedGame -> do
     if (move) == 2
      then Right $ cells
      else checkWinLine cells gs player (move+1)

-- проверка наличия свободных выигрышных линий в сегменте 
checkMove :: [[Int]] -> GameState -> Player -> Either String [Int]
checkMove [] gs player = Left "No moves"
checkMove list gs player = do 
 case checkWinLine (head list) gs player 0 of
  Left error -> checkMove (tail list) gs player 
  Right moves -> return moves

-- кол-во свободных клеток в сегменте
freeCounter:: Int -> GameState -> Player -> Int -> Int -> Int
freeCounter cell gs player 9 countOfFree = countOfFree
freeCounter cell gs player localCell countOfFree = do
 if (AtomicCell $ Free) == (getBoardCell (toEnum (localCell)) (getBoardCell (toEnum cell) (getGlobalBoard gs)))
  then freeCounter cell gs player (localCell+1) (countOfFree-1) 
  else freeCounter cell gs player (localCell+1) countOfFree 

-- выбор сегмента глобальной доски по максильному кол-ву свободных клеток
choseBetter :: [Int] -> GameState -> Player -> Int
choseBetter list gs player = do
 let coun = [(freeCounter (list!!0) gs player 0 9), (freeCounter (list!!1) gs player 0 9), (freeCounter (list!!2) gs player 0 9)] 
 let result = fromJust (elemIndex (maximum coun) coun) 
 list!!result

choseAnyAvailablePosition::GameState -> Player -> Int -> Int ->Either String Int 
choseAnyAvailablePosition gs player 9 9 = Left $ "LOSED"
choseAnyAvailablePosition gs player global 9 = choseAnyAvailablePosition gs player (global+1) 0 
choseAnyAvailablePosition gs player global local =
 case tryApplyTurn (PlayerTurn (map toEnum [global, local]) player) gs of
  Left error -> do 
   choseAnyAvailablePosition gs player global (local+1)  
  Right modifiedGame -> do
   Right $ global


--массив из AtomicCell для сегмента доски [x,o,_,_..., x]
getOwnedCells :: GameState -> Int -> Int -> [AtomicCell]
getOwnedCells gs global 9 = []
getOwnedCells gs global cell = 
 [(getBoardCell (toEnum cell) (getBoardCell (toEnum global)(getGlobalBoard gs)))] ++ (getOwnedCells gs global (cell+1)) 
  
--если клетка занята ботов - вернуть 10, противник - 1, никто - 0
stateReturner :: AtomicCell -> Player -> Int
stateReturner atomic player =
 if atomic == (AtomicCell $ Owned ((delete player [X,O])!!0))
  then 1
  else 
   if atomic == (AtomicCell $ Owned player)
    then 10
    else 0

-- если >=20 - близок к выигрышу бот , == 2 - близок противник
stateCoun::[AtomicCell] ->Player -> Int
stateCoun [] player = 0
stateCoun atomic player = 
 (stateReturner (atomic!!0) player) + (stateCoun (tail atomic) player)

--массив, чтобы определить близость выигрыша линии одной из стороны
stateCounterInWinLine :: [[AtomicCell]] ->Player -> [Int]
stateCounterInWinLine [] player = []
stateCounterInWinLine atomic player = 
 [(stateCoun (atomic!!0) player)] ++ stateCounterInWinLine (tail atomic) player

getCellStates :: [AtomicCell] -> [[Int]] -> [[AtomicCell]]
getCellStates atomicList [] = []
getCellStates atomicList list = 
 [[atomicList!!((head list)!!0), atomicList!!((head list)!!1), atomicList!!((head list)!!2)]] ++ getCellStates atomicList (tail list)
  

--перекрыть победу линии противнику
breakEnemyMove :: [Int] -> GameState -> Int -> Int -> Int
breakEnemyMove list gs global 3 = 9
breakEnemyMove list gs global index =
 if (AtomicCell $ Free) == (getBoardCell (toEnum (list!!index)) (getBoardCell (toEnum global) (getGlobalBoard gs)))
  then list!!index
  else breakEnemyMove list gs global (index + 1)
  
--забрать линию себе
makeWin:: [Int] -> GameState -> Int -> Int -> Int
makeWin list gs global 3 = 9
makeWin list gs global index = 
 if (AtomicCell $ Free) == (getBoardCell (toEnum (list!!index)) (getBoardCell (toEnum global) (getGlobalBoard gs)))
  then list!!index
  else makeWin list gs global (index + 1)
   
findMaxOrMin :: GameState ->[Int] -> Int -> Int -> Int
findMaxOrMin gs [] global index = 9
findMaxOrMin gs list global index = do
 let n = (list!!0) `mod` 10
 if (list!!0) >= 20
  then 
   makeWin (allWinLines!!index) gs global 0
  else 
   if n == 2
    then 
     breakEnemyMove (allWinLines!!index) gs global 0
    else 
     findMaxOrMin gs (tail list) global (index + 1)

choseAnyLocal::GameState -> Player -> Int-> Int ->Int
choseAnyLocal gs player global local =
 case tryApplyTurn (PlayerTurn (map toEnum [global, local]) player) gs of
  Left error -> do
   choseAnyLocal gs player global (local+1)
  Right modifiedGame -> do
   local
  
-- выбор хода для локальной доски
findBetterLocalPos::GameState -> Player -> Int -> Int
findBetterLocalPos gs player global = do
 let cellStates = getCellStates (getOwnedCells gs global 0) allWinLines
 trace ("segment: "++ show global ++" again list :" ++ show cellStates) $ do
  let stR = stateCounterInWinLine cellStates player
  trace ("list : " ++ show stR) $ do
   let result = findMaxOrMin gs stR global 0
   trace ("RESULT " ++ show result) $ do
    if result /=9
     then result
     else choseAnyLocal gs player global 0

-- выбор глобальной позиции
checkGlobal::GameState -> Player -> Int
checkGlobal gs player = do
 let turn = getLastPlayerTurn gs 
 case turn of 
  Just turn -> do
   let first = fromEnum(localPosition (turn))
   case tryApplyTurn (PlayerTurn (map toEnum [first, 0]) (player)) gs of
    Left error -> do
     case tryApplyTurn (PlayerTurn (map toEnum [4, 0]) (player)) gs of
      Left error -> do
       case checkMove allWinLines gs player of 
        Left error -> do 
         head (rights [choseAnyAvailablePosition gs player 0 0])
        Right newPosition ->  (choseBetter newPosition gs player)
      Right modifiedGame -> do
        4
    Right modifiedGame -> do
      first
  Nothing -> do
    4

checkLocal:: GameState -> Player -> Int -> Int
checkLocal gs player globalPo =  do
 if (getLastPlayerTurn gs) == Nothing
  then 4
 else 
  case tryApplyTurn (PlayerTurn (map toEnum[globalPo, 4]) (player)) gs of
   Left error -> do
    findBetterLocalPos gs player globalPo
   Right modifiedGame -> do
    4

generateBotMove :: Player -> GameState -> PlayerTurn
generateBotMove player gs = do
 let global = checkGlobal gs player
 let local  = checkLocal  gs player global
 PlayerTurn (map toEnum[global,local]) (player) 

