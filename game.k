/ DEFENDER clone in oK/iKe for Ludum Dare 49
/ -------------------------------------------
/i shipSR;arne;http://games.tangentcode.com/ld49/sprites/ship-stop-r.png
/i shipTR;arne;http://games.tangentcode.com/ld49/sprites/ship-thrust-r.png
/i alien0;arne;http://games.tangentcode.com/ld49/sprites/alien0.png
/i human;arne;http://games.tangentcode.com/ld49/sprites/human.png
/i beam;arne;http://games.tangentcode.com/ld49/sprites/beam.png

/ utils
sgn: {(x>0)-x<0}
kd:ku:kx:kr:kb:lx:ux:md:mu:mm:mg:mm:{} / clear event handlers
once:() / empty state var
assert:{[err;t] $[&/t;1;err[]]}
isFlat:~|/0=@:'  / x contains no lists

/ == setup =====================================================================
fc:48 / framecount for animated gif recorder
w: 320; h: 200 / screen size
seaLevel: 20
beamRange: 32
bad: h - beamRange+seaLevel+#human  / beam Activation Depth

/ "world" is about 5 screens. exact number comes from random terrain generation
worldW: w * 5   / initial width of world
fib:5{x,+/-2#x}/1 1 / first few fibonacci numbers
gndW: {(1+*&worldW<+\x)#x}20*fib@50?#fib
worldW: +/ gndW / refine width to exact match
wrap:{(worldW,h)!'x}

/ -- terrain generation ---
box: {[x;y;w;h](x,y)+/:(0 0;w,0;w,h;0,h)}
band: { (box[0;30*x;w;30]; ("transparent";solarized@x)) }
sky: band@'!6
gndC: ("#b58900";"#859900";"#cb4b16")
gndW,:gndW  / copy twice for wrapping
gndX:-1_0,+\gndW
gndH: _seaLevel+20*pn[0.1;0.1;]'?#gndW
gnd: (box'[gndX;200-gndH;gndW;gndH])
gnd: gnd {(x;("transparent";y))}' c,c:(0.5*#gndW)?gndC / color copies the same

/ -- humans --
spawnHumans: {
  hw: #*human
  hx: gndX + 0.5*gndW-hw  / x center of each tile
  hy: 200-gndH+#human
  hx,'hy }
huXY:spawnHumans[]
fhXY:() / falling humans

/ -- ship --
shXY:50 50      / ship coordinates
shD:1           / ship direction
shSpd: 8
shYMin: 18; shYMax: 146 / for clamping y-coord

/ -- aliens --
nAL:5
alSpd: 1.3 / 0.5
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

/ === collision detection =================================================

wh: |-1_#:'*:\   / width and height of a sprite (reverse of shape)
overlap:{[whA;whB;xyA;xyB]&/(xyA,xyB)<(xyB,xyA)+whB,whA}
colmat:{[sprA;sprB;xysA;xysB] / collision matrix
  $[0=|/(#xysA;#xysB); ()  / return () if either list is empty
    {ov:overlap[wh sprA;wh sprB]; ov/:\:[xysA;xysB]}[] ]}

/ collision handlers take the collision matrix
PHvAL:{ / phasers vs aliens: dead aliens holding humans drop their humans
  $[|/drop:alHH&alXX:|/x; fhXY,:: (-tgtOfs;2+#alien0) +/: (+(alX;alY))@&drop; `]
  rmPH@|/'x; rmAL@alXX }

SHvFH:{ rmFH@|/x } / ship vs falling humans (ship catches them)
rmFH:{[bits] keep:&~bits; fhXY@::keep }

/ -- run all the collision tests
collide:{ / called after all movement is done for the frame
  $[#cm:colmat[phaserR;alien0;phXY;+(alX;alY)]; PHvAL@cm;`]
  $[#cm:colmat[shipSR;falling;,shXY;fhXY]; SHvFH@cm;`]}

tick: {
  shD:: (-1; shD;1)[1+*dir]
  shXY:: @[wrap shXY+ shSpd*dir; 1; shYMax&shYMin|]
assert[`flat0;isFlat alX]
old::[x:(),alX; y:(),alY] / https://github.com/JohnEarnest/ok/issues/97
  / stage 0: aliens drift down while centering in on target
  s0: & ~ alHH | alIR
  $[1=#s0; s0:*s0; `] / workaround for https://github.com/JohnEarnest/ok/issues/96
  alX[s0]+:: alSpd * sgn alTX[s0] - alX[s0]
  alY[s0]:: bad & (1.5*alSpd) + alY[s0]
assert[`flat1;isFlat alX]
  / stage 1: engage tractor beams when in range
  alIR:: (bad = _ alY) & 1 > abs[alX-alTX]
  alBE|::engage: alIR > alHH  / bit vector: where to engage beams
  alHH|::engage

  / find humans at those x coordinates, and remove from display list
  huXY@:: (!#huXY) ^ (*:'huXY)?(-tgtOfs)+alTX@&engage

  alY[& alHH]-:: alSpd  / stage 2: aliens holding humans ruturn to space
  phXY:: wrap@' phXY+phDX; rmPH[1>phTL-:: 1]  / move and cull phaser blasts
  $[#fhXY;fhXY::fhXY+\:0 1;`]; $[0=4!f;falling::+|falling;`]  / falling humans
  collide[]

  (" " in keys) shoot[shXY]/shD / shoot if space is down
  x}

/ ==== display logic ========================================================

camXY:0 0       / camera coordinates
atSeam:{worldW<w+cx:*camXY}  / seam in view?

/ -- minimap --
mapw: 120; maph: 15; mapx: (w-mapw)%2; mapy:5
mapbc: ("white";"black") / map box color
mapcc: (solarized@2;"black") / map cam color
minimap: {
  sf: mapw%worldW / scaling factor
  cw: sf*w        / cam width on the minimap
  cx: mapx + co:sf**camXY
  r:,(box[mapx;mapy;mapw;maph];mapbc)
  $[atSeam[]
     c:((box[mapx;mapy+1;cw-mapw-co;maph-2];mapcc)
        (box[cx;mapy+1;mapw-co;maph-2];mapcc))
     c:,(box[cx;mapy+1;cw;maph-2];mapcc)]
  r,c}

/-- sprites --
shipSL: |:'shipSR
shipTL: |:'shipTR
falling: human
phaserL:|:'phaserR: ,3 4 7 8
bmOfs: 8 20 / beam offset from upper left of alien ship
stop: [shipTL:`shipSL; shipTR:`shipSR
       shipSL:`shipSL; shipSR:`shipSR]

/ -- items in this section move in world space
spriteLayer:{
  a:`arne; s:`shipTL`shipTR[shD=1]
  alXY: +(alX;alY)
  :((huXY;       a; `human)
    (fhXY;       a; `falling)
    (bmOfs +/: alXY@&alBE; a; `beam)
    (alXY;       a; `alien0)
    (,shXY;      a; $[abs[*dir]; s; stop[s]])
    (phXY;       a; `phaserR))}

copyLeftSide:{[r]    / render-time only
  t:&:'w>*:''r[;0]   / indices in each sprite group
  i:&0<#:'t          / indices of non-empty groups in r
  pal:r[i;1];  spr:r[i;2]
  xys:((worldW,0)+/:/: r[i;0]@'t@i)
  +(xys;pal;spr)}

draw: {
  camXY:: wrap camXY+ (shSpd, 0) * dir
  r:spriteLayer[]
  / if seam in view, copy left side of the world
  $[atSeam[]; r,:copyLeftSide[r]; `]
  r,:gnd
  r:.[r;(;0); -'\:; camXY]

  / -- everything below is fixed in place on-screen
  r,:minimap x
  r:sky,r
  / -- debug helpers:
  / r,:,(;;~,/'+text@","/$camXY) / debug: show 'camXY'
  / r,:,(2 190;;~,/'+text@" "/$dir) / debug: show 'dir'
  / r,:,(50 190;;~,/'+text@","/ 0,$ keys) / debug: show presesd keys
  :r}

/ blank lines to compensate for status line in iKe:
/
/
/
/
/