/ DEFENDER clone in oK/iKe for Ludum Dare 49
/ -------------------------------------------
/i shipSR;arne;http://games.tangentcode.com/ld49/sprites/ship-stop-r.png
/i shipTR;arne;http://games.tangentcode.com/ld49/sprites/ship-thrust-r.png
/i alien0;arne;http://games.tangentcode.com/ld49/sprites/alien0.png
/i human;arne;http://games.tangentcode.com/ld49/sprites/human.png

fc:48 / framecount for animated gif recorder

/-- constants
w: 320; h: 200
shSpd: 8
alSpd: 1.3
phSpd: _shSpd*2.5
seaLevel: 20
beamRange: 32
bad: h - beamRange+seaLevel+#human  / beam Activation Depth

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
gndH: _seaLevel+20*pn[0.1;0.1;]'?#gndW
gnd: (box'[gndX;200-gndH;gndW;gndH])
gnd: gnd {(x;("transparent";y))}' (#gnd)?gndC


/ -- add humans to the terrain
spawnHumans: {
  hw: #*human
  hx: gndX + 0.5*gndW-hw  / x center of each tile
  hy: 200-gndH+#human
  hx,'hy }

/ -- inital setup
nAL: 5
once: [camXY: 0 0 / camera coordinates
  shXY:50 50     / ship coordinates
  shD:1          / ship direction
  huXY:spawnHumans[]
  alX:nAL?worldW
  alY:nAL#0
  alHH:nAL#0     / bitmap: alien holding a human?
  alIR:nAL#0     / bitmap: alien in range of target?
  phXY:()        / phaser blast locations (xy)
  phDX:()]       / phaser blast directions (delta xy, where y=0)

/ find a target human (x coord) for each alien
alW:#*alien0
huW:#*human
once[`tgtX]: (-0.5*alW-huW)+ once[`alX] {y@t?&/t:abs[x-y]}\: (*:'once[`huXY])

sgn: {$[x=0;0;abs[x]%x]}
tick: {
  x[`camXY]-: (shSpd, 0) * dir
  x[`shD]: d: (-1; x[`shD];1)[1+*dir]
  x[`shXY]+: shSpd*dir


  / stage 0: aliens drift down while centering in on target
  s0: & ix: ~(hh: x[`alHH]) | ir:x[`alIR]

  / !! working around dmend bug: https://github.com/JohnEarnest/ok/issues/95
  alX:x[`alX]; tgtX:x[`tgtX]; alY:x[`alY]
  alX[s0]+: alSpd * sgn' tgtX[s0] - alX[s0]
  alY[s0]: bad & alSpd + alY[s0]
  x[`alX`alY]:(alX; alY)
  / !! /workaround

  x[`alIR]: ix & bad = _ x[`alY]

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
     (+x[`alX`alY]; `arne; `alien0)
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