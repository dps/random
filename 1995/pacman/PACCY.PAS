{PACCY - PacMan Clone David Singleton 1995}
{$X+}
Uses Crt,Graphics;
type
	Screen256 = ARRAY[0..199] OF ARRAY[0..319] OF Byte;
        Pal = Array[0..767] of byte;
        Sprite = Array[0..3] of Array[0..19] of Array[0..19] of Byte;
        Bady = record
           sx,sy,xx,yy,ox,oy:integer;
           blinky : boolean;
        end;

        Cursor = record
        	C : Array[0..15] of Word;
                M : Array[0..15] of Word;
        end;

var
        Level : Array[0..16] of Array[0..9] of Char;
        Pills : Array[0..16] of Array[0..19] of Char;
	Prefs : Array[0..4] of Byte;
        NoPills,numbad : integer;
        bad : array[1..10] of bady;
        s : array[0..255,1..3] of byte;
Procedure Vwait;
begin
asm
	CLI
        MOV DX,$3DA
@a:
	IN AL,DX
        AND AL,08h
        JNZ @a
@b:
	IN AL,DX
        AND AL,08h
        JZ @b
        STI
end;
end;

Procedure SetPixel(x,y,c : integer);
begin
	Mem[$A000:((y*320)+x)] := c;
end;

Procedure CursorPac;
var
Pac : Cursor;
S,O : Word;
begin
	Pac.C[0]:=$FFFF;
	Pac.C[1]:=$FFFF;
        Pac.C[2]:=$FFFF;
	Pac.C[3]:=$F80F;
        Pac.C[4]:=$F007;
        Pac.C[5]:=$C001;
        Pac.C[6]:=$C001;
        Pac.C[7]:=$8003;
        Pac.C[8]:=$801F;
        Pac.C[9]:=$807F;
        Pac.C[10]:=$C03F;
        Pac.C[11]:=$C03F;
        Pac.C[12]:=$F01F;
        Pac.C[13]:=$F81F;
        Pac.C[14]:=$FFFF;
        Pac.C[15]:=$FFFF;
	Pac.M[0]:=$0000;
	Pac.M[1]:=$0000;
        Pac.M[2]:=$0000;
	Pac.M[3]:=$07F0;
        Pac.M[4]:=$0FF8;
        Pac.M[5]:=$3F3E;
        Pac.M[6]:=$7FFC;
        Pac.M[7]:=$7FE0;
        Pac.M[8]:=$7F80;
        Pac.M[9]:=$3FC0;
        Pac.M[10]:=$3FC0;
        Pac.M[11]:=$0FE0;
        Pac.M[12]:=$07E0;
        Pac.M[13]:=$0000;
        Pac.M[14]:=$0000;
        Pac.M[15]:=$0000;
        S:=Seg(Pac);
        O:=Ofs(Pac);
	ASM	MOV AX,$0009
        	MOV BL,$01
                MOV CL,$01
                MOV ES,S
                MOV DX,O
                INT $33
        end;
end;

Procedure SetPalette(P : Pal);
var
S,O : Word;

begin
        S := Seg(P);
        O := Ofs(P);
	asm	MOV AX,$1012
        	MOV ES,S
                MOV DX,O
                MOV BX,0
                MOV CX,255
                INT $10
        end;
end;

Procedure LoadScr(name : string);
var
PaletteBuf : Pal;
n : byte;
l : integer;
fi : file;
begin
	assign(fi,name);
	reset(fi,1);
        for l:=0 to 31 do
              BlockRead(fi,n,1);

	BlockRead(fi,PaletteBuf,768);
        for l:=0 to 767 do
            begin
        	PaletteBuf[l]:=PaletteBuf[l] SHR 2;
            s[l div 3,(l mod 3)+1]:=PaletteBuf[l];
            end;

        BlockRead(fi,Ptr($A000,0000)^,64000);
        close(fi);
end;

Procedure LoadScrnp(name : string);
var
PaletteBuf : ^Pal;
n : byte;
l : integer;
fi : file;
begin
	assign(fi,name);
	reset(fi,1);
        for l:=0 to 31+768 do
              BlockRead(fi,n,1);
        BlockRead(fi,Ptr($A000,0000)^,64000);
        close(fi);
end;

