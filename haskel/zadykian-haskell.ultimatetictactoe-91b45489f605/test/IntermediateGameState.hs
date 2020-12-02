module IntermediateGameState where

import GameState
import BoardSegmentState
import GameBoard
import Player
import PlayerTurn
import AtomicCell

-- Состояние игры на промежуточной стадии партии.
intermediateGameState :: GameState
intermediateGameState = GameState intermediateGlobalBoard $ Just $ PlayerTurn [toEnum 5, toEnum 8] O
    where
        {-
            Глобальное поле на промежуточной стадии партии:

                X__ | _OO | O_X
                _X_ | _X_ | _OX
                __X | X__ | _XO
                ---------------
                OOO | _X_ | _OX
                X_X | OXO | XO_
                XXO | OX_ | __O
                ---------------
                XO_ | OOO | __X
                _O_ | ___ | _OO
                __X | X_X | O__
        -}
        intermediateGlobalBoard = GameBoard $ map createLocalBoard
            [
                -- LocalBoard '0'
                [
                    Owned X, Free, Free,
                    Free, Owned X, Free,
                    Free, Free, Owned X
                ],
                -- LocalBoard '1'
                [
                    Free, Owned O, Owned O,
                    Free, Owned X, Free,
                    Owned X, Free, Free
                ],
                -- LocalBoard '2'
                [
                    Owned O, Free, Owned X,
                    Free, Owned O, Owned X,
                    Free, Owned X, Owned O
                ],
                -- LocalBoard '3'
                [
                    Owned O, Owned O, Owned O,
                    Owned X, Free, Owned X,
                    Owned X, Owned X, Owned O
                ],
                -- LocalBoard '4'
                [
                    Free, Owned X, Free,
                    Owned O, Owned X, Owned O,
                    Owned O, Owned X, Free
                ],
                -- LocalBoard '5'
                [
                    Free, Owned O, Owned X,
                    Owned X, Owned O, Free,
                    Free, Free, Owned O
                ],
                -- LocalBoard '6'
                [
                    Owned X, Owned O, Free,
                    Free, Owned O, Free,
                    Free, Free, Owned X
                ],
                -- LocalBoard '7'
                [
                    Owned X, Free, Free,
                    Free, Owned O, Free,
                    Owned X, Free, Owned X
                ],
                -- LocalBoard '8'
                [
                    Free, Free, Owned X,
                    Free, Owned O, Owned O,
                    Owned O, Free, Free
                ]
            ]

createLocalBoard :: [BoardSegmentState] -> LocalBoard
createLocalBoard stateList = GameBoard $ map AtomicCell stateList
