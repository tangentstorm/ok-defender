/ DEFENDER clone in oK/iKe for Ludum Dare 49
/ -------------------------------------------
/i shipSR;arne;http://games.tangentcode.com/ld49/sprites/ship-stop-r.png
/i shipTR;arne;http://games.tangentcode.com/ld49/sprites/ship-thrust-r.png
/i alien0;arne;http://games.tangentcode.com/ld49/sprites/alien0.png
/i human;arne;http://games.tangentcode.com/ld49/sprites/human.png

fc:48 / framecount for animated gif recorder

/-- setup
w: 320; h: 200
shSpd: 8
phSpd: _shSpd*2.5

/ "world" is about 5 screens.
/ exact number comes from random terrain generation
worldW: w * 5   / initial width of world
fib:5{x,+/-2#x}/1 1 / first few fibonacci numbers
gndW: {(1+*&worldW<+\x)#x}20*fib@50?#fib
worldW: +/ gndW / refine width to exact match

/ -- terrain generation ---
box: {[x;y;w;h](x,y)+/:(0 0;w,0;w,h;0,h)}
band: { (box[0;30*x;w;30]; ("transparent";solarized@x)) }
sky: band@'!6
gndC: ("#b58900";"#859900";"#cb4b16")
gndX:-1_0,+\gndW
gndH: _20+20*pn[0.1;0.1;]'?#gndW
gnd: (box'[gndX;200-gndH;gndW;gndH])
gnd: gnd {(x;("transparent";y))}' (#gnd)?gndC


/ -- add humans to the terrain
spawnHumans: {
  hw: #*human
  hx: gndX + 0.5*gndW-hw  / x center of each tile
  hy: 200-gndH+#human
  hx,'hy }

/ -- add aliens to the list of aliens
spawnAliens: {[n;alXY] alXY,(n?worldW),'0}

/ -- inital setup
once: [camXY: 0 0 / camera coordinates
  shXY:50 50     / ship coordinates
  shD:1          / ship direction
  huXY:spawnHumans[]
  alXY:spawnAliens[5;()]
  phXY:()        / phaser blast locations (xy)
  phDX:()]       / phaser blast directions (delta xy, where y=0)

tick: {
  x[`camXY]-: (shSpd, 0) * dir
  x[`shD]: d: (-1; x[`shD];1)[1+*dir]
  x[`shXY]+: shSpd*dir
  x[`phXY]+: x[`phDX]
  $[" " in keys; x[`phXY`phDX],:(,x[`shXY]+22 18;,(phSpd*d),0); `] / pew pew
  x}


mapw: 120; maph: 15; mapy: 5
mapbc: ("white";"black") / map box color
mapcc: (solarized@2;"black") / map cam color
minimap: {
  cw: mapw%5 / cam width on the minimap
  ((box[(w-mapw)%2;mapy;mapw;maph];mapbc)
   (box[(w-cw)%2;mapy+1;cw;maph-2];mapcc))}



/-- sprites --
shipSL: |:'shipSR
shipTL: |:'shipTR
phaserL:|:phaserR: 3 4 7 8
stop: [shipTL:`shipSL; shipTR:`shipSR
       shipSL:`shipSL; shipSR:`shipSR]

draw: {
  s: `shipTL`shipTR[x[`shD]=1]

  / -- items in this section move in world space
  r:((,x[`shXY]; `arne; $[abs[*dir]; s; stop[s]])
     (x[`phXY]; `arne; `phaserR)
     (x[`alXY]; `arne; `alien0)
     (x[`huXY];`arne;`human))
  r,:gnd
  r:.[r;(;0); +'\:; x[`camXY]]

  / -- everything below is fixed in place on-screen
  r,:minimap x
  r:sky,r
  / -- debug helpers:
  / r,:,(2 190;;~,/'+text@" "/$dir) / debug: show 'dir'
  / r,:,(50 190;;~,/'+text@","/ 0,$ keys) / debug: show presesd keys
  :r}

/ blank lines to compensate for status line in iKe:
/
/
/
/
/