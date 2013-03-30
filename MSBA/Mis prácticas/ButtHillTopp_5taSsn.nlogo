globals ;; Para definir las variables globales.
[
  ;; q  Se elimina porque ahora la variable se define a través del "slider".
]

to init-globals ;; Para darle valor inicial a las variables globales.
  ;; set q 0.4 Se elimina porque ahora la variable se define a través del "slider".
end

to setup ;; Para inicializar la simulación.
  ;; ca            ;; Se elimina ahora porque limpiaría los gráficos también.
  init-globals  
  
  clear-drawing ;; Para limpiar solamente las trazas de las tortugas.
  ct            ;; Para matar las tortugas y volver a empezar.
  
  ;; Para crear tortugas e inicializar tortugas y parcelas.
  ask patches
  [
    P-init
  ]
  crt 50
  [
    T-init
  ]
  
  reset-ticks   ;; Para inicializar el contador de ticks.
  ;; plot-pen-up
  ;; plotxy 0 0
  ;; plot-pen-down
end

;; to go ;; Versión sin el graficador de q contra tics.
;;  ask turtles [T-move]
;;  tick
;;  if ticks >= 1000 
;;  [
;;    let final-corridor-width corridor-width
;;    output-write word "Corridor width: " final-corridor-width ;; OJO: el resultado se muestra por la ventana de salida única.
;;    stop
;;  ] ;; 
;; end

to go
  ask turtles [T-move]
  ;; plot corridor-width
  tick
  if ticks >= 1000 
  [
    plotxy q corridor-width
    stop
  ]
end


;;*******************************
;; Otras procedimientos globales:
;;*******************************

to-report corridor-width
  let number-visited-patches count patches with [used?]
  let mean-distance-to-85-95 mean [distancexy 85 95] of turtles
  report number-visited-patches / mean-distance-to-85-95
end


;;*******************************
;; Definición de agentes tortuga:
;;*******************************

turtles-own ;; Para definir los atributos de las tortugas.
[
  start-patch ;; Nueva variable de estado que permite "recordar" adónde empezó la tortuga.
]

to T-init ;; Para inicializar una tortuga a la vez.
  set size 2
  setxy 85 95
  set start-patch patch-here
end

to T-move ;; Se modifica para que al llegar a la cúspide ya no se mueva más la mariposa.
  if elevation >= [elevation] of max-one-of neighbors [elevation]
     [stop]
  ifelse random-float 1 < q
     [ uphill elevation ]
     [ move-to one-of neighbors ]  
  set used? true ;; Se marca la parcela visitada por la tortuga. 
end

;;*******************************
;; Definición de agentes parcela:
;;*******************************

patches-own ;; Para definir los atributos de las parcelas.
[
  elevation
  used? ;; Nueva variable que indica en true que la parcela ha sido recorrida.
]

to P-init ;; Para inicializar una parcela a la vez.
  set used? false ;; Se inicia en false para indicar que no ha pasado ninguna tortuga todavía.
  let elev1 100 - distancexy 30 30
  let elev2 50 - distancexy 120 100
  
  ifelse elev1 > elev2
     [set elevation elev1]
     [set elevation elev2]
  set pcolor scale-color green elevation 0 100
end


;;****************************
;; Definición de agentes link:
;;****************************

links-own ;; Para definir los atributos de los links o conexiones.
[
  
]

to L-init ;; Para inicializar un link o conexión a la vez.
  
end
@#$#@#$#@
GRAPHICS-WINDOW
250
12
1010
793
-1
-1
5.0
1
10
1
1
1
0
0
0
1
0
149
0
149
0
0
1
ticks
30.0

BUTTON
135
21
198
54
NIL
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

BUTTON
70
21
133
54
NIL
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

SLIDER
44
61
216
94
q
q
0
1
1
0.1
1
NIL
HORIZONTAL

OUTPUT
5
103
245
157
12

PLOT
40
195
240
345
Ancho de corredor por tic
tick
Corridor Width
0.0
999.0
0.0
100.0
true
false
"" ""
PENS
"pen-0" 1.0 0 -7500403 true "" ""

