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
huXY:spawnHumans[]
fhXY:()

/ -- inital setup
camXY:0 0       / camera coordinates
shXY:50 50      / ship coordinates
shD:1           / ship direction

/ -- aliens --
nAL:5
alSpd: 0.5
tgtOfs: -0.5*(#*alien0)-#*human
alX:nAL?worldW
alY:nAL#0
alHH:nAL#0      / bitmap: alien holding a human?
alIR:nAL#0      / bitmap: alien in range of target?
alBE:nAL#0      / bitmap: alien beam engaged?
/ find a target human (x coord) for each alien:
alTX: tgtOfs + alX {y@t?&/t:abs[x-y]}\: *:'huXY
rmAL: {[bits] keep:&~bits / remove aliens where bits=1
  alX@::keep; alY@::keep; alHH@::keep; alIR@::keep; alBE@::keep; alTX@::keep; `}

/ -- phasers --
phSpd: _shSpd*1.75
phTL:()         / phaser time to live
phXY:()         / phaser blast locations (xy)
phDX:()         / phaser blast directions (delta xy, where y=0)
phLT: 16        / phaser lifetime
phOfs: 22 18
rmPH: {[bits] keep:&~bits; phXY@::keep; phDX@::keep; phTL@::keep; `}
shoot:{[shXY;d] / spawn phaser given shipxy and x direction
  phTL,:: phLT
  phXY,:: ,shXY+phOfs
  phDX,:: ,(phSpd*d),0}

/ collision detection
wh: |-1_#:'*:\   / width and height of a sprite (reverse of shape)
overlap:{[whA;whB;xyA;xyB]&/(xyA,xyB)<(xyB,xyA)+whB,whA}
colmat:{[sprA;sprB;xysA;xysB] / collision matrix
  $[0=|/(#xysA;#xysB); ()  / return () if either list is empty
    {ov:overlap[wh sprA;wh sprB]; ov/:\:[xysA;xysB]}[] ]}

/ collision handlers take the collision matrix
PHvAL:{
  / dead aliens holding humans drop their humans
  $[|/drop:alHH&alXX:|/x; fhXY,:: (-tgtOfs;2+#alien0) +/: (+(alX;alY))@&drop; `]
  rmPH@|/'x; rmAL@alXX }

rmFH:{[bits] keep:&~bits; fhXY@::keep }
SHvFH:{ rmFH@|/x }

collide:{ / called after all movement is done for the frame
  / - phasers vs aliens: h: list of aliens hit, per phaser
  $[#cm:colmat[phaserR;alien0;phXY;+(alX;alY)]; PHvAL@cm;`]
  $[#cm:colmat[shipSR;falling;,shXY;fhXY]; SHvFH@cm;`]}

sgn: {$[x=0;0;abs[x]%x]}
tick: {
  camXY-:: (shSpd, 0) * dir
  shD:: (-1; shD;1)[1+*dir]
  shXY+:: shSpd*dir

  / stage 0: aliens drift down while centering in on target
  s0: & ~ alHH | alIR
  alX[s0]+:: alSpd * sgn' alTX[s0] - alX[s0]
  alY[s0]:: bad & (3*alSpd) + alY[s0]

  / stage 1: engage tractor beams when in range
  alIR:: (bad = _ alY) & 1 > abs[alX-alTX]
  engage: alIR > alHH  / bit vector: where to engage beams
  alHH|::engage
  alBE|::engage
  / find humans at those x coordinates, and remove from display list
  huXY@:: (!#huXY) ^ (*:'huXY)?(-tgtOfs)+alTX@&engage

  alY[& alHH]-:: alSpd  / stage 2: aliens holding humans ruturn to space
  phXY+:: phDX; rmPH[1>phTL-:: 1]  / move and cull phaser blasts
  $[#fhXY;fhXY::fhXY+\:0 1;`]; $[0=4!f;falling::+|falling;`]  / falling humans
  collide[]

  (" " in keys) shoot[shXY]/shD / shoot if space is down
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
falling: human
phaserL:|:'phaserR: ,3 4 7 8
bmOfs: 8 20 / beam offset from upper left of alien ship
stop: [shipTL:`shipSL; shipTR:`shipSR
       shipSL:`shipSL; shipSR:`shipSR]

draw: {
  a:`arne
  s:`shipTL`shipTR[shD=1]

  / -- items in this section move in world space
  alXY: +(alX;alY)
  r:((huXY;       a; `human)
     (fhXY;       a; `falling)
     (bmOfs +/: alXY@&alBE; a; `beam)
     (alXY;       a; `alien0)
     (,shXY;      a; $[abs[*dir]; s; stop[s]])
     (phXY;       a; `phaserR))
  r,:gnd
  r:.[r;(;0); +'\:; camXY]

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