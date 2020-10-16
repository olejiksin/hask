module Types.Line where

import Types.Rules

data Color
	= Green
	| Blue
	| Black
	deriving(Eq,Show,Read,Enum)
	
data Dot=Dot Int 
	deriving(Eq,Show,Read,Ord)
	
data Line=Line
{color::Color,
connection::[Int]
}deriving(Eq,Show,Read)

lineDefault=Line{color=Black, connection=[1,2]}