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

draw: {
  s: `shipTL`shipTR[x[`shD]=1]
 ((x[`xy]; `arne; $[abs[*dir]; s; stop[s]])
  (x[`phxy]; `arne; `phaserR)
  (200 5; `arne; `alien0)
  (;`arne;`person) )}
 /(;      ;~,/'+text@" "/$dir)    )}
 /(;`arne;~,/'+text@","/0,$keys))} / uncomment to show keys