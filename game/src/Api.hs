{-# LANGUAGE DataKinds #-}
{-# LANGUAGE TypeOperators #-}

module Api where

import Types
import Game

import Control.Concurrent.STM
import Control.Monad.IO.Class
import Control.Monad.Random
import Control.Monad.Reader
import Servant
import Servant.API