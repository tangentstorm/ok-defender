/i shipSR;arne;http://games.tangentcode.com/ld49/sprites/ship-stop-r.png
/i shipTR;arne;http://games.tangentcode.com/ld49/sprites/ship-thrust-r.png
/i alien0;arne;http://games.tangentcode.com/ld49/sprites/alien0.png

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
  shipD:1
  ship:`shipSR
  phxy:()
  phdx:()]
tick: {
  d: (-1; x[`shD];1)[1+*dir]
  s: `shipTL`shipTR[d=1]
  x[`ship]: $[abs[*dir]; s; stop[s]]
  x[`xy]+: shSpd*dir
  x[`phxy]+: x[`phdx],'0
  $[" " in keys; x[`phxy`phdx],:(,x[`xy]+22 18;phSpd*d); `] / pew pew
  x}

draw: { ((x[`xy]; `arne; x[`ship])
         (x[`phxy]; `arne; `phaserR)
         (200 5; `arne; `alien0) )}
         /(;`arne;,/'+text@","/0,$keys))} / uncomment to show keys
