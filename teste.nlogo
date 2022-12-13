extensions [array csv]

globals [
  visitorsTotal
  contentsList
  contentsListName
  contentsListCategory
  contentsListSubjects
  contentsListTypeOfInteractions
  contentsListAttractiveness
  walking
  interacting
  exited]

;; the exhibt content breed
breed [contents content]

breed [visitors visitor]
visitors-own[
  visitorAge
  interest
  mostInterestSubject
  mostInterestCategory
  mostInterestTypeOfInteraction
  scholarship
  influence
  visionDistance
  interactionInterval
  isInteracting
  movingToContent
  interactionContent

  ;; set of nearby visitors and contents
  nearbyVisitors
  nearbyContents
  visitedContents

  ;; time controls
  interactionStart
  interactionDuration
  visitDuration
  contentsInteractionDuration
]


patches-own [
  isBlocked
  isEntrance
  isExit
  contentId

  name
  strenghtLevel
  interactionCategory
  contentCategory
  contentSubject
  knowleadgeDegree
  complexity
  attractiveness
  maxNumberOfVisitors
  numberOfVisitorsNow
  visitorsQueue
]

to-report getColor [cellValue]

  if cellValue = "" [
    report 9
  ]

  if cellValue = -1 [
    report black
  ]

  if cellValue = 99 [
    report 123
  ]

  if cellValue = 11 [
    report blue
  ]

  if cellValue = 11 [
    report blue
  ]

  if member? cellValue contentsListName [
    let color_match getContentMatchTagValue cellValue "rgb_color"

    if color_match = "Not found" [
      set color_match orange
    ]
    report color_match

  ]

  report white

end


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;   GET THE TAG'S VALUE FOR THE CONTENT MATCHING NAME   ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
to-report getContentMatchTagValue[nameValue tag]
  let match  false
  let i 0
  while [ match = False and i < length contentsList] [
    let c item i contentsList

    let nameOfContent item 0 c
    if nameValue = nameOfContent [
      set match true
      if tag = "content"[
        report item 1 c
      ]	
      if tag = "subject"[
        report item 2 c
      ]	
      if tag = "interaction"[
        report item 3 c
      ]	
      if tag = "knowledge"[
        report item 4 c
      ]	
      if tag = "complexity"[
        report item 5 c
      ]	
      if tag = "strength_level"[
        report item 6 c
      ]	
      if tag = "number_visitors_per_cell"[
        report item 7 c
      ]	
      if tag = "rgb_color"[
        report item 8 c
      ]
    ]
    set i i + 1	
  ]

  report "Not found"
end


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;   DRAW THE MAP BY THE CSV FILE WITH DATA IN PATTERN   ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
to drawMap
 let scale world-width / 20
; show  scale
 let rowCounter 19

 let f "agentes.csv"
 if fileName != "" [
    set f fileName
    show f
 ]
 foreach (csv:from-file f ";") [
    row ->
;      show row
      let columnCounter 0
      foreach row [
        cellValue ->
          let xScaleCounter 0
          while [xScaleCounter < scale] [
            let yScaleCounter 0
            while [yScaleCounter < scale] [
              let x (columnCounter * scale + xScaleCounter)
              let y (rowCounter * scale + yScaleCounter)
;              show (word  " ( "  x ", " y ") = " cellValue )
              ask patch x y [set isEntrance false]
              ask patch x y [set isExit false]
              ask patch x y [set isBlocked false]
              ask patch x y [set contentId cellValue]

              ask patch x y [set pcolor getColor cellValue ]

              if-else cellValue = -1 [
                ask patch x y [set isBlocked true]
              ][

                 if-else cellValue = 11 [
                  ask patch x y [set isEntrance true]
                 ][
                   if-else cellValue = 99 [
                     ask patch x y [set isExit true]
                   ][
                     ask patch x y [
                       set name cellValue
                    ]
                   ]
                 ]
              ]
              set yScaleCounter yScaleCounter + 1
            ]
            set xScaleCounter xScaleCounter + 1
          ]
          set columnCounter (columnCounter + 1)
      ]
      set rowCounter (rowCounter - 1)
 ]

