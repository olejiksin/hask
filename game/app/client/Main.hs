module Main where

import Lib
import Types

import GHC.IO.Encoding
import Control.Monad.IO.Class

game :: ClientM ()
game = do
 s <- getState
 liftIO $ print s
 cmd <- liftIO getLine
 case cmd of 
  "quit" -> pure()
  _ -> case parseLine cmd of
    Just l -> postPaint l >> game
    _ -> game

main :: IO ()
main = do
  setLocaleEncoding utf8
  let baseUrl = BaseUrl Http "localhost" 8080 ""
  res <- runClient baseUrl game
  case res of
    Left err -> print err
    Right r -> pure ()
