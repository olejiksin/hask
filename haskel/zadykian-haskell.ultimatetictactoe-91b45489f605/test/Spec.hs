import Test.HUnit
import IntermediateGameState

import GameBoard
import AtomicCell
import BoardSegmentState
import Player
import PlayerTurn
import BoardSegment
import GameState

main :: IO Counts
main = runTestTT $ TestList $ map (uncurry TestLabel)
    [
        ("empty local board creation", createEmptyLocalBoard),
        ("empty global board creation", createEmptyGlobalBoard),
        ("apply turn to empty local board", applyTurnToEmptyLocalBoard),
        ("apply turn to empty global board", applyTurnToEmptyGlobalBoard),

        ("board is owned by X", localBoardIsOwned),
        ("apply turn of X to game state", applyTurnToGameState),
        ("second turn of player 'O'", rejectSecondTurnOfSamePlayer),
        ("invalid local board", rejectWrongLocalBoardTurn)
    ]

{-|
    Тест создания пустого локального поля.
-}
createEmptyLocalBoard :: Test
createEmptyLocalBoard = TestCase (
    assertEqual "emptyLocalBoard"
        (GameBoard $ replicate 9 $ AtomicCell Free)
        emptyLocalBoard
    )

{-|
    Тест создания пустого глобального поля.
-}
createEmptyGlobalBoard :: Test
createEmptyGlobalBoard = TestCase (
    assertEqual "emptyGlobalBoard"
        (GameBoard $ replicate 9 emptyLocalBoard)
        emptyGlobalBoard
    )

{-|
    Применить ход к пустому локальному полю.
-}
applyTurnToEmptyLocalBoard :: Test
applyTurnToEmptyLocalBoard = TestCase (
    assertEqual "turn to empty local board"
        (GameBoard $ AtomicCell (Owned X) : replicate 8 emptyAtomicCell)
        (applyTurn playerTurn emptyLocalBoard)
    )
    where playerTurn = PlayerTurn [toEnum 0] X

{-|
    Применить ход к пустому глобальному полю.
-}
applyTurnToEmptyGlobalBoard :: Test
applyTurnToEmptyGlobalBoard = TestCase (
    assertEqual "turn to empty global board"
        (GameBoard $ modifiedLocalBoard : replicate 8 emptyLocalBoard)
        (applyTurn playerTurn emptyGlobalBoard)
    )
    where
        playerTurn = PlayerTurn [toEnum 0, toEnum 4] O
        modifiedLocalBoard = GameBoard $
            replicate 4 emptyAtomicCell ++
            [AtomicCell (Owned O)] ++
            replicate 4 emptyAtomicCell

{-|
    Получить состояние локального поля, захваченного игроком X.
-}
localBoardIsOwned :: Test
localBoardIsOwned = TestCase (
    assertEqual "local board is owned"
        (Owned X)
        (state localBoard)
    )
    where
        localBoard = GameBoard $ map AtomicCell
            [
                Owned X, Free, Free,
                Free, Owned X, Free,
                Free, Free, Owned X
            ]

{-|
    Применить ход игрока 'X' к состоянию игры.
-}
applyTurnToGameState :: Test
applyTurnToGameState = TestCase (
    assertEqual "apply turn of X"
        (Right gameStateAfterTurn)
        (tryApplyTurn currentPlayerTurn intermediateGameState)
    )
    where
        currentPlayerTurn = PlayerTurn [toEnum 8, toEnum 3] X
        gameStateAfterTurn = GameState globalBoardAfterTurn $ Just currentPlayerTurn

        {-
            Глобальное поле после применения хода:

                X__ | _OO | O_X
                _X_ | _X_ | _OX
                __X | X__ | _XO
                ---------------
                OOO | _X_ | _OX
                X_X | OXO | XO_
                XXO | OX_ | __O
                ---------------
                XO_ | OOO | __X
                _O_ | ___ | XOO
                __X | X_X | O__
        -}
        globalBoardAfterTurn = GameBoard $ map createLocalBoard
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
                    Owned X, Owned O, Owned O,
                    Owned O, Free, Free
                ]
            ]

{-|
    Отвергнуть попытку совершения повторного хода.
-}
rejectSecondTurnOfSamePlayer :: Test
rejectSecondTurnOfSamePlayer = TestCase (
    assertEqual "second turn of O"
        (Left "turn can't be applied!")
        (tryApplyTurn currentPlayerTurn intermediateGameState)
    )
    where currentPlayerTurn = PlayerTurn [toEnum 8, toEnum 3] O

{-|
    Отвернуть попытку совершения хода с некорректным локальным полем.
-}
rejectWrongLocalBoardTurn :: Test
rejectWrongLocalBoardTurn = TestCase (
    assertEqual "invalid local board"
        (Left "turn can't be applied!")
        (tryApplyTurn currentPlayerTurn intermediateGameState)
    )
    where currentPlayerTurn = PlayerTurn [toEnum 1, toEnum 3] O