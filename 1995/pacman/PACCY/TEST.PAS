Uses Crt;
{INT 33 - MS MOUSE v1.0+ - READ MOTION COUNTERS
	AX = 000Bh
Return: CX = number of mickeys mouse moved horizontally since last call
	DX = number of mickeys mouse moved vertically
Notes:	a mickey is the smallest increment the mouse can sense
	positive values indicate down/right
SeeAlso: AX=0003h,AX=001Bh,AX=0027h}
var
x,y : word;
xx,yy : integer;
begin
	repeat
        begin
        	asm	MOV AX,$000B
                	INT $33
                        MOV x,CX
                        MOV y,DX
                end;
        xx:=x;
        yy:=y;
        {if x>32768 then x:=not(x);
        if y>32768 then y:=not(y);}
        writeln(xx div 5,' ',yy div 5);
        Repeat
        until KeyPressed;
        end;
        ReadKey;
        until Port[$60]=1;

end.