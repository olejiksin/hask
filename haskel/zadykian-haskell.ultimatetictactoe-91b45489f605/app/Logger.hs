module Logger (logMessage) where

import Data.Time.Clock
import System.IO

{-|
    Отправить сообщение в stdout.
-}
logMessage :: String -> IO ()
logMessage message = do
    currentTime <- getCurrentTime
    putStrLn $ show currentTime ++ ": " ++ message
    hFlush stdout