end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;    READ THE CONTENTS CSV FILE TO FIND THE CONTENTS    ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
to loadContents
 set contentsListName (list)
 set contentsList (list)
 set contentsListCategory (list)
 set contentsListSubjects (list)
 set contentsListTypeOfInteractions (list)
 set contentsListAttractiveness (list)
 foreach (csv:from-file "contents.csv" ";") [
    contentRow ->
      set contentsList lput contentRow contentsList
      let contentValue item 0 contentRow
      set contentsListName lput contentValue contentsListName
      set contentValue item 1 contentRow
      set contentsListCategory lput contentValue contentsListCategory
      set contentValue item 2 contentRow
      set contentsListSubjects lput contentValue contentsListSubjects
      set contentValue item 3 contentRow
      set contentsListTypeOfInteractions lput contentValue contentsListTypeOfInteractions

      ;; add a random attractiveness for each content patch
      let dev (random attractivenessMeanLevel  - (attractivenessMeanLevel / 2))
      set contentsListAttractiveness lput (attractivenessMeanLevel + dev) contentsListAttractiveness

 ]

end


;;;;;;;;;;;;;;;;;
;;    SETUP    ;;
;;;;;;;;;;;;;;;;;
to setup
 clear-all
 set visitorsTotal 0
 loadContents
 drawMap
 reset-ticks
end


;;;;;;;;;;;;;;;;;;;;;;;;
;;   CREATE VISITOR   ;;
;;;;;;;;;;;;;;;;;;;;;;;;
to createAndSetVisitor

;    ;; randomly setting a link to another visitor at entrance
;    let createRandom random 100
;    if createRandom < 20 [
;      let linkedVisitor [who] of (one-of visitors-here)
;      if linkedVisitor != [who] of self [
;;        move-to visitor linkedVisitor
;        set ycor ([ycor] of visitor linkedVisitor )
;        create-link-with visitor linkedVisitor [tie]
;      ]
;    ]


;    set shape "person"

    set scholarship scholarshipLevel
    set visionDistance visionDistanceLimit
    set isInteracting false
    set interactionContent nobody

    ;; set random interval of interaction for each visitor
    let dev  (random averageInteractionInterval  - (averageInteractionInterval / 2))
    set interactionInterval averageInteractionInterval + dev

    ;; set random interest  for each visitor
    set dev (random interestLevel  - (interestLevel / 2)) / interestLevel
    set interest interestLevel + dev

    ;; set random age for each visitor
    set dev (random meanAge  - (meanAge / 2))
    set visitorAge meanAge + dev

    ;; random interests to score time of interaction
    set mostInterestCategory one-of remove-duplicates contentsListCategory
    set mostInterestSubject one-of remove-duplicates contentsListSubjects
    set mostInterestTypeOfInteraction one-of remove-duplicates  contentsListTypeOfInteractions

    ;; set random influence for each visitor
    set dev (random influenceLevel  - (influenceLevel / 2)) / influenceLevel
    if-else influenceLevel + dev > 1 [
      set influence 1
    ][
      set influence influenceLevel + dev
    ]


    ;; set visitedContents
    set visitedContents []


    ;; set time
    set interactionStart 0
    set interactionDuration 0
    set visitDuration 0
    set contentsInteractionDuration n-values length contentsListName [0]

    ;; directions control
    set movingToContent false
    changeDirection



end


