module BoardSegment where

import BoardSegmentState
import PlayerTurn

{-|
    Класс типов сегмента игровой доски.
-}
class BoardSegment segment where

    -- | Получить состояние сегмента доски.
    state :: segment -> BoardSegmentState

    -- | Определить, может ли ход игрока быть применён к сегменту.
    turnCanBeApplied :: PlayerTurn -> segment -> Bool

    -- | Применить ход игрока к сегменту.
    applyTurn :: PlayerTurn -> segment -> segment