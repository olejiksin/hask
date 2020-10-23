module Game(
paintLine,
checkTriangle,
initialState
) where

import Types
import Data.List
import Data.Either
import Data.Matrix

paintLine::GameState -> Draw -> Either String GameState
paintLine state line=

checkTriangle::GameState -> Bool
checkTriangle state=

initialState::GameState
initialState = GameState{ players=[Player{Id=1,coloredLines=Nothing, gotTriangle=False,color=Green},
Player{Id=2,coloredLines=Nothing, gotTriangle=False,color=Blue}],
move=0,
whoseMove=1,
triangle=False,
lines=[]}


