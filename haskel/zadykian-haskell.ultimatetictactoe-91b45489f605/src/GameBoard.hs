{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE OverloadedStrings #-}

module GameBoard where

import AtomicCell
import BoardSegment
import BoardSegmentState
import CellPosition
import Player
import PlayerTurn
import Control.Lens hiding ((.=))

import Data.Aeson
import GHC.Generics (Generic)
import Data.Swagger.Internal.Schema (ToSchema)

{-|
    Игровое поле, состоящее из девяти ячеек.
-}
newtype GameBoard cell = GameBoard [cell] deriving (Eq, Show, Generic)

{-|
    Получить ячейку игрового поля по позиции CellPosition.
-}
getBoardCell :: CellPosition -> GameBoard cell -> cell
getBoardCell position (GameBoard cellList) = cellList !! fromEnum position

{-|
    Локальное игровое поле.
-}
type LocalBoard = GameBoard AtomicCell

instance ToSchema LocalBoard

{-|
    Конструктор пустого локального поля.
-}
emptyLocalBoard :: LocalBoard
emptyLocalBoard = GameBoard $ replicate 9 emptyAtomicCell


{-|
    Глобальное игровое поле.
-}
type GlobalBoard = GameBoard LocalBoard

instance ToSchema GlobalBoard

{-|
    Конструктор пустого глобального поля.
-}
emptyGlobalBoard :: GlobalBoard
emptyGlobalBoard = GameBoard $ replicate 9 emptyLocalBoard


{-|
    Представитель класса типов BoardSegment для типа [GameBoard cell],
    причем вложенная в GameBoard ячейка также должна являться представителем класса BoardSegment.

    Образуется следующая вложенность типов:
    GlobalBoard --> LocalBoard --> AtomicCell.
-}
instance (BoardSegment cell) => BoardSegment (GameBoard cell) where

    -- | Получить состояние сегмента доски.
    state gameBoard
        | containsOwnedLine gameBoard X = Owned X
        | containsOwnedLine gameBoard O = Owned O
        | otherwise = Free
        where
            -- Содержит ли игровое поле линию выигрыша одного из игроков.
            containsOwnedLine :: (BoardSegment cell) => GameBoard cell -> Player -> Bool
            containsOwnedLine (GameBoard cellList) playerOwner = allPossibleLines & any lineIsOwned
                where
                    -- Принадлежит ли линия, представленная в виде списка индексов доски, игроку playerOwner.
                    lineIsOwned :: [Int] -> Bool
                    lineIsOwned = all (segmentIsOwned . (cellList !!))

                    -- Принадлежит ли сегмент игроку playerOwner.
                    segmentIsOwned :: BoardSegment cell => cell -> Bool
                    segmentIsOwned boardSegment = state boardSegment == Owned playerOwner

                    -- Все возможные линии выигрыша на доске, представленные в виде списков индексов.
                    allPossibleLines =
                        [
                            -- Горизонтальные линии.
                            [0, 1, 2], [3, 4, 5], [6, 7, 8],
                            -- Вертикальные линии.
                            [0, 3, 6], [1, 4, 7], [2, 5, 8],
                            -- Диагонали.
                            [0, 4, 8], [2, 4, 6]
                        ]

    -- | Определить, может ли ход игрока быть применён к сегменту.
    turnCanBeApplied (PlayerTurn (currentPosition : nestedPositions) playerOfTurn) currentBoardSegment
        = state currentBoardSegment == Free && turnCanBeApplied (PlayerTurn nestedPositions playerOfTurn) nextSegment
        -- Следующий по вложенности сегмент доски.
        where nextSegment = getBoardCell currentPosition currentBoardSegment

    turnCanBeApplied _ _ = error "Player turn must contain CellPosition!"

    -- | Применить ход к сегменту доски.
    applyTurn (PlayerTurn (currentPosition : nestedPositions) playerOfTurn) gameBoard@(GameBoard cellList)
        = GameBoard $ cellList & element (fromEnum currentPosition) .~ affectedInnerSegment
        where
            -- Результат применения хода к nextSegment.
            affectedInnerSegment = applyTurn (PlayerTurn nestedPositions playerOfTurn) nextSegment
            -- Следующий по вложенности сегмент доски.
            nextSegment = getBoardCell currentPosition gameBoard

    applyTurn _ _ = error "Player turn must contain CellPosition!"

{-|
    Представитель класса типов ToJSON для типа [GameBoard cell].
-}
instance (BoardSegment cell, ToJSON cell) => ToJSON (GameBoard cell) where
    toJSON gameBoard@(GameBoard cellList) = object 
        [
            "CellList" .= cellList,
            "SegmentState" .= state gameBoard 
        ]