Procedure LoadSpr(name : string;row : integer;var pl : Sprite);
var
n : byte;
l,a,b,ystart,xstart : integer;
Pic : Screen256;
fi : file;
begin
	assign(fi,name);
	reset(fi,1);
        for l:=0 to 31+768 do
              BlockRead(fi,n,1);
        BlockRead(fi,Pic,64000);
        ystart:=1+(21*(row-1));

        for l:=0 to 3 do
        begin
        xstart := (l*21+1);
        	for b:=0 to 19 do
                begin
                	for a:=0 to 19 do
                        begin
                           pl[l,a,b]:=Pic[a+ystart,b+xstart];
                        end;
                end;
        end;

        close(fi);
end;

Procedure PutSpr(Pl : Sprite;x,y,frame : integer);
var
	a,b : integer;
begin
       Vwait;
        for b:=0 to 19 do
        begin
        	for a:=0 to 19 do
                begin
                	if Pl[frame,b,a]<>0 then Mem[$A000:(x+a)+((y+b)*320)]:=Pl[frame,b,a]
                    else Mem[$A000:(x+a)+((y+b)*320)]:=VScreenMCGA^[(x+a)+((y+b)*320)+1];
                end;
        end;
end;

Procedure PutSprnr(Pl : Sprite;x,y,frame : integer);
var
	a,b : integer;
begin
        for b:=0 to 19 do
        begin
        	for a:=0 to 19 do
                begin
                	if Pl[frame,b,a]<>0 then Mem[$A000:(x+a)+((y+b)*320)]:=Pl[frame,b,a]; 
                end;
        end;
end;

Procedure PutBack(x,y : integer);
var
	a,b : integer;
begin
        for b:=0 to 19 do
        begin
        	for a:=0 to 19 do
                begin
                	Mem[$A000:(x+a)+((y+b)*320)]:=VScreenMCGA^[(x+a)+((y+b)*320)+1];
                end;
        end;
end;
Procedure ClrSpr(xx,yy,ox,oy: integer);
var
	a,b,xdif,ydif : integer;
begin
     if xx<>ox then 
     begin
        xdif:=xx-ox;
        if xdif<0 then
         begin
         
          for a:=0 to abs(xdif)-1 do
           for b:=0 to 19 do
            Mem[$A000:(xx+20+a)+((oy+b)*320)]:=VScreenMCGA^[(xx+20+a)+((oy+b)*320)+1];
         end
        else
         begin
         
         for a:=0 to abs(xdif) do
           for b:=0 to 19 do
            Mem[$A000:(ox+a)+((oy+b)*320)]:=VScreenMCGA^[(ox+a)+((oy+b)*320)+1];
         end;
     end;
if yy<>oy then 
     begin
        ydif:=yy-oy;
        if ydif<0 then
         begin
         
          for a:=0 to 19 do
           for b:=0 to abs(ydif)-1 do
            Mem[$A000:(ox+a)+((yy+20+b)*320)]:=VScreenMCGA^[(ox+a)+((yy+20+b)*320)+1];
         end
        else
         begin
         
         for a:=0 to 19 do
           for b:=0 to abs(ydif)-1 do
            Mem[$A000:(xx+a)+((oy+b)*320)]:=VScreenMCGA^[(xx+a)+((oy+b)*320)+1];
         end;
     end;
{        for b:=0 to 19 do
        begin
        	for a:=0 to 19 do
                begin
        		Mem[$A000:(x+a)+((y+b)*320)]:=BefLPut[b,a];
                end;

        end;}
end;




Procedure DrawLev(name : string;s,c,p : Sprite);
var
	lev : text;
	n,m:integer;
        row : string;
        r : char;
begin
        assign(lev,name);
        reset(lev);
        readln(lev,n);
        NoPills:=0;
        for n:=0 to 9 do
        begin
           readln(lev,row);
           for m:=0 to length(row)-1 do
           	begin
			r:=row[m+1];
                        if (r='.') or (r='@') then 
			begin 
                         if r='.' then NoPills:=NoPills+1;
			 Pills[m,n]:=r;
			 Level[m,n]:=' ';
			end 

			else Level[m,n]:=r;

                        if r='1' then PutSprnr(s,m*20,n*20,0);
                        if r='2' then PutSprnr(s,m*20,n*20,1);
                        if r='3' then PutSprnr(s,m*20,n*20,2);
                        if r='4' then PutSprnr(s,m*20,n*20,3);
			if r='5' then PutSprnr(c,m*20,n*20,0);
                        if r='6' then PutSprnr(c,m*20,n*20,1);
                        if r='7' then PutSprnr(c,m*20,n*20,2);
                        if r='8' then PutSprnr(c,m*20,n*20,3);
                        if r='.' then PutSprnr(p,m*20,n*20,0);
                        if r='@' then PutSprnr(p,m*20,n*20,2);
                end;
       end;
   readln(lev,numbad);
   for n:=1 to numbad do
   begin
   readln(lev,bad[n].sx,bad[n].sy);
   end;
   close(lev);
