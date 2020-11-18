module Main where

import Lib
import Types

import Control.Monad
import Control.Monad.IO.Class
import Data.Maybe

prettyConnections :: Line -> String
prettyConnections (Line col [fc, sc]) =
 [ allColorString !! fromEnum col
 , allConnectionFirstString !! (fc-1)
 , allConnectionSecondString !! (sc-2)
 ] 

printConnections :: [Line] -> IO()
printConnections cons = do
 forM_ cons $ \cn -> do
  putStr $ prettyConnections cn ++ " " 
 putStrLn ""


{-
printPlayers :: [Player] -> IO()
printPlayers players = do
 forM_ players $ \p -> do
  putStr $ prettyPlayer p ++ " "
 putStrLn ""

prettyPlayer :: Player -> String
prettyPlayer (Player numb coloredLines color) =
 [ show numb
 , show coloredLines
 , show color
 ] 
-}

printGameState::GameState -> IO()
printGameState gs = do
 putStr $ "Move of player with numb " ++ show (move gs)
 putStrLn ""
 putStrLn "All lines: " 
 forM_ (gameLines gs) $ \gls -> do
  putStr $ prettyConnections gls ++ " "
 putStrLn ""
 putStr "Paint not colored line"
 putStrLn ""


game :: ClientM ()
game = do
 s <- getState
 if (result s) == 2
  then do
   liftIO $ printGameState s
   cmd <- liftIO getLine
   case cmd of 
    "quit" -> pure()
    _ -> case parseLine cmd of
      Just l -> postPaint l >> game
      _ -> game
  else do
   liftIO $ print $ "Loser: " ++ show(result s)
   pure()
   
main :: IO ()
main = do
  let baseUrl = BaseUrl Http "localhost" 8080 ""
  res <- runClient baseUrl game
  case res of
    Left err -> print err
    Right r -> pure ()
