program editor;
uses crt,graph,dos,drivers,fonts;
type koord=record
             a:integer;
             b:integer
           end;
var n:array[1..32,1..32] of boolean;
    i,j,x,y,x1,y1:integer;
    co:integer;
    k:koord;
    f1:file of koord;
    o,u:boolean;
    dirinfo:searchrec;
    archive:word;
procedure inicijalizacija;
var a,b:integer;
begin
  if RegisterBGIdriver(@HercDriverProc) < 0 then
    halt(1);
  if RegisterBGIfont(@TriplexFontProc) < 0 then
    halt(1);
  if RegisterBGIfont(@SmallFontProc) < 0 then
    halt(1);
   a:=detect;
   InitGraph(a,b,'');
end;
procedure bris;
begin
 for x:=1 to 32 do
  for y:=1 to 32 do n[x,y]:=false
end;
procedure screen1;
begin
 setvisualpage(1);
 setactivepage(1);
 setusercharsize(10,10,80,80);
 settextstyle(1,0,7);
 outtextxy(70,70,' Sprite editor ');
 settextstyle(2,0,8);
 outtextxy(505,160,' version 1.0 ');
 settextstyle(5,0,1);
 outtextxy(380,300,'written by Ognjen Perisic (C) 1992.');
end;
procedure screen;
begin
 setactivepage(0);
 rectangle(10,10,330,330);
 rectangle(0,2,338,337);
 setusercharsize(1,1,1,1);
 settextstyle(5,0,4);
 for x:=1 to 6 do begin
                    circle(x*50+5,6,3);
                    floodfill(x*50+7,6,1);
                    circle(x*50+5,333,3);floodfill(x*50+6,334,1);
                    circle(5,x*50+5,3);circle(334,x*50+5,3);
                    floodfill(5,x*50+5,1);floodfill(335,x*50+6,1)
                  end;
 circle(6,7,3);floodfill(7,8,1);
 rectangle(400,70,700,340);
 setusercharsize(2,2,2,2);
 settextstyle(5,0,5);
 outtextxy(420,80,' pokretanje kursorskim tasterima');
 outtextxy(420,320,' Esc - izlaz');
 outtextxy(420,180,' Insert - pisanje (linije)');
 outtextxy(420,200,' Delete - brisanje (linije)');
 outtextxy(420,100,' Home - kursor');
 outtextxy(420,140,' Enter - pisanje (tacke)');
 outtextxy(420,160,' Backspace - brisanje (tacke)');
 outtextxy(420,120,' End - brisanje ekrana');
 outtextxy(420,280,' F5 - ucitavanje objekta');
 outtextxy(420,300,' F9 - snimanje objekta');
 outtextxy(420,220,' F1 - rotacija po X - osi');
 outtextxy(420,240,' F2 - rotacija po Y - osi');
 outtextxy(420,260,' F3 - inverzni objekat');
 for i:=1 to 32 do begin
                     line(i*10,10,i*10,330);
                     line(10,i*10,330,i*10)
                   end;
 setvisualpage(0);
 setactivepage(0);
end;
procedure plot(var x,y,co:integer;p:boolean);
var k:integer;
begin
if p then k:=1
     else k:=0;
 setcolor(k);
 for i:=x*10+1 to x*10+9 do line(i,y*10+1,i,y*10+9);
 putpixel(x+400,y+30,k);
 n[x,y]:=p;
 setcolor(1);
 inc(co);
end;
procedure kvadrat(x,y,l:integer);
var t:integer;
begin
  setcolor(l);
  rectangle(x+3,y+3,x+7,y+7)
end;
procedure snim;
var g:string[12];
    c:char;
begin
 restorecrtmode;
 clrscr;
 gotoxy(5,6);
 write(' ----------------------------------------------');
 gotoxy(5,5);
 write('Unesite naziv objekta koji zelite da snimite :');
 readln(g);
 g:=concat(g,'.edi');
 findfirst(g,archive,dirinfo);
 if doserror=0 then begin
                       gotoxy(5,7);
                       write('Objekat pod tim nazivom postoji.Nastavak (N)?');
                       c:=readkey;
                       if c in ['N','n',chr(13)] then exit;
                     end;
 assign(f1,g);
 rewrite(f1);
 for x:=1 to 32 do
                 for y:=1 to 32 do if n[x,y] then begin
                                                    k.a:=x;
                                                    k.b:=y;
                                                    write(f1,k)
                                                  end;
 close(f1)
