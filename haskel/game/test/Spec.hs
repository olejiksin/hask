
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
   let defaultLine = Line{colorForLine=Black, connection=[1,2]}
   let gs = paintLine initialState defaultLine 
   paintLine initialState defaultLine @?= gs,
  testCase "already colored line" $ do
   let coloredLine = Line{colorForLine=Green, connection=[1,2]}
   paintLine initialState coloredLine @?= Left "Already colored"
 ]

triangleTest::[TestTree]
triangleTest =
 [ 
  testCase "triangle exists and losed player with numb=0" $ do
   let pla = [Player{color = Green, coloredLines=[Line {colorForLine = Green, connection = [1,2]},Line {colorForLine = Green, connection = [2,3]},Line {colorForLine = Green, connection = [1,3]}], numb=0}] ++ [(players initialState)!!1]
   let lin = [ Line {colorForLine = Green, connection = [1,2]}, Line {colorForLine = Green, connection = [1,3]}, Line {colorForLine = Black, connection = [1,4]}, Line {colorForLine = Black, connection = [1,5]}, Line {colorForLine = Black, connection = [1,6]}, Line {colorForLine = Green, connection = [2,3]}, Line {colorForLine = Black, connection = [2,4]}, Line {colorForLine = Black, connection = [2,5]}, Line {colorForLine = Black, connection = [2,6]}, Line {colorForLine = Black, connection = [3,4]}, Line {colorForLine = Black, connection = [3,5]}, Line {colorForLine = Black, connection = [3,6]}, Line {colorForLine = Black, connection = [4,5]}, Line {colorForLine = Black, connection = [4,6]}, Line {colorForLine = Black, connection = [5,6]}]
   let gs = initialState{players=pla, gameLines=lin}
   checkTriangle pla gs @?= gs{result=0,triangle=True}
   ,
  testCase "triangle exists and losed player with numb=1" $ do
   let pla = [(players initialState)!!0] ++ [Player{color = Red, coloredLines=[Line {colorForLine = Red, connection = [1,2]},Line {colorForLine = Red, connection = [2,3]},Line {colorForLine = Red, connection = [1,3]}], numb=1}]
   let lin = [ Line {colorForLine = Red, connection = [1,2]}, Line {colorForLine = Red, connection = [1,3]}, Line {colorForLine = Black, connection = [1,4]}, Line {colorForLine = Black, connection = [1,5]}, Line {colorForLine = Black, connection = [1,6]}, Line {colorForLine = Red, connection = [2,3]}, Line {colorForLine = Black, connection = [2,4]}, Line {colorForLine = Black, connection = [2,5]}, Line {colorForLine = Black, connection = [2,6]}, Line {colorForLine = Black, connection = [3,4]}, Line {colorForLine = Black, connection = [3,5]}, Line {colorForLine = Black, connection = [3,6]}, Line {colorForLine = Black, connection = [4,5]}, Line {colorForLine = Black, connection = [4,6]}, Line {colorForLine = Black, connection = [5,6]}]
   let gs = initialState{players=pla, gameLines=lin}
   checkTriangle pla gs @?= gs{result=1,triangle=True}
   ,
   testCase "triangle not exists" $ do
   let pla = players initialState
   let gs = initialState 
   checkTriangle pla gs @?= gs
 ]