end;

Procedure MousePoll(var x,y : word;var LeftBut,RightBut :Boolean);
var
        xt : word;
        yt : word;
	ButStat : word;
begin
	asm	MOV AX,$0003
		INT $33
                MOV ButStat,BX
                MOV xt,CX
		MOV yt,DX
	end;
        x:=xt;
        y:=yt;
        if (ButStat AND 1) = 1 then LeftBut := True;
	if (ButStat AND 2) = 2 then RightBut := True;
end;

Function PauseKey : char;
Var
x,y : word;
l,r : Boolean;
begin
	Repeat
	Until KeyPressed;
 	PauseKey:=ReadKey;
end;


Procedure SetGraph;
begin
     asm        MOV AH,00
                MOV AL,$13
                INT $10
     end;
end;

Procedure SetText;
begin
     asm        MOV AH,00
                MOV AL,03
                INT $10
     end;
end;

Procedure ShowMouse;
begin
	asm	MOV AH,00
		MOV AL,01
		INT $33
	end
end;

Procedure MouseHide;
begin
	asm	MOV AH,00
		MOV AL,02
		INT $33
	end
end;

Procedure MouseMotion(var x,y : word);
var
	c,d : word;
begin
       	asm	MOV AX,$000B
        	INT $33
                MOV c,CX
                MOV d,DX
        end;
	x:=c;
        y:=d;
end;

Procedure TextyStuff;
var
N : char;
begin
TextColor(1);
Writeln('같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같�');
Writeln('갚굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�');
Writeln('갚께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께껑�');
Writeln('갚꾼栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢껑�');
Write('갚꾼栢栢栢栢栢�');
TextColor(14);
TextBackGround(1);
Write('     PACCY - PacMan Clone David Singleton 1995     ');
TextColor(1);
TextBackground(0);
Writeln('栢栢栢栢栢껑�');
Writeln('갚꾼栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢껑�');
Writeln('갚께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께껑�');
Writeln('갚굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�');
Writeln('같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같�');
Writeln('');
TextColor(5);
Writeln('Press Any Key To Begin....');
N:=PauseKey;
end;

Function ReadController : Byte;
var
 x,y : word;
 a,b : integer;
begin
	if Prefs[0]=1 then begin;ReadController:=Port[$60];if Keypressed then readKey;end
        else
        begin
         if Prefs[0]=2 then
         	begin
                {Mouse}
                MouseMotion(x,y);
                a:=x;
                b:=y;
                a:=a div 5;
                b:=b div 5;
                if (a=0) and (b=0) then ReadController:=0;
                if (a>0) and (abs(a)>abs(b)) then ReadController:=77;
                if (a<0) and (abs(a)>abs(b)) then ReadController:=75;
                if (b>0) and (abs(a)<abs(b)) then ReadController:=80;
                if (b<0) and (abs(a)<abs(b)) then ReadController:=72;
                if port[$60]=1 then ReadController:=1;
                end;
        end;
end;

Function CheckMove(xx,yy,xm,ym : integer) : Boolean;
begin
                CheckMove:=False;
		if (Level[(xx+xm) div 20,(yy+ym) div 20]=' ') then
		if (Level[(xx+19+xm) div 20,(yy+19+ym) div 20]=' ') then 
        if (Level[(xx+19+xm) div 20,(yy+ym) div 20]=' ') then
        if (Level[(xx+xm) div 20,(yy+19+ym) div 20]=' ') then
                CheckMove:=True
                
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



Procedure FadeDown;
VAR loop1,loop2:integer;
    Tmp : Array [1..3] of byte;

