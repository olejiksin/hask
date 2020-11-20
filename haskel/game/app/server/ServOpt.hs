module ServOpt where

import Options
import Control.Lens.Lens ((&))

data ServOpt = ServOpt
 {
  host :: String,
  port :: Int,
  timeout :: Int
 }

fullAddress :: ServOpt -> String
fullAddress options = (options & host) ++ ":" ++ show (options & port)

instance Options ServOpt where
 defineOptions = (ServOpt
  <$> simpleOption "host" "127.0.0.1" "API host address.")
  <*> simpleOption "port" 8080 "API port."
  <*> simpleOption "timeout" 60 "API timeout in seconds."

instance Show ServOpt where
 show options =
  (options & host) 
   ++ ":" ++ show (options & port) 
   ++ " with " ++ show (options & timeout) ++ "s request timeout."