Генератор лабиринтов v.01b  
flex файл: beta01.l  
bison файл с трансляцией на lc3: beta01.y  
bison файл с трансляцией на c: c_concept.y  
Командны:  
SIZE int XSIZE int YSIZE - задание размера лабиринта  
WALL int XCOORD int YCOORD - расположение стены в лабиринте по координатам XCOORD и YCOORD 
FLOOR int XCOORD int YCOORD - расположение пола в лабиринте по координатам XCOORD и YCOORD 
CHEST int XCOORD int YCOORD - расположение сундука в лабиринте по координатам XCOORD и YCOORD  
DOOR int XCOORD int YCOORD - расположение двери в лабиринте по координатам XCOORD и YCOORD  
TRAP int XCOORD int YCOORD - расположение ловушки в лабиринте по координатам XCOORD и YCOORD
QUIT - выход из написания кода, вывод кода на LC 3 в консоль  
