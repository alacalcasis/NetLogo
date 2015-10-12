extensions [ gis ]

breed [ ptsEnc ptEnc ]
breed [ ptsSal ptSal ]
breed [ senyls senyl ]
breed [ peatones peaton ]

globals [ ptsEnc-salitral-ds
          ptsSal-salitral-ds 
          rtsEvc-salitral-ds
          senyls-salitral-ds
          inndcn-salitral-ds
          subSct-salitral-ds
          sectores-salitral-ds 
          mapa-ds ]

to init-globals ;; Para darle valor inicial a las variables globales.
  let ruta "mapas"
  set ptsEnc-salitral-ds gis:load-dataset word ruta "/PUNTOS DE ENCUENTRO.shp"
  set ptsSal-salitral-ds gis:load-dataset  word ruta "/PUNTOS_DE_SALIDA.shp"
  set rtsEvc-salitral-ds gis:load-dataset  word ruta "/RUTAS_EVACUACION.shp"
  set senyls-salitral-ds gis:load-dataset  word ruta "/SEÑALES.shp"
  set inndcn-salitral-ds gis:load-dataset  word ruta "/UnionAreaInundacion.shp"
  set subSct-salitral-ds gis:load-dataset  word ruta "/SECTORES.shp"
  set sectores-salitral-ds gis:load-dataset  word ruta "/5_SECTORES.shp"
  ;set mapa-ds gis:load-dataset word ruta "/mapa.asc" cuando lo genere
  gis:set-world-envelope (gis:envelope-union-of (gis:envelope-of ptsEnc-salitral-ds)
                                                (gis:envelope-of ptsSal-salitral-ds)
                                                (gis:envelope-of rtsEvc-salitral-ds)
                                                (gis:envelope-of senyls-salitral-ds)
                                                (gis:envelope-of inndcn-salitral-ds)
                                                (gis:envelope-of subSct-salitral-ds)
                                                (gis:envelope-of sectores-salitral-ds)
                                                ;(gis:envelope-of mapa-ds)
                                                )
  ;gis:set-world-envelope gis:raster-world-envelope mapa-ds 0 0
  ;gis:set-drawing-color 9
  ;gis:paint mapa-ds 100
    
  gis:set-drawing-color brown
  gis:draw subSct-salitral-ds 1
  
  gis:set-drawing-color blue
  gis:draw ptsSal-salitral-ds 1
  
  gis:set-drawing-color green
  gis:draw rtsEvc-salitral-ds 2 ; data set y grosor de la línea pintada
  marcar-parcelas-rutas         ; colorea las parcelas en las rutas de evacuación
  
  gis:set-drawing-color 133
  gis:draw ptsEnc-salitral-ds 1
  
  gis:set-drawing-color sky
  gis:draw senyls-salitral-ds 1
  
  gis:set-drawing-color 56
  gis:draw inndcn-salitral-ds 1
end

to setup ;; Para inicializar la simulación.
  ca           ;; Equivale a clear-ticks + clear-turtles + clear-patches + 
               ;; clear-drawing + clear-all-plots + clear-output.
               
  init-globals ;; Para inicializar variables globales.
  
  ;; Para crear puntos de salida, de encuentro y señales y mostrarlos.
  ptsEnc-crgDts    ; carga los datos de los puntos de encuentro desde el shape-file
  senyls-crgDts    ; carga los datos de las señales desde el shape-file  
  ptsSal-crgDts    ; carga los datos de los puntos de salida desde el shape-file
  ask patches with [ any? ptsSal-here ] [ P-crear-peatones ]   ; crea los grupos de personas o "peatones" en cada parcela con algún ptSal
  
  reset-ticks  ;; Para inicializar el contador de ticks.
end

to go ;; Para ejecutar la simulación.
  ask ( n-of N-peatones peatones ) [ peaton-seguir-ruta 7 90 5 2 100 ]
  tick
  ; actualizar-salidas
  ; if ticks >= 25  ;; En caso de que la simulación esté controlada por cantidad de ticks.
  ;   [stop]
end


;;*******************************
;; Otras funciones globales:
;;*******************************