BEGIN
  For loop1:=1 to 64 do BEGIN
    Vwait;
    For loop2:=1 to 255 do BEGIN
      Getpal (loop2,Tmp[1],Tmp[2],Tmp[3]);
      If Tmp[1]>0 then dec (Tmp[1]);
      If Tmp[2]>0 then dec (Tmp[2]);
      If Tmp[3]>0 then dec (Tmp[3]);

      SPal (loop2,Tmp[1],Tmp[2],Tmp[3]);
    END;
  END;
END;

procedure Scrollup;
var
 line,l,d,e : integer;

begin
 for l:=0 to 9 do
 begin


    if l mod 2=1 then
    begin
     for d:=1 to 64 do begin
    for e:=l*20 to l*20+20 do
     begin
     Mem[$A000:(e*320)+319]:=0;
     Mem[$A000:(e*320)+318]:=0;
     Mem[$A000:(e*320)+317]:=0;
     Mem[$A000:(e*320)+316]:=0;
     Mem[$A000:(e*320)+315]:=0;
     end;
    Vwait;
    for line:=l*20 to (l*20)+20 do
    Move(mem[$A000:line*320+5],mem[$A000:line*320],320);end;
    end
    else
     for d:=1 to 64 do begin
    for e:=l*20 to l*20+20 do
     begin
     Mem[$A000:(e*320)]:=0;
     Mem[$A000:(e*320)+1]:=0;
     Mem[$A000:(e*320)+2]:=0;
     Mem[$A000:(e*320)+3]:=0;
     Mem[$A000:(e*320)+4]:=0;
     Mem[$A000:(e*320)+5]:=0;
     end;
    Vwait;
    for line:=l*20 to (l*20)+20 do
    Move(mem[$A000:line*320-5],mem[$A000:line*320],320);end;
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

Procedure InFUp;
var
 loop : integer;
begin
 for loop := 0 to 255 do
    Getpal(loop,s[loop,1],s[loop,2],s[loop,3]);
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
      if store[l2,1]<(s[l2,1]-1) then inc(store[l2,1],2);
      if store[l2,2]<(s[l2,2]-1) then inc(store[l2,2],2);
      if store[l2,3]<(s[l2,3]-1) then inc(store[l2,3],2);
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
  
 {Move(mem[$A000:3200],mem[$A000:0],60800);
 fillchar(Mem[$A000:60800],3200,0);
 for line:=2 to 20 do
 begin
 Move(mem[$A000:3200],mem[$A000:0],60800);
 end;}