PLOT
40
358
240
574
Ancho del corredor X q
q
Ancho del corredor
0.0
1.0
0.0
100.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" ""

@#$#@#$#@
## ¿DE QUÉ SE TRATA?

El modelo fue diseñado para explorar cuestiones sobre "corredores virtuales". ¿Bajo qué condiciones las interacciones entre el comportamiento de escalar colinas de las mariposas y la topografía del paisaje da lugar al surgimiento de "corredores virtuales", esto es, angostos pasadizos a lo largo de los cuales transitan muchas mariposas? ¿Cómo se ven afectados estos "corredores virtuales" por la variabilidad en la tendencia de las mariposas a escalar colinas?

## ¿CÓMO FUNCIONA?

(qué reglas usan los agentes para orginar el funcionamiento del modelo)

## ¿CÓMO USARLO?

(cómo usar el modelo, incluye una descripción de cada uno de los controles en la interfaz)

## ¿QUÉ TOMAR EN CUENTA?

(cosas que debe tener en cuenta el usuario al ejecutar el modelo)

## ¿QUÉ PROBAR?

(sugerencias para el usuario sobre qué pruebas realizar (mover los "sliders", los "switches", etc.) con el modelo)

## EXTENDIENDO EL MODELO

(sugerencias sobre cómo realizar adiciones o cambios en el código del modelo para hacerlo más complejo, detallado, preciso, etc.)

## CARACTERÍSTICAS NETLOGO

(características interesantes o inusuales de NetLogo que usa el modelo, particularmente de código; o cómo se logra implementar características inexistentes)

## MODELOS RELACIONADOS 

(otros modelos de interés disponibles en la Librería de Modelos de NetLogo o en otros repositorios de modelos)

## CRÉDITOS AND REFERENCIAS

Pe’er, G., Saltz, D. & Frank, K. 2005. Virtual corridors for conservation management. _Conservation Biology_, 19, 1997–2003.

Pe’er, G. 2003. Spatial and behavioral determinants of butterfly movement patterns in topographically complex landscapes. Ph.D. thesis, Ben-Gurion University of the Negev.

Railsback, S. & Grimm, V. 2012. _Agent-based and individual-based modeling: A practical introduction_. Princeton University Press, Princeton, NJ.

## ODD - ESPECIFICACIÓN DETALLADA DEL MODELO

## Título
Butterfly Hilltopping

## Autores
Pe'er, G., Saltz, D. y Frank, K.

## Visión
## 1  Objetivos: Explorar cuestiones acerca de corredores virtuales.

 1.1  ¿Bajo qué condiciones de interacción entre el comportamiento de mariposas que suben una colina y la topografía del paisaje emergen “corredores virtuales” o pasadizos angostos con muchas mariposas en tránsito?
 1.2  ¿Cómo se ven afectados  los “corredores virtuales” que emergen  ante la variabilidad de la tendencia de las mariposas de subir una colina?

## 2  Entidades, variables de estado y escalas:

 2.1  Mariposas: se caracterizan solamente por su posición en el paisaje de parcelas.
 2.2  Parcelas: forman un paisaje de 150x150, cada parcela tiene un valor de elevación como variable de estado.
 2.3  Escalas: 
 2.3.1  Cuando se usan datos de un paisaje real, cada parcela corresponde con un cuadrado de 25 m2.
 2.3.2  Cada simulación dura 1000 tics, cada tic corresponde aproximadamente con el tiempo que dura una mariposa en moverse de 25 a 35 metros (o sea la distancia aproximada entre el centro de dos parcelas).

## 3  Visión del proceso y programación:
 3.1  Sólo hay un proceso y es el movimiento de las mariposas. En cada tic de la simulación, las mariposas se mueven una vez. El orden en que las mariposas se mueven no es relevante porque no hay interacciones entre las mariposas.

