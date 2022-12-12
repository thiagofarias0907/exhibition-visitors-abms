extensions [array csv]

globals [visitorsTotal contentsList contentsListName contentsListCategory contentsListSubjects contentsListTypeOfInteractions walking interacting exited]

breed [walls wall]

;; the exhibt content breed
breed [contents content]


;contents-own [
;  name
;  strenghtLevel
;  interactionCategory
;  contentCategory
;  contentSubject
;  knowleadgeDegree
;  complexity
;  attractiveness
;  maxNumberOfVisitors
;  numberOfVisitorsNow
;  visitorsQueue
;]

breed [visitors visitor]
visitors-own[
  visitorAge
  interest
  mostInterestSubject
  mostInterestCategory
  mostInterestTypeOfInteraction
  education
  influence
  visionDistance
  visionDegree
  interactionInterval
  isInteracting
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
  while [ match = False and i <= length contentsList] [
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

;to-report getContentValue[tag contentAsList]
;  if tag = "content"[
;    report 0 item contentAsList
;  ]	
;  if tag = "subject"[
;    report 0 item contentAsList
;  ]	
;  if tag = "interaction"[
;    report 0 item contentAsList
;  ]	
;  if tag = "knowledge"[
;    report 0 item contentAsList
;  ]	
;  if tag = "complexity"[
;    report 0 item contentAsList
;  ]	
;  if tag = "strength_level"[
;    report 0 item contentAsList
;  ]	
;  if tag = "number_visitors_per_cell"[
;    report 0 item contentAsList
;  ]	
;  if tag = "rgb_color"[
;    report 0 item contentAsList
;  ]
;  repor ""
;end

;to-report getContentName [contentAsList]
;  report item 0 contentAsList
;end
;
;
;to-report getContentCategory [contentAsList]
;  report item 1 contentAsList
;end
;
;to-report getContentSubject [contentAsList]
;  report item 3 contentAsList
;end
;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;   DRAW THE MAP BY THE CSV FILE WITH DATA IN PATTERN   ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
to drawMap
 let scale world-width / 20
; show  scale
 let rowCounter 19
 foreach (csv:from-file "agentes.CSV" ";") [
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
                create-walls 1 [ setxy x y hide-turtle]
              ][

                 if-else cellValue = 11 [
                  ask patch x y [set isEntrance true]
                 ][
                   if-else cellValue = 99 [
                     ask patch x y [set isExit true]
                   ][
                     ask patch x y [set name cellValue]
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
 foreach (csv:from-file "contents.csv" ";") [
    contentRow ->
;      show contentRow
      set contentsList lput contentRow contentsList
;      let contentValues contentRow
;      set contentsList lput contentValues contentsList
      let contentValue item 0 contentRow
      set contentsListName lput contentValue contentsListName
;      set contentsColor lput

      set contentValue item 1 contentRow
      set contentsListCategory lput contentValue contentsListCategory
      set contentValue item 2 contentRow
      set contentsListSubjects lput contentValue contentsListSubjects
      set contentValue item 3 contentRow
      set contentsListTypeOfInteractions lput contentValue contentsListTypeOfInteractions

 ]

; show contentsList
; foreach read-from-string contentsList [ c -> set contentsListName lput c contentsListName ]
; show contentsListName
end


;;;;;;;;;;;;;;;;;
;;    SETUP    ;;
;;;;;;;;;;;;;;;;;
to setup
 clear-all
 set visitorsTotal 0

 loadContents

 drawMap

 ;; set the contents by the input

;  ask patches [
;;    if-else count contents > 0 [
;;      set blocked true
;;    ][ set blocked false]
;    set pcolor 89
;  ]

  ;; set common content state
;  create-contents contentNumber [
;    set shape "box"
;    set color random 13 * 10  + 5
;    let xpos random-xcor
;    while [(xpos > -5) and (xpos  < 5)] [
;      set xpos random-xcor
;    ]
;    set xcor xpos
;    set ycor random-ycor
;    set size 1
;
;    ask patch xcor ycor[
;      set blocked true
;    ]


    ;; set random interest  for each visitor
;    let dev (random attractivenessMeanLevel  - (attractivenessMeanLevel / 2))
;    set attractiveness attractivenessMeanLevel + dev
;;    set attractiveness random 100
;
;    set strenghtLevel  0.1
;    set interactionCategory "audiovisual"
;    set contentCategory "movie"
;    set contentSubject "dinosaurs"
;    set knowleadgeDegree "basic"
;    set complexity "low"
;  ]
;  ask contents [
;
;  ]

;  ;; create visitors
;  create-visitors numberOfVisitors [
;    set shape "person"
;    move-to one-of patches with [isEntrance]
;  ]
;
;  ;; set common visitors state
;  ask visitors [
;  ]

  reset-ticks
end


;;;;;;;;;;;;;;;;;;;;;;;;
;;   CREATE VISITOR   ;;
;;;;;;;;;;;;;;;;;;;;;;;;
to createAndSetVisitor

    ;; randomly setting a link to another visitor at entrance
    let createRandom random 100
    if createRandom < 20 [
      let linkedVisitor [who] of (one-of visitors-here)
      if linkedVisitor != [who] of self [
;        move-to visitor linkedVisitor
        set ycor ([ycor] of visitor linkedVisitor )
        create-link-with visitor linkedVisitor [tie]
      ]
    ]

    set visitorAge age
    set education escolaridade
    set visionDistance visionDistanceLimit
    set visionDegree visionDegreeLimit
    set isInteracting false
    set interactionContent nobody

    ;; set random interval of interaction for each visitor
    let dev  (random 30  - (30 / 2))
    set interactionInterval averageInteractionInterval + dev

    ;; set random interest  for each visitor
    set dev (random 10  - (10 / 2)) / 10
    set interest interestLevel + dev

    ;; random interests to score time of interaction
    set mostInterestCategory one-of remove-duplicates contentsListCategory
    set mostInterestSubject one-of remove-duplicates contentsListSubjects
    set mostInterestTypeOfInteraction one-of remove-duplicates  contentsListTypeOfInteractions

    ;; set random influence for each visitor
    set dev (random 15  - (15 / 2)) / 15
    set influence influenceLevel + dev

    ;; set visitedContents
    set visitedContents []

    ;; set time
    set interactionStart 0
    set interactionDuration 0
    set visitDuration 0
    set contentsInteractionDuration n-values length contentsListName [0]


    changeDirection
end


;;;;;;;;;;;;;;;;;
;;   GO LOOP   ;;
;;;;;;;;;;;;;;;;;
to go
  if visitorsTotal <  numberOfVisitors [
    let entrancePatchesCount count patches with [isEntrance]
    let visitorsPerPatch 3
    ask patches with [isEntrance] [
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

  ;; set common visitors state
  ask visitors [
  ]


  ask visitors with [not [isExit] of patch-here ]  [
    setNearbyVisitorsAndContent
    interactionControl
    walk
    updateNextContentQueue
  ]
  set exited 0
  ask patches with [isExit] [
    set exited (exited + count turtles-here)
  ]
  if exited >= numberOfVisitors [ stop ]
  tick
end


;;;;;;;;;;;;;;;;;
;;     WALK    ;;
;;;;;;;;;;;;;;;;;
to walk
  let step 1
  if-else [isExit] of patch-here [
    if visitDuration = 0 [
      set visitDuration ticks
    ]
    set step 0
  ][

    if-else patch-ahead 1 = nobody [
      changeDirection
    ][
      if-else [isBlocked] of patch-ahead 1[
        changeDirection
      ][
        if-else isInteracting [
          if [name] of patch-ahead 1 != [name] of patch-here [
            changeDirection
          ]
        ][
          changeDirection
        ]
      ]
    ]
  ]
  fd step
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
;      let c item i inradiusContent
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
;    show (word "t " ticks " start " interactionStart " exp " contentExpectedTime )
    if (ticks - interactionStart) >= contentExpectedTime [
      let pos (position (last visitedContents) contentsListName)
      let tempCount item pos contentsInteractionDuration
      set contentsInteractionDuration replace-item pos contentsInteractionDuration (ticks - interactionStart + tempCount)
      set isInteracting false
      set interactionStart 0
    ]
  ][
    if not member? [contentId] of patch-here [-1 99 11 0 ""] [
        set interactionStart ticks
        set isInteracting true

        set visitedContents lput [name] of patch-here visitedContents ;; adds a content's name at the end of the list
    ]
  ]
end


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;  CALCULATE THE TIME FOR THE CONTENT   ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
to-report contentExpectedTime
  if [name] of patch-here = ""[

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

  report interactionInterval * interest * (1 + boost)
end


;;; random follow pair calc. Returns True if actor must go to it's pair position
;to-report followPair
;  report
;

;; content influence
to-report contentInfluence
  report 0
end


;; distance influence
to-report ageInfluence
  report 0
end


;; distance influence
to-report distanceInfluence
  report 0
end



;; pair influence
to-report pairInfluence
  report 0
end



;; nearby agent influence
to-report othersInfluence
  report 0
end


;; visited exhibits
to-report visitedExhibits
  report 0
end


;; set next to visit queue
to-report updateQueueOfExhibtsToVisit
  let queue (list 0 1 2)
  report queue
end


;; time spent
to-report timeSpent
  report 0
end


;; time spent on exhibit
to-report timeSpentOnExhibt [exhibt]
  report 0
end

;; calc the mean percentage of exhibits visited by all visitors
to-report percentageOfVisit
  report 0
end

;; calc the average time of visitors
to-report averageVisitTime
  report 0
end

;; calc the average time of interaction of visitors
to-report averageTimeSpentOnExhibt [exhibt]
  report 0
end



to updateNextContentQueue

end


;to whereToGo
;  if any? nearbyVisitors [
;;    ask nearbyVisitors []    ;; to do someting
;  ]
;  if any? nearbyContents [
;
;    ;;if a content is nearby and is interesing, head to its direction
;
;    set heading towards attractiveContent xcor ycor;;agent position
;
;    while [patch-ahead 1 = isBlocked] [
;      ;;if nothing is nearby, return a random heading
;      set heading heading + 18 * ( 5 - random 10)
;    ]
;  ]
;
;  while [patch-ahead 1 = isBlocked] [
;    ;; return a random heading
;    set heading heading + 18 * ( 5 - random 10)
;  ]
;
;end

;;; Find the most attractive content
;to-report attractiveContent [x y]
;  let headToContent nobody
;  let maxAtt 0
;  if any? nearbyContents [
;;    show nearbyContents
;    foreach (sort nearbyContents)  [
;      ncontent ->
;;        show distance myself
;      ifelse ([distancexy x y] of ncontent) = 0 [ ;; was using 'distance self' before
;        let att [attractiveness] of ncontent
;        ;; already visited discount
;        if member? ncontent visitedContents [
;          set att att * ( 1 - visitedDiscountFactor)
;        ]
;
;        ;; update most attractive object
;        if att > maxAtt [
;          set maxAtt att
;          set headToContent  ncontent
;;            print word "MaxAtt dist 0 " maxAtt
;        ]
;      ][
;        ;; attractiveness weighted by the distance to the agent
;        let att  [attractiveness] of ncontent * ( 1 - 1 / ([distancexy x y] of ncontent) )
;
;        ;; already visited discount
;        if member? ncontent visitedContents [
;          set att att * ( 1 - visitedDiscountFactor)
;        ]
;
;        if  att > maxAtt [
;          set maxAtt att
;          set headToContent ncontent
;;            print word "MaxAtt dist <> 0 " maxAtt
;        ]
;      ]
;
;    ]
;  ]
;
;  ;; in case nobody, use the most attractive content
;  if headToContent = nobody [
;    set headToContent max-one-of nearbyContents [attractiveness]
;  ]
;  report headToContent
;end

;to interactionStep
;  if any? nearbyContents [
;    let nearestContent min-one-of nearbyContents [distance myself]
;    if ([distance myself] of nearestContent) <= 1 [
;      set visitedContents lput nearestContent visitedContents ;; adds a content at the end of the list
;    ]
;  ]
;end

;to endInteraction
;end
@#$#@#$#@
GRAPHICS-WINDOW
302
10
710
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
1
1
1
ticks
30.0

BUTTON
19
30
82
63
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

INPUTBOX
18
421
84
481
age
NIL
1
0
String

SLIDER
19
100
191
133
influenceLevel
influenceLevel
0
1
0.4
0.1
1
NIL
HORIZONTAL

SLIDER
19
136
191
169
averageInteractionInterval
averageInteractionInterval
0
300
29.0
1
1
NIL
HORIZONTAL

BUTTON
92
30
155
63
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
19
172
191
205
interestLevel
interestLevel
0
100
10.0
1
1
NIL
HORIZONTAL

SLIDER
19
208
191
241
visionDegreeLimit
visionDegreeLimit
0
180
44.0
1
1
NIL
HORIZONTAL

SLIDER
19
244
191
277
visionDistanceLimit
visionDistanceLimit
0
100
25.0
1
1
NIL
HORIZONTAL

SLIDER
19
325
191
358
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
19
361
192
394
attractivenessMeanLevel
attractivenessMeanLevel
0
100
26.0
1
1
NIL
HORIZONTAL

MONITOR
213
66
283
111
Saíram
exited
0
1
11

CHOOSER
19
279
191
324
escolaridade
escolaridade
"Básico" "Superior" "Especialização"
0

SLIDER
19
65
191
98
numberOfVisitors
numberOfVisitors
1
100
20.0
1
1
NIL
HORIZONTAL

MONITOR
213
116
283
161
Entraram
visitorsTotal
0
1
11

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
