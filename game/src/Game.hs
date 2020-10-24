module Game(
paintLine,
checkTriangle,
initialState
) where

import Types
import Data.List
import Data.Either
import Data.Matrix

--закрашивание линий игроком
paintLine::Draw -> Player -> Either String GameState
paintLine line player = 
	if color line == "Black"
	then colorLine : coloredLines player
		Right $
		where colorLine = line{color = color player }
	else Left "Already colored"
	
--проверка на наличие треугольника после закрашивания линии
checkTriangle::[Player] -> Bool
checkTriangle players =

--инициализация начального состояния
initialState::GameState
initialState = GameState{ players=[Player{id=1,coloredLines=Nothing, gotTriangle=False,color=Green},
Player{id=2,coloredLines=Nothing, gotTriangle=False,color=Blue}],
move=0,
whoseMove=1,
triangle=False,
lines=[]}


