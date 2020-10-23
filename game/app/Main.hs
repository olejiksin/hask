module Main where

import Lib

import Network.Wai.Handler.Warp (run)

main :: IO ()
main = do
  app <- mkApp
  run 8081 app
