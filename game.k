/i shipSR;arne;http://games.tangentcode.com/ld49/sprites/ship-stop-r.png
/i shipTR;arne;http://games.tangentcode.com/ld49/sprites/ship-thrust-r.png
/i alien0;arne;http://games.tangentcode.com/ld49/sprites/alien0.png

fc:48 / framecount for animated gif recorder

/-- setup
w: 320; h: 200
speed: 5

/-- sprites --
shipSL: |:'shipSR
shipTL: |:'shipTR
phaserL:|:phaserR: 3 4 7 8
stop: [shipTL:`shipSL; shipTR:`shipSR
       shipSL:`shipSL; shipSR:`shipSR]


once: [xy:50 50;ship:`shipSR;phxy:();phdx:()]
tick: {
  s: (`shipTL,x[`ship],`shipTR)[1+*dir]
  x[`ship]: $[abs[*dir]; s; stop[s]]
  x[`xy]+: speed * dir }

draw: { ((x[`xy]; `arne; x[`ship])
         (x[`xy]+22 18; `arne; `phaser)
         (200 5; `arne; `alien0))}


