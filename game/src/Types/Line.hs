{-# LANGUAGE DeriveGeneric #-}

module Types.Line where

import Data.Aeson(FromJSON,ToJSON)
import Data.List (findIndex)
import GHC.Generics

--Всего три цвета для линий: черный(default/неокрашенная), зеленый(первый игрок), синий(второй игрок)
data Color
 = Green
 | Red
 | Black
 deriving(Eq,Show,Read,Enum,Generic)
 
instance FromJSON Color
instance ToJSON Color

--Соединенные точки линией указываются в массиве ([1,3]-соединены точки 1 и 3) 
--изначально элементы имеют цвет 'Black'
data Line=Line
 {colorForLine::Color,
 connection::[Int]
 }deriving(Eq,Show,Read,Generic)
 
instance FromJSON Line
instance ToJSON Line

allColorString,allConnectionFirstString,allConnectionSecondString::String
allColorString = "BGR"
allConnectionFirstString = "12345"
allConnectionSecondString = "23456"

parseLine::String -> Maybe Line
parseLine [cl,fCon,sCon]
 = mLine
 <$> findIndex (==cl)  allColorString
 <*> findIndex (==fCon) allConnectionFirstString
 <*> findIndex (==sCon) allConnectionSecondString
 where mLine cli fConn sConn = Line (toEnum cli) ([fConn,sConn]) 
parseLine _=Nothing


