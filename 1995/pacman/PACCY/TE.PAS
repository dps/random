{$X+,S-,R-}
uses graphics,crt;
var
s : array[0..255,1..3] of byte;

procedure fillcrap;
var
 fill : longint;
begin
 for fill:=1 to 64000 do
  Mem[MCGA:fill]:=random(255);
end;

Procedure GetPal(ColorNo : Byte; Var R,G,B : Byte);
Begin
   Port[$3c7] := ColorNo;
   R := Port[$3c9];
   G := Port[$3c9];
   B := Port[$3c9];
End;

Procedure SPal(ColorNo : Byte; R,G,B : Byte);
Begin
   Port[$3c8] := ColorNo;
   Port[$3c9] := R;
   Port[$3c9] := G;
   Port[$3c9] := B;
End;

Procedure Fadedown;
var
 store : array[0..255,1..3] of byte;
 r,g,b,col : byte;
 loop,l2 : integer;
begin
 col:=0;
 for loop := 0 to 255 do
    Getpal(loop,store[loop,1],store[loop,2],store[loop,3]);
 for loop := 1 to 64 do
  begin
    for l2:=0 to 255 do
     begin
      if store[l2,1]>0 then dec(store[l2,1]);
      if store[l2,2]>0 then dec(store[l2,2]);
      if store[l2,3]>0 then dec(store[l2,3]);
     end;
     Vwait;
     for l2:=0 to 63 do
       Spal(l2,store[l2,1],store[l2,2],store[l2,3]);
     Vwait;
     for l2:=63 to 127 do
       Spal(l2,store[l2,1],store[l2,2],store[l2,3]);
     Vwait;
     for l2:=64 to 191 do
       Spal(l2,store[l2,1],store[l2,2],store[l2,3]);
     Vwait;
     for l2:=192 to 255 do
       Spal(l2,store[l2,1],store[l2,2],store[l2,3]);
    end;
   
end;

Procedure InitFadeUp;
var
 loop : integer;
begin
 for loop := 0 to 255 do
    Getpal(loop,s[loop,1],s[loop,2],s[loop,3]);
 for loop := 0 to 255 do
    SPal(loop,0,0,0);
end;

Procedure FadeUp;
var
 store : array[0..255,1..3] of byte;
 r,g,b,col : byte;
 loop,l2 : integer;
begin
 col:=0;
 for loop := 0 to 255 do
    Getpal(loop,store[loop,1],store[loop,2],store[loop,3]);
 for loop := 1 to 64 do
  begin
    for l2:=0 to 255 do
     begin
      if store[l2,1]<s[l2,1] then inc(store[l2,1]);
      if store[l2,2]<s[l2,2] then inc(store[l2,2]);
      if store[l2,3]<s[l2,3] then inc(store[l2,3]);
     end;
     Vwait;
     for l2:=0 to 63 do
       Spal(l2,store[l2,1],store[l2,2],store[l2,3]);
     Vwait;
     for l2:=63 to 127 do
       Spal(l2,store[l2,1],store[l2,2],store[l2,3]);
     Vwait;
     for l2:=64 to 191 do
       Spal(l2,store[l2,1],store[l2,2],store[l2,3]);
     Vwait;
     for l2:=192 to 255 do
       Spal(l2,store[l2,1],store[l2,2],store[l2,3]);
    end;
   
end;


var
   t: integer;
begin
  SetMCGA;
  InitFadeUp;
  fillcrap;
  FadeUp;
  Fadedown;
  fillcrap;
  FadeUp;
  SetTEXT;
end.