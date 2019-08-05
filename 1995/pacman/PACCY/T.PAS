Uses Crt,Graphics;


procedure Scroll;
var
 line : integer;
 line2:integer;
 lop:integer;
 cou : integer;
begin
 cou:=0;
 repeat
 Vwait;
 for line:=90 to 100 do
  Move(mem[$A000:line*320+1],mem[$A000:line*320],320);
 for line:=101 to 111 do
 Move(mem[$A000:(line)*320-1],mem[$A000:(line)*320],320);
  for line:=79 to 89 do
 Move(mem[$A000:(line)*320-1],mem[$A000:(line)*320],320);
 for line2:=90 to 100 do
  Mem[$A000:(line2*320)+319]:=random(12)+11;
 for line2:=102+random(10) to 111 do
   Mem[$A000:((line2)*320)]:=random(2);
 for line2:=79 to random(10)+79 do
   Mem[$A000:((line2)*320)]:=random(2);

  until port[$60]=1;

end;

begin
SetMCGA;


scroll;

SetTEXT;
end.