to actualizar-salidas ;; Para actualizar todas las salidas del modelo.
end

to marcar-parcelas-rutas
  ask patches gis:intersecting rtsEvc-salitral-ds [ set pcolor green ]
end


;;*******************************
;; Definición de agentes peaton:
;;*******************************

peatones-own [ 
  ticSal    ; ticSal es el tic en que saldrá el grupo de personas que representa el peaton
  cntPrs    ; cntPrs es la cantidad de personas que representa el peaton
  encObj       ; punto de encuentro objetivo
]

; REQ: tSal haya sido generado por una distribución normal
; EFE: inicializar un peaton con tic de salida en tSal y 
to peaton-init [ tSal cPrs ] ; Para inicializar peaton a la vez: tic de salida y cantidad de peatones.
  set ticSal tSal
  set cntPrs cPrs
  set size cntPrs
  peaton-buscar-ptEnc        ; Busca el punto de encuentro más cercano linealmente
  
  ; ahora hay que darle una dirección con base en la ruta de evacuación y que lo lleve al ptEnc más cercano
  ; let direcciones patches in-radius 10 with [ pcolor = green ]
  ; let direccion min-one-of direcciones [ distance encObj myself]
  peaton-asignar-tmpSal
end

to peaton-seguir-ruta [rv av gr lp cnp]
  ; rv sería el rango de visión: más o menos cuántas parcelas a la redonda pueden ver las tortugas para seguir la ruta. 7 parece ser el número mágico.
  ; av sería el ángulo de visión: que nos da la cuerda en que la tortuga busca parcelas de color green para seguir la ruta
  ; gr giro que hace la tortuga para buscar un mejor heading
  ; lp longitud del paso de la tortuga hacia adelante
  ; cnp cantidad de pasos que dará la tortuga
  ; además cada tortuga tiene una memoria de intersecciones ordenadas y debería saber en qué dirección virar al llegar a esas intersecciones
  ; face agent: estas intersecciones podrían ser agentes, habría que ver si esto da alguna ventaja para simular el movimiento de los peatones,
  ; jump number: podría ser útil para simular diferentes velocidades,
  ; patches in-cone rv av me da todas las parcelas en un cono de radio rv y tamaño de cuerda av que está al frente de una tortuga
  
  ; setxy -231 -414
  ; set heading 90
  ; set color white
  ; follow-me
  peaton-seguir-ruta-rcr rv av gr lp cnp
end

to peaton-seguir-ruta-rcr [rv av gr lp cnp]
  if cnp > 0 [
     ifelse ( not any? patches in-cone rv av with [ pcolor = 53 or pcolor = 54 or pcolor = 55 ] ) ;; hay que corregir heading
       [ ;; rt gr sólo girar para tratar de corregir heading no sirve
         ;; los peatones con heading ortogonal a la ruta de evacuación reportan no encontrar max-one-of...
         set heading towards max-one-of patches in-cone rv 270 with [ pcolor = 53 or pcolor = 54 or pcolor = 55 ] [ distance myself ]
        ] ; 
       [ fd lp ] ; avanza porque va en la dirección correcta
     peaton-seguir-ruta-rcr rv av gr lp cnp - 1
  ]
end

to peaton-buscar-ptEnc
  set encObj min-one-of ptsEnc [ distance self ]
end

to peaton-asignar-tmpSal
end

;;*******************************
;; Definición de agentes ptsEnc:
;;*******************************

ptsEnc-own [ 
  dom     ; DOMINIO: público o privado
  tipo    ; TIPO:...
  nmb     ; NOMBRE del lugar
  cntPeatones  ; cantidad de peatones que se han reunido en el lugar
]

to ptsEnc-crgDts 
  foreach gis:feature-list-of ptsEnc-salitral-ds [
    create-ptsEnc 1 [
      set xcor first gis:location-of first first gis:vertex-lists-of ?
      set ycor last gis:location-of first first gis:vertex-lists-of ?
      set color 133
      set shape "flag" 
      set size 7
      ptsEnc-init ?
    ]
  ]
end

to ptsEnc-init [tupla]
  set dom gis:property-value tupla "DOMINIO"
  set tipo gis:property-value tupla "TIPO"
  set nmb gis:property-value tupla "NOMBRE"
