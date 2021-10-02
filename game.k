/i shipSR;arne;http://games.tangentcode.com/ld49/sprites/ship-stop-r.png
/i shipTR;arne;http://games.tangentcode.com/ld49/sprites/ship-thrust-r.png
/i alien0;arne;http://games.tangentcode.com/ld49/sprites/alien0.png
/i person;arne;http://games.tangentcode.com/ld49/sprites/person.png

fc:48 / framecount for animated gif recorder

/-- setup
w: 320; h: 200
shSpd: 5
phSpd: 8

/-- sprites --
shipSL: |:'shipSR
shipTL: |:'shipTR
phaserL:|:phaserR: 3 4 7 8
stop: [shipTL:`shipSL; shipTR:`shipSR
       shipSL:`shipSL; shipSR:`shipSR]

once: [xy:50 50
  shD:1          / ship direction
  phxy:()        / phaser blast locations (xy)
  phdx:()]       / phaser blast directions (delta xy, where y=0)

tick: {
  x[`shD]: d: (-1; x[`shD];1)[1+*dir]
  x[`xy]+: shSpd*dir
  x[`phxy]+: x[`phdx]
  $[" " in keys; x[`phxy`phdx],:(,x[`xy]+22 18;,(phSpd*d),0); `] / pew pew
  x}


box: {[x;y;w;h](x,y)+/:(0 0;w,0;w,h;0,h)}
band: { (box[0;30*x;w;30]; ("transparent";solarized@x)) }
sky: band@'!6

fib:2_8{x,+/-2#x}/1 1 / first 8 fibonacci numbers after 1
0*fib@50?8
earth: ("#b58900";"#859900";"#cb4b16")
n:16; ground: (box[;180;20;20]@'20*!n) {(x;("black";y))}' earth@n?3

draw: {
  s: `shipTL`shipTR[x[`shD]=1]
 sky,((x[`xy]; `arne; $[abs[*dir]; s; stop[s]])
  (x[`phxy]; `arne; `phaserR)
  (200 5; `arne; `alien0)
  (152 92;`arne;`person)),ground}
 /(;      ;~,/'+text@" "/$dir)    )}
 /(;`arne;~,/'+text@","/ 0,$ keys))} / uncomment to show keys