{TIME FOR THE MAIN PROGRAM *PS* }
var
PlayerR : Sprite;
PlayerL : Sprite;
PlayerU : Sprite;
PlayerD : Sprite;
Baddy : Sprite;
Wallz : Sprite;
Cornerz : Sprite;
Pillz : Sprite;
a : integer;
Null : char;
xx,yy,x,y,ox,oy : word;
xm,ym,bd : integer;
Left,Right,ClickyStart,endy : Boolean;
l,k,Buf : byte;
begin
    SetupVScreenMCGA;
        Prefs[0]:=2; {Controller - Mouse}
	TextyStuff;
	SetGraph;
        endy:=False;
	Repeat
                prefs[0]:=2;
                initfadeup;
                LoadScr('pintro.raw');
                LoadSpr('bonuses.raw',1,Pillz);
                PutSprnr(Pillz,95,64,3);
                PutSprnr(Pillz,95,89,2);
	        ShowMouse;
        	CursorPac;
                clickyStart:=False;
                Fadeup;
                Repeat
		Left:=False;
		MousePoll(x,y,Left,Right);
                x:=x div 2;
                if port[$60]=159 then Clickystart:=true;

                if port[$60]=178 then 
				begin Prefs[0]:=2;PutSprnr(Pillz,95,64,3);PutSprnr(Pillz,95,89,2);end;

                if port[$60]=165 then 
				begin Prefs[0]:=1;PutSprnr(Pillz,95,64,2);PutSprnr(Pillz,95,89,3);end;

                if port[$60]=144 then endy:=true;

                If Left=True then
		begin
                 if ((((x>89) and (x<231)) and ((y>125) and (y<164)))) then ClickyStart:=true;
                 if (((x>115) and (x<201)) and ((y>64) and (y<85))) then 
		 begin Prefs[0]:=2;PutSprnr(Pillz,95,64,3);PutSprnr(Pillz,95,89,2);end;
                 if (((x>115) and (x<201)) and ((y>89) and (y<110))) then 
		 begin Prefs[0]:=1;PutSprnr(Pillz,95,64,2);PutSprnr(Pillz,95,89,3);end;
                 if (((x>253) and (x<317)) and ((y>176) and (y<197))) then endy:=true;
		end;
                Until (ClickyStart=True) or (endy=True);
	
        if endy=False then
        begin
        infup;
        fadedown;
        MouseHide;
        LoadSpr('sprites.raw',1,PlayerR);
        LoadSpr('sprites.raw',2,PlayerL);
        LoadSpr('sprites.raw',3,PlayerU);
	LoadSpr('sprites.raw',4,PlayerD);
	LoadSpr('sprites.raw',5,Baddy);
        LoadSpr('sprites.raw',6,Wallz);
        LoadSpr('sprites.raw',7,Cornerz);
        LoadScrnp('play.raw');
        Move(Mem[MCGA:0],VScreenMCGA^,64000);
        DrawLev('Pac.lev',Wallz,Cornerz,Pillz);
        for bd:=1 to numbad do
          begin
          bad[bd].yy:=(bad[bd].sx-1)*20;
          bad[bd].xx:=(bad[bd].sy-1)*20;
          end;
        ox:=100;
        oy:=160;
        xx:=100;
        yy:=160;
        PutSpr(PlayerR,xx,yy,0);
        Buf:=0;
        fadeup;
        Repeat
	       begin
                k:=ReadController;
                if ((k=77) or (k=72) or (k=80) or (k=75)) then Buf:=k;
                l:=l+1;
                if (Checkmove(xx,yy,xm,ym)=True) then
                begin xx:=xx+xm;yy:=yy+ym;end;

                for bd:=1 to numbad do
                begin
                   if bad[bd].xx<>bad[bd].ox then PutSpr(Baddy,bad[bd].xx,bad[bd].yy,1);
                   bad[bd].ox:=bad[bd].xx;
                   bad[bd].oy:=bad[bd].yy;
                end;

                if ((ox<>xx) or (oy<>yy)) then
                  begin
                   
                   if ((ox div 20)<>(xx div 20)) or ((oy div 20)<>(yy div 20)) then
                   begin
                     if Pills[(xx) div 20,(yy) div 20]='.' then
                      begin
                        Sound(5000);
                        NoPills:=NoPills-1;
                        Pills[(xx) div 20,(yy) div 20]:=' ';
                        NoSound;
		      end;
                     if Pills[xx div 20,yy div 20]='@' then
                      begin
                               Sound(1000);
                        delay(5);
                        Pills[xx div 20,yy div 20]:=' ';
                        NoSound;
                      end;
                   end;
           
		   if xm<0 then PutSpr(PlayerL,xx,yy,(l div 4) mod 4);
		   IF XM>0 then PutSpr(PlayerR,xx,yy,(l div 4) mod 4);
           if ym>0 then PutSpr(PlayerD,xx,yy,(l div 4) mod 4);
		   if ym<0 then PutSpr(PlayerU,xx,yy,(l div 4) mod 4);
           ClrSpr(xx,yy,ox,oy);
		  {Vwait;}
                  ox:=xx;
                  oy:=yy;
                  end;

                 if ((xx mod 20)=0) and ((yy mod 20)=0) then
                 begin
		         if ((k=77) or (Buf=77)) and (CheckMove(xx,yy,2,0)=True) then BEGIN xm:=2; ym:=0; end;
                 if ((k=75) or (Buf=75)) and (CheckMove(xx,yy,-2,0)=True) then BEGIN xm:=-2; ym:=0; end;
                 if ((k=80) or (Buf=80)) and (CheckMove(xx,yy,0,2)=True) then BEGIN xm:=0; ym:=2; end;
                 if ((k=72) or (Buf=72)) and (CheckMove(xx,yy,0,-2)=True) then BEGIN xm:=0; ym:=-2; end; 
                 end;
        	end;


        Until (k=1) or (NoPills<1);
        end;
{        Fillchar(Mem[$A000:0000],64000,1);}
{        Scrollup;}
		Fadedown;
        Until endy=True;

        MouseHide;
    TrashVScreenMCGA;
	SetText;
	Writeln('See ya!');
end.