end

;;*******************************
;; Definición de agentes ptsSal:
;;*******************************

ptsSal-own [ 
  id      ; id del ptSal en el shape-file
  pobNys  ; población de niños
  pobAdt  ; población de adultos
  pobAdm  ; población de adultos mayores
  pobDsc  ; población de discapacitados
] ; NOTA: se supone que los niños, adultos mayores y discapacitados deben evacuar en compañía de al menos un adulto


; EFE: crea un punto de salida y carga los datos correspondientes a partir del shape file
to ptsSal-crgDts
  ;{{gis:VectorFeature ["ID":"A-1"]["POB_DSC":"6.0"]["POB_ADT":"113.0"]["POB_NYS":"29.0"]["POB_TOT":"150.0"]["POB_ADM":"8.0"]}}
  foreach gis:feature-list-of ptsSal-salitral-ds [
    create-ptsSal 1 [
      set xcor first gis:location-of first first gis:vertex-lists-of ?
      set ycor last gis:location-of first first gis:vertex-lists-of ?
      set color blue
      set shape "house" 
      set size 7
      ptsSal-init ?
    ]
  ]  
end

; EFE: inicializa un punto de salida a partir de los datos cargados en "ptsSal-crgDts" del shape file
to ptsSal-init [tupla]
  set id gis:property-value tupla "ID"
  set pobDsc gis:property-value tupla "POB_DSC"
  set pobAdt gis:property-value tupla "POB_ADT"
  set pobNys gis:property-value tupla "POB_NYS"
  set pobAdm gis:property-value tupla "POB_ADM"
  set pobTot pobAdt + pobNys + pobAdm + pobDsc
  set fg round ( 1 + pobAdt / ( pobNys + pobAdm + pobDsc ))
  set lstGps []
end

; EFE: retorna la lista de grupos
to-report ptsSal-obt-lstGps 
  report lstGps
end

; EFE: retorna la cantidad de grupos de un ptSal
to-report ptsSal-cuenta-grupos
  let rsl 0
  foreach lstGps [
    set rsl rsl + first ? 
  ]
  report rsl
end

to remanente
    ; let tupla lput ID []  
    ; set tupla lput POB_DSC tupla
    ; set tupla lput POB_ADT tupla
    ; set tupla lput POB_NYS tupla
    ; set tupla lput POB_TOT tupla
    ; set tupla lput POB_ADM tupla
    ; show tupla
end
;;*******************************
;; Definición de agentes senyls:
;;*******************************

senyls-own [ 
  num   ; identificación de la señal 
  lado  ; señala giro a la izquierda o a la derecha
]

to senyls-crgDts
  foreach gis:feature-list-of senyls-salitral-ds [
    create-senyls 1 [
      set xcor first gis:location-of first first gis:vertex-lists-of ?
      set ycor last gis:location-of first first gis:vertex-lists-of ?
      set color sky
       
      set size 7
      senyls-init ?
    ]
  ]  
end

to senyls-init [tupla]
  set num gis:property-value tupla "NUM"
  set lado gis:property-value tupla "LADO"
  if lado = "IZQUIERDA" [ set shape "arrowIzq" ]
  if lado = "DERECHA" [ set shape "arrowDer" ]
  set heading 0
end

;;*******************************
;; Definición de agentes parcela:
;;*******************************

patches-own ;; Para definir los atributos de las parcelas.
[
  pobtot     ; población total que será dividida en grupos, cada grupo es un "peaton" que incluye al menos un adulto y un niño, adulto mayor o discapacitado
  cntTotPtns ; cntTotGps = cantidad de peatones en el punto de salida sobre esta parcela
  lstGps     ; lstGps = lista de agrupamientos [[cantidad-de-peatones cantidad-de-grupos]...]
  fg         ; fg = factor de agrupamiento = ( 1 + pobAdt / ( pobNys + pobAdm + pobDsc ))
]

to P-init ;; Para inicializar una parcela a la vez.
  set pobTot 0
  set cntTotPtns 0
  set lstGps []
  set fg 0.0
end

