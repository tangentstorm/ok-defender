/ DEFENDER clone in oK/iKe for Ludum Dare 49
/ -------------------------------------------
/i shipSR;arne;http://games.tangentcode.com/ld49/sprites/ship-stop-r.png
/i shipTR;arne;http://games.tangentcode.com/ld49/sprites/ship-thrust-r.png
/i alien0;arne;http://games.tangentcode.com/ld49/sprites/alien0.png
/i person;arne;http://games.tangentcode.com/ld49/sprites/person.png

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


/-- sprites --
shipSL: |:'shipSR
shipTL: |:'shipTR
phaserL:|:phaserR: 3 4 7 8
stop: [shipTL:`shipSL; shipTR:`shipSR
       shipSL:`shipSL; shipSR:`shipSR]

once: [camXY: 0 0 / camera coordinates
  shXY:50 50 / ship coordinates
  shD:1          / ship direction
  phxy:()        / phaser blast locations (xy)
  phdx:()]       / phaser blast directions (delta xy, where y=0)

tick: {
  x[`camXY]-: (shSpd, 0) * dir
  x[`shD]: d: (-1; x[`shD];1)[1+*dir]
  x[`shXY]+: shSpd*dir
  x[`phxy]+: x[`phdx]
  $[" " in keys; x[`phxy`phdx],:(,x[`shXY]+22 18;,(phSpd*d),0); `] / pew pew
  x}


box: {[x;y;w;h](x,y)+/:(0 0;w,0;w,h;0,h)}
band: { (box[0;30*x;w;30]; ("transparent";solarized@x)) }
sky: band@'!6

earth: ("#b58900";"#859900";"#cb4b16")

gndX:-1_0,+\gndW
gndH: _20+20*pn[0.1;0.1;]'?#gndW
gnd: (box'[gndX;200-gndH;gndW;gndH])
gnd: gnd {(x;("transparent";y))}' (#gnd)?earth

draw: {
  s: `shipTL`shipTR[x[`shD]=1]

  r:((,x[`shXY]; `arne; $[abs[*dir]; s; stop[s]])
     (x[`phxy]; `arne; `phaserR)
     (,200 5; `arne; `alien0)
     (,152 92;`arne;`person))
  r,:gnd
  r:.[r;(;0); +'\:; x[`camXY]]
  / r,:,(2 190;;~,/'+text@" "/$dir) / debug: show 'dir'
  / r,:,(50 190;;~,/'+text@","/ 0,$ keys) / debug: show presesd keys
  / sky is fixed gradient. others are drawn relative to camera
  :sky,r}

/ blank lines to compensate for status line in iKe:
/
/
/
/
/