# MiniProject_CodeNamesCard

The MiniProjects are small tasks for the purpose of getting practice in multiple languages.

CodeNamesCard should be a small application that can make a card modeled after the clue-givers map in the game Code Names.  The map uses colored squares in a 5x5 grid to indicate which positions (which spies) are one the red team, blue team, tan (inocent by-stander) or black (the assisin).  

The user should be able to control: 
-the size of the gred (default 5x5, and defaults to square if only width or height is set),
-The number of assisins (default 1),
-the number of by-standers (default: floor of 25% of squares),
-The number of team-spaces for each team (default: (number of squares - assasins - by-standers)/2 max difference of 1 for red and blue).

Given these parameters, the application should produce an image similar to the maps found in the Code Names game.

The output should look as close as possible to the cards in the official game.
For online reference, there is an app version of the official game: 
https://play.google.com/store/apps/details?id=com.czechgames.codenames