; EFE: crea una lista de grupos de peatones
;      ejemplo: [[3 5] [14 4] [9 3] [13 2]]
;      que indica 3 grupos de 5 peatones,
;                14 grupos de 4 peatones,
;                 9 grupos de 3 peatones,
;                13 grupos de 2 peatones.
to P-crear-peatones
  let cntFg fg         ; secuencia decreciente del factor de agrupamiento
  let pobTotRst pobTot ; población total restante, es decir, no agrupada
  set cntTotPtns 0     ; contador de peatones (grupos de personas)
  let pobAgrupada 0    ; acumula el total de población agrupada para comparar contra pobTot
  while [ ( cntFg > 1 ) and (pobTotRst > 0) ][
    let cntGps random round ( pobTotRst / cntFg )
    show word "se crearán " word cntGps  word " de " word cntFg " peatones cada uno."
    set lstGps lput ( list cntGps cntFg ) lstGps 
    sprout-peatones cntGps [ 
      let tSal 0 ; se debe generar un valor al azar para tic de salida con base en la normal
      peaton-init tSal cntFg ; inicializa cada peatón
    ]
    set pobAgrupada cntGps * cntFg + pobAgrupada
    set pobTotRst pobTotRst - cntGps * cntFg
    set cntFg cntFg - 1
    set cntTotPtns cntTotPtns + cntGps
  ]
  if pobTotRst > 0 [ ;crear pobTotRst de peatones solos, es decir, grupos de una persona para completar la población total.
    show word "se crean " word pobTotRst " de un peaton cada uno."
    set lstGps lput ( list pobTotRst 1 ) lstGps
    set cntTotPtns cntTotPtns + pobTotRst
    sprout-peatones pobTotRst [ 
      let tSal 0 ; se debe generar un valor al azar para tic de salida con base en la normal
      peaton-init tSal 1 ; inicializa cada peatón
    ]    
  ]
  show word lstGps  word " total: " word ptsSal-cuenta-grupos word " cant tot pos grupos: " word cntTotPtns word " pobTot: "word pobTot word " pobAgrup: "  ( pobAgrupada + pobTotRst )
end
@#$#@#$#@
GRAPHICS-WINDOW
210
10
2422
2243
550
550
2.0
1
10
1
1
1
0
1
1
1
-550
550
-550
550
0
0
1
ticks
30.0

BUTTON
55
51
120
84
Iniciar
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
56
97
119
130
go
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

INPUTBOX
48
145
146
205
N-peatones
10
1
0
Number

@#$#@#$#@
## WHAT IS IT?

(a general understanding of what the model is trying to show or explain)

## HOW IT WORKS

(what rules the agents use to create the overall behavior of the model)

## HOW TO USE IT

(how to use the model, including a description of each of the items in the Interface tab)

## THINGS TO NOTICE

(suggested things for the user to notice while running the model)

## THINGS TO TRY

(suggested things for the user to try to do (move sliders, switches, etc.) with the model)

## EXTENDING THE MODEL

(suggested things to add or change in the Code tab to make the model more complicated, detailed, accurate, etc.)

## NETLOGO FEATURES

(interesting or unusual features of NetLogo that the model uses, particularly in the Code tab; or where workarounds were needed for missing features)

## RELATED MODELS

(models in the NetLogo Models Library and elsewhere which are of related interest)

## CREDITS AND REFERENCES

(a reference to the model's URL on the web if it has one, as well as any other necessary credits, citations, and links)
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

arrow 3
true
0
Polygon -7500403 true true 135 255 105 300 105 225 135 195 135 75 105 90 150 0 195 90 165 75 165 195 195 225 195 300 165 255

arrowder
true
0
Polygon -7500403 true true 45 135 0 105 75 105 105 135 225 135 210 105 300 150 210 195 225 165 105 165 75 195 0 195 45 165

arrowizq
true
0
Polygon -7500403 true true 255 165 300 195 225 195 195 165 75 165 90 195 0 150 90 105 75 135 195 135 225 105 300 105 255 135

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270

@#$#@#$#@
NetLogo 5.2.0
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180

@#$#@#$#@
0
@#$#@#$#@
