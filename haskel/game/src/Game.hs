module Game where

import Types
import Control.Monad
import Data.List
import Data.Either
import Data.Maybe


--закрашивание линии игроком
paintLine:: GameState -> Line -> Either String GameState
paintLine gs line = 
 let 
  player = (players gs)!!(move gs)
  m = numb player
  k = fromJust (elemIndex line (gameLines gs))
  colorLine = Line{colorForLine = color player,connection = connection line}
  updatePlayer = player{coloredLines = (coloredLines player) ++ [colorLine]}
  updPlayers = if m==1
         then [(players gs)!!0, updatePlayer]
         else [updatePlayer, (players gs)!!1]
  gss = gs{
     move = (move gs + 1) `mod` (length $ players gs),
     gameLines = take k (gameLines gs) ++ [colorLine] ++ drop(k+1) (gameLines gs),
     players = updPlayers} 
 in if colorForLine line == Black
    then do 
     Right $ checkTriangle (players gss) gss
    else Left "Already colored"


--проверка на наличие треугольника после закрашивания линии
checkTriangle:: [Player] -> GameState -> GameState
checkTriangle pla gss = do
 let results = [contains (trian triangles) (pars(coloredLines (pla!!0)))] ++ [contains (trian triangles) (pars(coloredLines (pla!!1)))]
 if (results!!0 == True) || (results!!1 == True)
  then do if (results!!0) == True
           then gss{result=0,triangle=True}
           else gss{result=1,triangle=True}
  else gss{result=2}


--получение connection линий 
pars::[Line]->[[Int]]
pars [] = []
pars a = [connection (head a)] ++ pars (tail a)

-- генерация способов получения треугольника , например [1,2][2,4][1,4]
againCombin::Int -> Int -> Int ->[[[Int]]]
againCombin a b (-1) = []
againCombin a b c = do
 lin <- [generateLines 1] 
 againCombin a b (c-1) ++ if ((connection (lin!!a))!!0 == (connection (lin!!c))!!0) && ((connection (lin!!a))!!1 == (connection (lin!!b))!!0)&& 
  ((connection (lin!!b))!!1 == (connection (lin!!c))!!1) && 
  (((connection (lin!!a)) /= (connection (lin!!b)))) && (((connection (lin!!c)) /= (connection (lin!!b))))  
 then [[connection (lin!!a), connection (lin!!b), connection (lin!!c)]]
 else []

combin::Int -> Int -> Int ->[[[Int]]]
combin a (-1) c = []
combin a b c = combin a (b-1) c ++ againCombin a b c

comb::Int -> Int -> Int ->[[[Int]]]
comb (-1) b c = []
comb a b c = comb (a-1) b c ++ combin a b c 

check::Int -> [[[Int]]]
check 0 = []
check n =nub( comb (n-1) (n-1) (n-1) ++ check (n-1))
 

--тип со всеми случаями появления треугольников
data Triangles=Triangles
 {
 trian::[[[Int]]]
 }deriving(Show)

triangles=Triangles{
 trian= check 15
 }


containt::[[Int]]->[[Int]]->Bool
containt [] b = True
containt a b = containt (tail a) b && (head a) `elem` b
--проверка наличия элементов списка [[[a]]] в другом списке [[b]]
contains::[[[Int]]]->[[Int]]->Bool
contains [] b = False
contains a b = contains (tail a) b || containt (head a) b

--генерация списка линий
genLin::Int -> Int -> [Line]
genLin n 7 = []
genLin 7 n = []
genLin n b = [Line{colorForLine=Black,connection = [n, b]}] ++ genLin n (b+1)

generateLines:: Int -> [Line]
generateLines 7 = [] 
generateLines n = [] ++ genLin n (n+1) ++ generateLines (n+1)


--инициализация начального состояния
initialState::GameState
initialState = GameState
 --инициализация двух игроков
 { players = [
  Player{numb=0,coloredLines=[],color=Green},
  Player{numb=1,coloredLines=[],color=Red}],
 --чей ход
 move=0,
 --numb игрока, который победил(0 или 1, 2 - default) 
 result=2,
 --есть ли закрашенный треугольник
 triangle=False,
 --список всех линий
 gameLines= generateLines 1 }