;;;;;;;;;;;;;;;;;
;;   GO LOOP   ;;
;;;;;;;;;;;;;;;;;
to go

  if (visitorsTotal <  numberOfVisitors) and (remainder ticks 30 = 0) [  ;; add a remainder to slow the number of entrance
    let entrancePatchesCount count patches with [isEntrance]
    let visitorsPerPatch 3
;    ask patches with [isEntrance] [
    ask one-of patches with [isEntrance] [ ;; slow the number of

      if-else (numberOfVisitors - visitorsTotal) >= visitorsPerPatch [
        sprout-visitors visitorsPerPatch [
          createAndSetVisitor
        ]
        set visitorsTotal visitorsTotal + visitorsPerPatch
      ][
        if (numberOfVisitors - visitorsTotal) > 0 [
          sprout-visitors numberOfVisitors - visitorsTotal [
            createAndSetVisitor
          ]
          set visitorsTotal visitorsTotal + (numberOfVisitors - visitorsTotal)

        ]
      ]
    ]
  ]

  ask visitors with [not [isExit] of patch-here ]  [
    setNearbyVisitorsAndContent
    interactionControl
    walk
  ]

  set walking 0
  ask patches with [contentId = "" or contentId = 0] [
    set walking (walking + count turtles-here)
  ]
  set interacting count visitors with [isInteracting]

  set exited 0
  ask patches with [isExit] [
    set exited (exited + count turtles-here)
  ]
  if exited >= numberOfVisitors [
    printAllStats
    stop
  ]

  tick
end


;;;;;;;;;;;;;;;;;
;;     WALK    ;;
;;;;;;;;;;;;;;;;;
to walk
  let step 1
  if-else [isExit] of patch-here [
    set step 0
  ][

    if-else patch-ahead 1 = nobody [
      changeDirection
    ][
       if-else isInteracting [ ;; remain on the content's interaction area while is interacting
        while [[name] of patch-ahead 1 != [name] of patch-here] [
          changeDirection
        ]
      ][
        ;; in case it's not interacting anymore, change it's heading content
        whereToGo

        if [isBlocked] of patch-ahead 1 [
          changeDirection
        ]
      ]
    ]
  ]


  ;; add a step
  fd step

  ;; save time in case has reached the end
  if [isExit] of patch-here  [
    set visitDuration ticks
  ]

  ;; control the path drawing of selected visitor
  if (any? visitors with [ pen-mode = "down"]) and (not drawPathOfVisitor) [
    set pen-mode "up"
    pen-erase
  ]
  if (showPathOfVisitor != 0 ) and drawPathOfVisitor [
    if ( visitor showPathOfVisitor != nobody) [
      ask visitor showPathOfVisitor [
        set pen-mode "down"
        set pen-size 1
      ]
    ]
  ]


end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;   CHANGE DIRECTION IN CASE OF A WALL  ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
to changeDirection
  let turn true
  while [turn]  [
    set heading heading + 18 * ( 5 - random 10)
    if patch-ahead 1 != nobody [
      set turn [isBlocked] of patch-ahead 1
    ]
  ]

end



;;;;;;;;;;;;;;;;;
;;   NEARBY    ;;
;;;;;;;;;;;;;;;;;
to setNearbyVisitorsAndContent

  set nearbyVisitors other visitors in-radius visionDistance
  let nearbyContentsList (list)

  let inradiusContent patches in-radius visionDistance
  set inradiusContent inradiusContent with [member? name contentsListName]

  let i 0
  while [i < count  inradiusContent] [
    let block false
    ask inradiusContent [
      let d distance myself

      while [d > 0 and block = false] [
        let p patch-at-heading-and-distance towards myself d
        if-else p = nobody [
          set block true
        ][
          if [isBlocked] of p [
            set block true
          ]
        ]
        set d d - 1
      ]
      set i i + 1

      if block = false [
        set nearbyContentsList lput self nearbyContentsList
      ]
    ]

  ]
  set nearbyContents patches with [member? self nearbyContentsList]

end


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;   CONTROL THE INTERACTION ACTIVE NOW  ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
to interactionControl

  if-else isInteracting [
    set movingToContent false
;    show (word "t " ticks " start " interactionStart " exp " contentExpectedTime )
    if (ticks - interactionStart) >= contentExpectedTime [
      let pos (position (last visitedContents) contentsListName)
      let tempCount item pos contentsInteractionDuration
      set contentsInteractionDuration replace-item pos contentsInteractionDuration (ticks - interactionStart + tempCount)
      set isInteracting false
      set interactionStart 0
      set interactionContent nobody
    ]
  ][
    if not member? [contentId] of patch-here [-1 99 11 0 ""] [
      if-else length visitedContents   > 0 [
        if [contentId] of patch-here != last visitedContents [
          set movingToContent false
          set interactionStart ticks
          set isInteracting true
          set visitedContents lput [name] of patch-here visitedContents ;; adds a content's name at the end of the list
        ]
      ][
        set movingToContent false
        set interactionStart ticks
        set isInteracting true
        set visitedContents lput [name] of patch-here visitedContents ;; adds a content's name at the end of the list
      ]
    ]
  ]
end


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;  CALCULATE THE TIME FOR THE CONTENT   ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
to-report contentExpectedTime
  report interactionInterval * interactionBoostFactor
end


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;    CALCULATES THE BOOST RATE BY OTHERS' INFLUENCE    ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
to-report interactionInfluenceFactor [ contentName ]
  if count nearbyVisitors = 0 [
    report 1
  ]
  let boost 0

  let visitorsNearbyTotal count nearbyVisitors
  let qtty count nearbyVisitors with [[name] of patch-here  = contentName ]
;  show influence * (visitorsNearbyTotal - qtty) / visitorsNearbyTotal
  report influence * (1 + (visitorsNearbyTotal - qtty) / visitorsNearbyTotal)
end



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;     CALCULATES THE BOOST DONE BY THE CONTENT     ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
to-report interactionBoostFactor
  if [name] of patch-here = "" or [name] of patch-here = 0 [
    report 0
  ]
  let boost 0

  if mostInterestCategory =  [contentCategory] of patch-here [
    set boost boost + 0.1
  ]
  if mostInterestSubject =  [contentSubject] of patch-here [
    set boost boost + 0.2
  ]
  if mostInterestTypeOfInteraction =  [interactionCategory] of patch-here [
    set boost boost + 0.3
  ]

  if (getContentMatchTagValue [name] of patch-here "knowledge")  > scholarship [
    set boost boost - 0.2
  ]
  if (getContentMatchTagValue [name] of patch-here "complexity") > ( scholarship + visitorAge / 7) / 2  [
    set boost boost - 0.3
  ]
  if (getContentMatchTagValue [name] of patch-here "strength_level") > visitorAge / 7 [
    set boost boost - 0.1
  ]

  report 1 + boost
end




;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;                        STATISTICS                         ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to printAllStats
  show "--- % Percentuais de Visitação ---"
  foreach contentsListName [ c -> show (word "" c " " item (position c contentsListName) percentageOfVisit " %")]
  show (word "Média % de visitação das exposições: " mean percentageOfVisit " %")
  show "==="

  show "--- Tempo médio (ticks) de interação dos usuários por exposição ---"
  foreach contentsListName [ c -> show (word "" c " " item (position c contentsListName) averageTimeSpentOnExhibits " ticks")]
  show (word "Tempo Médio (ticks) de visitação das exposições: " mean averageTimeSpentOnExhibits " ticks")
  show "==="

  show "--- Tempo médio (ticks) de duração total da visitação do espaço ---"
  show (word "Tempo Médio de visitação: " averageVisitTime " ticks")

end



;; calc the percentage of visitors that interacted with the exhibitions
to-report percentageOfVisit
  let contentsVisitPercs n-values length contentsListName [0]
  ask visitors [
    let index 0
    while [index < length contentsInteractionDuration ]  [
      if (item index contentsInteractionDuration) > 0 [
        let actualVisitValue (item index contentsVisitPercs)
        let updateValue actualVisitValue + 100 * 1 / numberOfVisitors
        set contentsVisitPercs replace-item index contentsVisitPercs updateValue
      ]
      set index index + 1
    ]
  ]
  report contentsVisitPercs
end

;; calc the average visit time of visitors
to-report averageVisitTime
  let meanVisitTotalTime 0
  ask visitors [
    set meanVisitTotalTime meanVisitTotalTime + (visitDuration / numberOfVisitors )
  ]
  report meanVisitTotalTime
end

;; calc the average time of interaction of visitors by Content Exhibt
to-report averageTimeSpentOnExhibits
  let averageTimeSpent n-values length contentsListName [0]
  ask visitors [
    let index 0
    while [index < length contentsInteractionDuration ]  [

      let actualValue (item index averageTimeSpent)
      let updateValue actualValue + (item index contentsInteractionDuration) / numberOfVisitors
      set averageTimeSpent replace-item index averageTimeSpent updateValue

      set index index + 1
    ]
  ]
  report averageTimeSpent
end





;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;         WHERE TO GO BASED UPON ON ATTRACTIVENESS          ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to whereToGo
  if-else isInteracting  [
    ;; do nothing
  ][
    if-else movingToContent [

      ;; avoid aiming to the same content
      if-else [contentId] of patch-here = [contentId] of interactionContent [
        ;; set to none
        set interactionContent nobody
        set movingToContent false
      ]
      [

        set heading towards interactionContent ;; keep it in case it's moving towards an already calculated most attractive content
      ]
    ][

      if count nearbyContents > 0 [

        ;;if a content is nearby and is interesing, head to its direction
        set interactionContent attractiveContent xcor ycor;; relative to it's actual position
        if interactionContent != nobody [
          set heading towards interactionContent
          set movingToContent true
        ]

      ]
    ]
  ]

end

;; Find the most attractive content
to-report attractiveContent [x y]

  let headToContent nobody
  let maxAtt 0

  ; only different ones
  let filteredNearbyContent with [contentId != [contentId] of patch-here ] nearbyContents

  if count nearbyContents > 0 [
    foreach (sort filteredNearbyContent)  [ ;;sort used here was a trick in order to set an agentset as list
      ncontent ->

      ;; get attractiveness from contentsListAttractiveness
      let pos (position [name] of ncontent contentsListName)
;      show (word pos " " [name] of ncontent " " contentsListName )
      let baseAtt item pos contentsListAttractiveness
      set baseAtt baseAtt * interactionBoostFactor * (interactionInfluenceFactor [name] of ncontent)

;      show [distancexy x y] of ncontent
      ifelse ([distancexy x y] of ncontent) = 0 [ ;; was using 'distance self' before
        let att baseAtt

        ;; same as the current
        if-else ([contentId] of ncontent = last visitedContents)  [

          ;;do nothing
        ][
          ;; already visited discount
          if member? ([name] of ncontent) visitedContents [
            set att att * ( 1 - visitedDiscountFactor)
          ]

          ;; update most attractive object
          if att > maxAtt [
            set maxAtt att
            set headToContent  ncontent
            print word "MaxAtt dist 0 " maxAtt
          ]
        ]

;        show (word " d = 0 ncontent " ncontent " id " [contentId] of ncontent " visited " visitedContents " baseAtt " baseAtt  " att  " att  )
      ][

        let att baseAtt
        ;; already visited discount
        if member? ncontent visitedContents [
          set att att * ( 1 - visitedDiscountFactor)

        ]
        ;; attractiveness weighted by the distance to the agent
        set att  att  / ([distancexy x y] of ncontent)

        if  att > maxAtt [
          set maxAtt att
          set headToContent ncontent
;          print word "MaxAtt dist <> 0 " maxAtt
        ]
;        show (word " d > 0 --- ncontent " ncontent " id " [contentId] of ncontent " visited " visitedContents " baseAtt " baseAtt  " att  " att  )
      ]


    ]
  ]

  ;; in case nobody, head to one that's not visited
  if headToContent = nobody [
    foreach sort(nearbyContents) [
      nearCont ->

      if position ([contentId] of nearCont) visitedContents = false [
       set headToContent nearCont
      ]
    ]

  ]


;  show (word "Curr. "  [contentId] of patch-here " Content: " [name] of headToContent " " headToContent )
  report headToContent
end
@#$#@#$#@
GRAPHICS-WINDOW
303
10
711
419
-1
-1
10.0
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
39
0
39
0
0
1
ticks
60.0

BUTTON
24
10
87
43
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
19
142
135
175
influenceLevel
influenceLevel
0.1
1
0.4
0.1
1
NIL
HORIZONTAL

SLIDER
61
217
233
250
averageInteractionInterval
averageInteractionInterval
10
300
16.0
1
1
NIL
HORIZONTAL

BUTTON
97
10
160
43
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

SLIDER
148
106
275
139
interestLevel
interestLevel
1
10
1.0
1
1
NIL
HORIZONTAL

SLIDER
148
70
275
103
visionDistanceLimit
visionDistanceLimit
0
100
20.0
1
1
NIL
HORIZONTAL

SLIDER
61
181
233
214
visitedDiscountFactor
visitedDiscountFactor
0
1
1.0
0.001
1
NIL
HORIZONTAL

SLIDER
60
255
233
288
attractivenessMeanLevel
attractivenessMeanLevel
0
100
23.0
1
1
NIL
HORIZONTAL

MONITOR
729
11
799
56
Saíram
exited
0
1
11

SLIDER
19
71
135
104
numberOfVisitors
numberOfVisitors
1
100
19.0
1
1
NIL
HORIZONTAL

MONITOR
729
61
799
106
Entraram
visitorsTotal
0
1
11

INPUTBOX
137
351
292
411
showPathOfVisitor
540.0
1
0
Number

SWITCH
136
312
292
345
drawPathOfVisitor
drawPathOfVisitor
1
1
-1000

PLOT
412
563
612
713
Gráfico
ticks
Qtd
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"Andando" 1.0 0 -5987164 true "" "plot walking"
"Interagindo" 1.0 0 -8330359 true "" "plot interacting"
"Saiu" 1.0 0 -408670 true "" "plot exited"

MONITOR
728
120
809
165
Caminhando
walking
0
1
11

MONITOR
726
182
810
227
Mover p/ Objeto
count visitors with [movingToContent]
0
1
11

MONITOR
728
238
806
283
Interagindo
interacting
0
1
11

SLIDER
19
106
135
139
meanAge
meanAge
3
80
20.0
2
1
anos
HORIZONTAL

PLOT
616
561
816
711
Histograma - Idade
NIL
NIL
0.0
20.0
0.0
20.0
true
false
"" ""
PENS
"Idade" 1.0 1 -13791810 true "\n" "histogram [visitorAge] of visitors"

SLIDER
148
140
277
173
scholarshipLevel
scholarshipLevel
1
3
1.0
1
1
NIL
HORIZONTAL

PLOT
411
441
815
561
Histograma % visita de cada conteúdo expo
NIL
NIL
0.0
100.0
0.0
15.0
false
false
"" ""
PENS
"default" 10.0 1 -16777216 true "" "histogram percentageOfVisit"

BUTTON
175
10
273
43
NIL
printAllStats
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

PLOT
7
441
407
561
Distribuição do Tempo Médio (ticks) de interação pelos visitantes
NIL
NIL
0.0
1000.0
0.0
10.0
true
false
"" ""
PENS
"default" 100.0 1 -16777216 true "" "histogram averageTimeSpentOnExhibits"

PLOT
7
565
207
715
Médias de tempo
NIL
Média em Ticks
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"Visitação" 1.0 0 -5825686 true "" "plot averageVisitTime"
"Por Conteúdo" 1.0 0 -14439633 true "" "plot mean averageTimeSpentOnExhibits"

INPUTBOX
9
329
127
389
fileName
agentes_sem_parede.csv
1
0
String

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
NetLogo 6.3.0
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
