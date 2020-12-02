{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE OverloadedStrings #-}

module GameState 
    (
        GameState(..),
        tryApplyTurn,
        newGameState,
        getGlobalBoard,
        getLastPlayerTurn
    ) where

import GameBoard(GlobalBoard, getBoardCell, emptyGlobalBoard)
import PlayerTurn
import BoardSegment
import Player (Player(..))
import BoardSegmentState (BoardSegmentState(..))

import Data.Maybe
import Data.Aeson (ToJSON, toJSON, object, (.=))
import GHC.Generics (Generic)
import Data.Swagger (ToSchema)

{-|
    Состояние игры.
    Описывается как глобальное поле и последний ход одного из игроков.
-}
data GameState = GameState GlobalBoard (Maybe PlayerTurn) deriving (Eq, Show, Generic)

instance ToJSON GameState where
    toJSON (GameState globalBoard playerTurn) = object
        [
            "GameBoard" .= globalBoard,
            "LastPlayerTurn" .= playerTurn
        ]

instance ToSchema GameState

{-|
    Конструктор новой игровой партии.
-}
newGameState :: GameState
newGameState = GameState emptyGlobalBoard Nothing

{-|
    Сообщение об ошибке выполнения операции.
-}
type ErrorMessage = String

{-|
    Попытаться применить ход к состоянию игры.
-}
tryApplyTurn :: PlayerTurn -> GameState -> Either ErrorMessage GameState
tryApplyTurn playerTurn gameState
    | turnCanBeAppliedToState playerTurn gameState = Right $ applyTurnToState playerTurn gameState
    | otherwise = Left "turn can't be applied!"

{-|
    Определить, может ли ход быть применен к состоянию игры.
-}
turnCanBeAppliedToState :: PlayerTurn -> GameState -> Bool

{-|
    Считаем, что первым всегда ходит 'X'.
-}
turnCanBeAppliedToState currentTurn (GameState _ Nothing) = player currentTurn == X

{-|
     В общем случае ход может быть применен к состоянию игры, если:
     1. Предыдущий ход выполнял другой игрок.
     2. Текущий ход может быть применен к глобальному полю.
     3. а) Позиция локального поля соответствует позиции ячейки предыдущего хода.
        - или -
        б) Предыдущий ход определил недоступное локальное поле.
-}
turnCanBeAppliedToState currentTurn (GameState globalBoard (Just previousTurn)) =
    player currentTurn /= player previousTurn
    && turnCanBeApplied currentTurn globalBoard
    && (localPosition previousTurn == globalPosition currentTurn || previousTurnDirectedToOwned)
    where
        previousTurnDirectedToOwned = case state localBoardSetByPreviousTurn of
            Owned _ -> True
            Free -> False
        localBoardSetByPreviousTurn = getBoardCell (localPosition previousTurn) globalBoard

{-|
    Применить ход к состоянию игры.
-}
applyTurnToState :: PlayerTurn -> GameState -> GameState
applyTurnToState playerTurn (GameState globalBoard _) =
    GameState (applyTurn playerTurn globalBoard)
    $ Just playerTurn

{-|
    Получить глобальное поле из состояния игры.
-}
getGlobalBoard :: GameState -> GlobalBoard
getGlobalBoard (GameState global _) = global

getLastPlayerTurn :: GameState -> Maybe PlayerTurn
getLastPlayerTurn (GameState global turn) = turn