## Conceptos del diseño
## 4  Propiedades del modelo:
##  4.1  Básicas:  La principal propiedad del comportamiento de las mariposas que el modelo trata es el de la formación de “corredores virtuales” o pasadizos más o menos angostos usados por las mariposas cuando no hay ningún beneficio particular en usarlos.

##  4.2  Emergentes: Se considera que los “corredores virtuales” emergen del comportamiento adaptativo de las mariposas y del paisaje en que éstas se mueven.

##  4.3  Adaptabilidad: El comportamiento adaptativo es modelado a través de una simple regla que reproduce el comportamiento observado en las mariposas: el movimiento hacia arriba en la colina. Se supone que las mariposas se mueven hacia arriba para aparearse (aspecto que no se incluye en el modelo). Debido a que se asume el comportamiento de las mariposas (hacia arriba en la colina) se descartan los conceptos de “meta” y “predictibilidad”, tampoco hay “aprendizaje” en el modelo.

##  4.4  Metas:

##  4.5  Aprendizaje:

##  4.6  Predictibilidad:

##  4.7  Sensibilidad:  Se supone que las mariposas son capaces de determinar cuál de las parcelas a su alrededor tiene la mayor elevación, pero también que no pueden acceder información acerca de la elevación en parcelas que están más allá de su entorno inmediato.

##  4.8  Interacciones: Se supone que las mariposas no interactúan. Aunque en otros estudios los autores encontraron que sí lo hacen, lo descartaron como una característica relevante para este modelo de los “corredores virtuales”.

##  4.9  Estocasticidad: Se usa para representar dos fuentes de variabilidad en el movimiento que es muy complejo para ser modelado mecánicamente. Las mariposas no siempre se mueven hacia arriba en la colina, probablemente debido a: 1) limitaciones en la habilidad de las mariposas para detectar el área más elevada en su entorno y 2) otros factores además de la mera topografía (por ejemplo flores que tienden a explorar durante su viaje). Esta variabilidad se modela mediante un movimiento al azar usando un parámetro q (0 < q < 1) que representa la probabilidad de que la mariposa se mueva hacia arriba en la colina (1 – q representaría la posibilidad de que se mueva en otra dirección).

##  4.10  Colectividades:

##  4.11  Salidas: La principal medida es la “amplitud de corredor” que determina el ancho del pasadizo seguido por una mariposa desde su punto de salida hasta que llegó a la cúspide de la colina.

## Detalles
##  5  Inicialización: El paisaje o topografía es inicializado al comienzo de la simulación y se hace en dos variantes: 1) una topografía artificial muy simple y 2) una topografía basada en un sitio real, que se importa de un archivo que contiene la elevación de cada parcela. Al comienzo se crean 500 mariposas y se ubican en una misma parcela inicial o en una región pequeña del paisaje.

##  6  Datos de entrada:

##  7  Submodelos: El movimiento de cada mariposa se basa en el parámetro q.  Se obtiene un número entre cero y uno al azar, con base en una distribución uniforme. Si dicho número es menor que q la mariposa escogerá la parcela más alta de las ocho en su entorno inmediato. Si hubiese dos o más con la misma elevación mayor, entonces se escoge alguna al azar entre las que tienen la mayor elevación. Si el valor es mayor o igual a q, la mariposa se traslada a cualquier parcela al azar.
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
0
Rectangle -7500403 true true 151 225 180 285
Rectangle -7500403 true true 47 225 75 285
Rectangle -7500403 true true 15 75 210 225
Circle -7500403 true true 135 75 150
Circle -16777216 true false 165 76 116

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
Polygon -7500403 true true 135 285 195 285 270 90 30 90 105 285
Polygon -7500403 true true 270 90 225 15 180 90
Polygon -7500403 true true 30 90 75 15 120 90
Circle -1 true false 183 138 24
Circle -1 true false 93 138 24

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270

@#$#@#$#@
NetLogo 5.0.3
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 1.0 0.0
0.0 1 1.0 0.0
0.2 0 1.0 0.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180

@#$#@#$#@
0
@#$#@#$#@
