
import Test.Tasty
import Test.Tasty.HUnit hiding (assert)
import Test.Tasty.Hedgehog

import Hedgehog
import qualified Hedgehog.Gen as Gen
import qualified Hedgehog.Range as Range

import Types
import Game

main :: IO ()
main = defaultMain tests

tests :: TestTree
tests = testGroup "Tests"
 [
   testGroup "change lineColor" lineColorTest,
   testGroup "check existTriangle" triangleTest
 ]
 

lineColorTest::[TestTree]
lineColorTest =
 [
  testCase "not colored line" $ do
   let player = Player{numb=1,color=Green, coloredLines=[]}
   let defaultLine = Line{colorForLine=Black, connection=[1,2]}
   let coloredLine = Line{colorForLine=Green, connection=[1,2]}
   let gs = paintLine initialState defaultLine player
   paintLine initialState defaultLine player == gs,
  testCase "already colored line" $ do
   let player = Player{numb=1,color=Green, coloredLines=[]}
   let defaultLine = Line{colorForLine=Black, connection=[1,2]}
   let coloredLine = Line{colorForLine=Green, connection=[1,2]}
   paintLine initialState defaultLine player == "Already colored"
 ]

triangleTest::[TestTree]
triangleTest =
 [ testCase "triangle exists and losed player with numb=1" $ do
    let playerss = [Player{color = Green, coloredLines=[[1,2],[2,3],[1,3]], numb=1}] ++ [(players initialState)!!1]
	let liness = 
     [Line {colorForLine = Green, connection = [1,2]},Line {colorForLine = Green, connection = [1,3]},
	 Line {colorForLine = Black, connection = [1,4]},Line {colorForLine = Black, connection = [1,5]},
	 Line {colorForLine = Black, connection = [1,6]},Line {colorForLine = Green, connection = [2,3]},
	 Line {colorForLine = Black, connection = [2,4]},Line {colorForLine = Black, connection = [2,5]},
	 Line {colorForLine = Black, connection = [2,6]},Line {colorForLine = Black, connection = [3,4]},
	 Line {colorForLine = Black, connection = [3,5]},Line {colorForLine = Black, connection = [3,6]},
	 Line {colorForLine = Black, connection = [4,5]},Line {colorForLine = Black, connection = [4,6]},
	 Line {colorForLine = Black, connection = [5,6]}
     ]
	let gs = initialState{players=playerss, gameLines=liness}
	checkTriangle playerss gs == gs{result=1}
	,
   testCase "triangle exists and losed player with numb=2" $ do
    let playerss = [(players initialState)!!0] ++ [Player{color = Blue}, coloredLines=[[1,2],[2,3],[1,3]], numb=2]
	let liness = 
     [Line {colorForLine = Blue, connection = [1,2]},Line {colorForLine = Blue, connection = [1,3]},
	 Line {colorForLine = Black, connection = [1,4]},Line {colorForLine = Black, connection = [1,5]},
	 Line {colorForLine = Black, connection = [1,6]},Line {colorForLine = Blue, connection = [2,3]},
	 Line {colorForLine = Black, connection = [2,4]},Line {colorForLine = Black, connection = [2,5]},
	 Line {colorForLine = Black, connection = [2,6]},Line {colorForLine = Black, connection = [3,4]},
	 Line {colorForLine = Black, connection = [3,5]},Line {colorForLine = Black, connection = [3,6]},
	 Line {colorForLine = Black, connection = [4,5]},Line {colorForLine = Black, connection = [4,6]},
	 Line {colorForLine = Black, connection = [5,6]}
     ]
	let gs = initialState{players=playerss, gameLines=liness}
	checkTriangle playerss gs == gs{result=2}
	,
   testCase "triangle not exists" $ do
    let playerss = players initialState
	let gs = initialState 
	checkTriangle playerss gs == gs
 ]



