module Game where

import Types
import Data.List
import Data.Either
import Data.Maybe

--закрашивание линии игроком
paintLine:: GameState -> Line -> Player -> Either String GameState
paintLine gs line player = 
 let m = id player
 let k = fromJust (elemIndex line (lines gs))
 let colorLine = line{color = color player}
 if color line == Black
  then do 
   colorLine : coloredLines player
   Right $ gs{
   move = (move gs + 1) `mod` (length $ players gs),
   lines = take k (lines gs) ++ [colorLine] ++ drop(k+1) (lines gs),
   players = take m (players gs) ++ [player] ++ drop(m+1) (players gs)}
  else Left "Already colored"

--получение connection линий 
pars::[Line]->[[Int]]
pars [] = []
pars a = [connection (head a)] ++ pars (tail a)

--тип со всеми случаями появления треугольников
data Triangles=Triangles{trian::[[[Int]]]}deriving(Show)
triangles=Triangles{
trian=[[[1,2],[2,3],[1,3]],
[[1,2],[2,4],[1,4]],
[[1,2],[2,5],[1,5]],
[[1,2],[2,6],[1,6]],
[[1,3],[3,4],[1,4]],
[[1,3],[3,5],[1,5]],
[[1,3],[3,6],[1,6]],
[[1,4],[4,5],[1,5]],
[[1,4],[4,6],[1,6]],
[[1,5],[5,6],[1,6]],
[[2,3],[3,4],[2,4]],
[[2,4],[4,5],[2,5]],
[[2,5],[5,6],[2,6]],
[[2,3],[3,5],[2,5]],
[[2,3],[3,6],[2,6]],
[[3,4],[4,6],[3,6]],
[[3,4],[4,5],[3,5]],
[[3,5],[5,6],[3,6]],
[[4,5],[5,6],[4,6]]]}
	
--проверка на наличие треугольника после закрашивания линии
checkTriangle:: [Player] -> GameState -> [[a]] -> Either String GameState
checkTriangle players gs a = 
 let results = [contains (trian triangles) (pars(coloredLines players!!0))] ++ [contains (trian triangles) (pars(coloredLines players!!1))]
 if (results!!0 == True) || (results!!1 == True)
  then do if results!!0 == True
           then Right $ gs{result=1}
		   else Right $ gs{result=2}
  else Left "No triangle or some error"


containt::[[Int]]->[[Int]]->Bool
containt [] b = True
containt a b = (head a) `elem` b && containt (tail a) b


--проверка наличия элементов списка [[[a]]] в другом списке [[b]]
contains::[[[Int]]]->[[Int]]->Bool
contais [] b = True
contains a b =  containt (head a) b && contains (tail a) b


--инициализация начального состояния
initialState::GameState
initialState = GameState
--инициализация двух игроков
{ players=[Player{id=1,coloredLines=Nothing,color=Green},
Player{id=2,coloredLines=Nothing,color=Blue}],
--номер хода
move=0,
--id игрока, который победил(1 или 2, 0 - default) 
result=0,
--есть ли закрашенный треугольник
triangle=False,
--список всех линий
lines=[
Line{color=Black,connection=[1,2]},
Line{color=Black,connection=[1,3]},
Line{color=Black,connection=[1,4]},
Line{color=Black,connection=[1,5]},
Line{color=Black,connection=[1,6]},
Line{color=Black,connection=[2,3]},
Line{color=Black,connection=[2,4]},
Line{color=Black,connection=[2,5]},
Line{color=Black,connection=[2,6]},
Line{color=Black,connection=[3,4]},
Line{color=Black,connection=[3,5]},
Line{color=Black,connection=[3,6]},
Line{color=Black,connection=[4,5]},
Line{color=Black,connection=[4,6]},
Line{color=Black,connection=[5,6]}]}


