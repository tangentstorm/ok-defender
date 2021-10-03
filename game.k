/ DEFENDER clone in oK/iKe for Ludum Dare 49
/ -------------------------------------------
/i shipSR;arne;http://games.tangentcode.com/ld49/sprites/ship-stop-r.png
/i shipTR;arne;http://games.tangentcode.com/ld49/sprites/ship-thrust-r.png
/i alien0;arne;http://games.tangentcode.com/ld49/sprites/alien0.png
/i human;arne;http://games.tangentcode.com/ld49/sprites/human.png
/i beam;arne;http://games.tangentcode.com/ld49/sprites/beam.png

fc:48 / framecount for animated gif recorder

/-- constants
w: 320; h: 200
shSpd: 8
alSpd: 0.5
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
  alBE:nAL#0     / bitmap: alien beam engaged?
  phXY:()        / phaser blast locations (xy)
  phDX:()]       / phaser blast directions (delta xy, where y=0)

/ find a target human (x coord) for each alien
alW:#*alien0
huW:#*human
tgtOfs: -0.5*alW-huW
once[`tgtX]: tgtOfs + once[`alX] {y@t?&/t:abs[x-y]}\: (*:'once[`huXY])

/ collision detection
wh: |-1_#:'*:\   / width and height of a sprite (reverse of shape)
overlap:{[whA;whB;xyA;xyB]&/(xyA,xyB)<(xyB,xyA)+whB,whA}
collide:{ / called after all movement is done for the frame
  overlap[wh phaserR;wh alien0]\:/:[x`phXY;+x`alX`alY]
  :x}

sgn: {$[x=0;0;abs[x]%x]}
tick: {
  x[`camXY]-: (shSpd, 0) * dir
  x[`shD]: d: (-1; x[`shD];1)[1+*dir]
  x[`shXY]+: shSpd*dir

  / !! ----- workaround dmend bug: https://github.com/JohnEarnest/ok/issues/95
  alX:x[`alX]; tgtX:x[`tgtX]; alY:x[`alY]

  / stage 0: aliens drift down while centering in on target
  s0: & ~ x[`alHH] | x[`alIR]
  alX[s0]+: alSpd * sgn' tgtX[s0] - alX[s0]
  alY[s0]: bad & alSpd + alY[s0]

  / stage 1: engage tractor beams when in range
  x[`alIR]: (bad = _ alY) & 1 > abs[alX-tgtX]
  engage: x[`alIR] > x[`alHH]  / bit vector: where to engage beams
  x[`alHH]|:engage
  x[`alBE]|:engage
  / find humans at those x coordinates, and remove from display list
  x[`huXY]@: (!#x`huXY) ^ (*:'x`huXY)?(-tgtOfs)+tgtX@&engage

  / stage 2: aliens take humans into the sky
  alY[& x[`alHH]]-: alSpd
  x[`alX`alY]:(alX; alY)
  / !! ----- /workaround

  x[`phXY]+: x[`phDX] / move phaser blasts

  /x:collide[x]
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
phaserL:|:'phaserR: ,3 4 7 8
bmOfs: 8 20 / beam offset from upper left of alien ship
stop: [shipTL:`shipSL; shipTR:`shipSR
       shipSL:`shipSL; shipSR:`shipSR]

draw: {
  a:`arne
  s: `shipTL`shipTR[x[`shD]=1]

  / -- items in this section move in world space
  alXY: +x[`alX`alY]
  r:((x[`huXY];       a; `human)
     (bmOfs +/: alXY@&x[`alBE]; a; `beam)
     (alXY;           a; `alien0)
     (,x[`shXY];      a; $[abs[*dir]; s; stop[s]])
     (x[`phXY];       a; `phaserR))
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