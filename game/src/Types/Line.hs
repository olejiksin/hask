{-# LANGUAGE DeriveGeneric #-}

module Types.Line where

import Data.Aeson
import GHC.Generics

--Всего три цвета для линий,черный(default/неокрашенная), зеленый(первый игрок), синий(второй игрок)
data Color
	= Green
	| Blue
	| Black
	deriving(Eq,Show,Read,Enum)
instance FromJSON Color
instance ToJSON Color

--Соединенные точки линией указываются в массиве ([1,3]-соединены точки 1 и 3) 
--В итоге будет матрица 6х6, изначально элементы имеют цвет 'Black'. (Окрашиваем линию между точками 1 и 3 в 'Blue', т.е эл. матрицы [0][2])  
data Line=Line
{color::Color,
connection::[Int]
}deriving(Eq,Show,Read)
instance FromJSON Line
instance ToJSON Line