end;
procedure usnim;
var g,n:string[12];
    dirinfo:searchrec;
    u,yt:char;
begin
 restorecrtmode;
 if co>0 then
           begin
             gotoxy(1,5);
             writeln(' Da li zelite da snimite sprite (D/N) ?');
             gotoxy(40,5);
             yt:=readkey;
             if yt in ['D','d'] then snim;
             co:=0;
           end;
 bris;
 gotoxy(1,5);
 clreol;
 gotoxy(1,5);
 writeln('Pritisnite k za katalog ili bilo koji taster za ucitavanje.');
 gotoxy(60,5);
 u:=readkey;
 highvideo;
 if u='k' then begin
                 writeln(' Sprites ');
                 clrscr;
                 findfirst('*.edi',archive,dirinfo);
                 while doserror=0 do begin
                                       write(dirinfo.name:15);
                                       findnext(dirinfo)
                                      end
               end
          else clrscr;
 lowvideo;
 gotoxy(15,16);
 writeln('---------------------------------------------');
 gotoxy(15,15);
 write('Unesite naziv spritea koji zelite da ucitate :');
 readln(g);
 g:=concat(g,'.edi');
 findfirst(g,archive,dirinfo);
 if DosError=0 then begin
                     assign(f1,g);
                     reset(f1);
                     setgraphmode(getgraphmode);
                     screen;
                     repeat
                       read(f1,k);
                       plot(k.a,k.b,co,true)
                     until eof(f1);
                     close(f1);
                     x:=1;
                     y:=1;
                     co:=0;
                   end
               else begin
                     setgraphmode(getgraphmode);
                     screen;
                     x:=1;
                     y:=1;
                   end
end;
procedure swap(var x,y:boolean);
var m:boolean;
begin
   m:=x;
   x:=y;
   y:=m
end;
procedure ispis;
begin
 for x:=1 to 32 do
                  for y:=1 to 32 do if n[x,y] then plot(x,y,co,true)
                                              else plot(x,y,co,false);
 x:=1;
 y:=1
end;
procedure rot(t:boolean);
var x1,y1,k:integer;
begin
  k:=31;
  for x1:=1 to 16 do begin
                        for y1:=32 downto 1 do begin
                                              if t then swap(n[x1,y1],n[x1+k,y1])
                                                   else swap(n[y1,x1],n[y1,x1+k])
                                               end;
                        dec(k,2)
                     end;
  ispis
end;
procedure check;
var f:char;
    e:integer;
begin
 screen;
 x:=2;
 y:=2;
 kvadrat(x*10,y*10,1);
 repeat
   f:=readkey;
   x1:=x;
   y1:=y;
   setcolor(0);
   if u and (f<>chr(13)) then kvadrat(x*10,y*10,j);
                 case f of
                         chr(13):plot(x,y,co,true);
                         chr(8):plot(x,y,co,false);
                         chr(72):if y>1 then dec(y);
                         chr(80):if y<32 then inc(y);
                         chr(77):if x<32 then inc(x);
                         chr(75):if x>1 then  dec(x);
                         chr(71):u:=true;
                         chr(82):begin
                             o:=true;
                             u:=false
                            end;
                         chr(83):begin
                             o:=false;
                             u:=false
                            end;
                         chr(63):usnim;
                         chr(67):begin
                              snim;
                              setgraphmode(getgraphmode);
                              screen;
                              ispis;
                            end;
                         chr(60):rot(true);
                         chr(59):rot(false);
                         chr(61):begin
                                  for x:=1 to 32 do
                                     for y:=1 to 32 do begin
                                                          n[x,y]:=not(n[x,y]);
                                                       end;
                                 ispis;
                                end;
                         chr(79):begin
                              bris;
                              for x:=1 to 32 do
                               for y:=1 to 32 do if n[x,y] then plot(x,y,co,true)
                                                           else plot(x,y,co,false);
                               x:=1;
                               y:=1
                            end
                          end;
                 j:=getpixel(x*10+2,y*10+2);
                 if u then kvadrat(x*10,y*10,abs(j-1))
                      else  begin
                              plot(x1,y1,co,o);
                              x1:=x;
                              y1:=y;
                              kvadrat(x*10,y*10,abs(j-1))
                            end;

                 until f=chr(27);
 closegraph
end;
begin
 co:=0;
 inicijalizacija;
 bris;
 screen1;
 u:=true;
 check
end.


