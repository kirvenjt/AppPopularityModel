extensions [array]

globals [
  numgroups 
  groupSizes 
  groupsHaveCount
  person-talking-influence
  never-get-threshold
  get-threshold
  last-app-get-tick
  conversations-between-friends
  ]

breed [groups group] 

breed [people person]

groups-own
[
  group-utility
  group-funness
  group-cost
  group-userfriendliness
  group-level-of-influence
]

people-own
 [
  grouplist
  app?
  importance-utility
  importance-funness
  importance-cost
  importance-userfriendliness
  level-of-influence
  exposure-to-app
  app-score
  get-score
 ]
 
to step
  go
  ask people [app-score-get]
end

to setup
  clear-all
 
  set numgroups 10
  set never-get-threshold 20 * .6
  set get-threshold 60
  setup-patches
  setup-groups
  setup-people
   reset-ticks
  setup-people-with-app
  
end

to setup-patches
  ask patches [ set pcolor green ]
end

to setup-groups
  set groupSizes array:from-list n-values 10 [0]
  set groupsHaveCount array:from-list n-values 10 [0]
  
  create-groups numgroups  
  random-seed randomseed;;137
  ask groups [set group-utility random-normal 5 2] 
  ask groups [set group-funness random-normal 5 2] 
  ask groups [set group-cost random-normal 5 2]      
  ask groups [set group-userfriendliness random-normal 5 2] 
  ask groups [set group-level-of-influence random-normal 5 2] 
  
  ask groups [set color green]
  show-group-characteristics
  set conversations-between-friends 0
end

to setup-people
  create-people number-of-people[ setxy random-xcor random-ycor 
    set color blue
    set shape "person"
    set app? false
    set grouplist (list random numgroups random numgroups random numgroups)]

  ask people [set-characteristics-from-group]
  print sentence "the size of the groups:" groupSizes
end

to set-characteristics-from-group
  
  ;gets the group from the # in the grouplist 
  let G1 group (item 0 grouplist)
  let G2 group (item 1 grouplist)
  let G3 group (item 2 grouplist)
  
  foreach [0 1 2 3 4 5 6 7 8 9] [
    
      if (member? ?1 grouplist) [array:set groupSizes ?1 (array:item groupSizes ?1 + 1)] ;;if not already talking?
          
        ]

  let locUtility1 [group-utility] of G1
  let locFun1 [group-funness] of G1
  let locCost1 [group-cost] of G1
  let locUserFriend1 [group-userfriendliness] of G1  
  let locLevelInfluence1 [group-level-of-influence] of G1  
  
  let locUtility2 [group-utility] of G2
  let locFun2 [group-funness] of G2
  let locCost2 [group-cost] of G2
  let locUserFriend2 [group-userfriendliness] of G2 
  let locLevelInfluence2 [group-level-of-influence] of G2
  
  let locUtility3 [group-utility] of G3
  let locFun3 [group-funness] of G3
  let locCost3 [group-cost] of G3
  let locUserFriend3 [group-userfriendliness] of G3
  let locLevelInfluence3 [group-level-of-influence] of G3
  
  set importance-utility random-normal ((locUtility1 * 1.5 + locUtility2 + locUtility3 * .5) / 3) .5
  set importance-funness random-normal ((locFun3 * 1.5 + locFun3 + locFun3 * .5) / 3) .5
  set importance-cost  random-normal ((locCost1 * 1.5 + locCost2 + locCost3 * .5) / 3) .5
  set importance-userfriendliness  random-normal ((locUserFriend1 * 1.5 + locUserFriend2 + locUserFriend3 * .5) / 3) .5
  set level-of-influence  random-normal ((locLevelInfluence1 * 1.5 + locLevelInfluence2 + locLevelInfluence3 * .5) / 3) .5
  set exposure-to-app 0
  
  app-score-get
  ;show app-score
end

to app-score-get
  
  ;; app-person = negative --> app-score =0
  ;; app-person = 0 or positve --> app-score = ranking * score multiplier
  ;; score-multiplier = sum of rankings for all importance factors/4
  let utility-weight 1.11
  let funness-weight 1.10
  let user-friendly-weight 1
  let cost-weight .4
  
  set app-score 0
  let importance-rankings-sum (importance-utility + importance-funness + importance-userfriendliness)
  let score-multiplier (importance-rankings-sum / 3)
  
  if (app-utility-rating - importance-utility >= 0)  [set app-score (app-score + importance-utility * utility-weight * score-multiplier )]
  
  if (app-funness-rating - importance-funness >= 0)  [set app-score (app-score + importance-funness * funness-weight * score-multiplier )]
  
  if (app-user-friendliness-rating - importance-userfriendliness >= 0) [set app-score (app-score + importance-userfriendliness * user-friendly-weight * score-multiplier)]
  
  let rand random 100
  ;show rand 
  ;show 58.404 * e ^ (-0.896 * app-cost)
  if (rand > (58.404 * e ^ (-0.896 * app-cost)) )[
    set app-score app-score - (10 * importance-cost) ;; ****SomeFunction using app-cost**** (importance-cost - app-cost) * cost-weight * score-multiplier)
  ]
end 

to show-group-characteristics
  
  let sortedGroups sort-on [who] groups
  
  foreach sortedGroups[
   ask ?1 [show (sentence " utility: " precision group-utility 2 " fun: " precision group-funness 2 " cost: " precision group-cost 2 
       " userFriendly: " precision group-userfriendliness 2 " Influence: " precision group-level-of-influence 2)]
  ]
end
  
to setup-people-with-app
  
  if (start-choice = "one-per-group") [start-one-each-group]
  if (start-choice = "top-influential") [start-most-influence]
  if (start-choice = "least-influential") [start-least-influence]
  if (start-choice = "random-people") [start-random]
  if (start-choice = "highest-app-score") [start-highest-app-score]

end

to start-one-each-group
  let grouparray array:from-list n-values 10 [false]
  
  let countn 0 
  
  ask people [
    foreach [0 1 2 3 4 5 6 7 8 9] [  
      if (member? ?1 grouplist) [
        if (array:item grouparray ?1 = false)[
          array:set grouparray ?1 true
          get-app
          
          set countn (countn + 1)
          
          ]
        ]       
      ]
  ]
end

to start-most-influence
  
  let sortedPeople sort-on [level-of-influence] people
  let mostInfPeople sublist sortedPeople (number-of-people - number-people-start-with-app) (number-of-people)
  foreach mostInfPeople [
  ask ?1 [ get-app ] 
  ]
  
 
end

to start-least-influence
  
  let sortedPeople sort-on [level-of-influence] people
  let leastInfPeople sublist sortedPeople 0 number-people-start-with-app
  foreach leastInfPeople [
    ask ?1 [ get-app ] 
  ]
end 

to start-random  
  ask n-of number-people-start-with-app people [get-app]
end

to start-highest-app-score
  
    let sortedPeople sort-on [app-score] people
  let bestScorePeople sublist sortedPeople (number-of-people - number-people-start-with-app) (number-of-people)
  foreach bestScorePeople [
  ask ?1 [ get-app ] 

  ]

end

to go
  ;; we want to run until steady state
  move-people
  attempt-talk
  tick
end

to move-people

  ask people [
    ifelse (show-groups?)
     [set label grouplist ]
     [set label ""]
    right random 360
    forward 1
  ]
end

;; If a person is on same patch as fellow group member, 
;; try to talk  
to attempt-talk
  
  ask people with [app?] 
  [ set person-talking-influence level-of-influence
    foreach grouplist [
      ask other people-here [
      if (member? ? grouplist) [talk] 
          ]
        ]
  ]
end

;; if other doesn't have app and is a match, pass it on
to talk
  
  set conversations-between-friends conversations-between-friends + 1
  ;; app-score has to be above never get threshold to even talk 
  if (app-score > never-get-threshold) [
  
    ;; An individual’s exposure score increases when he comes in contact with a fellow group member. 
    ;; The increase = “app score”/ 50 * influence score of the other individual. 
    set exposure-to-app (exposure-to-app + app-score / 60 * person-talking-influence)

  let app-sharing-weight .7
  set get-score (app-score + exposure-to-app + app-sharing-capability * app-sharing-weight)

    ;; get-score is sum of app-score + exposure + sharing 
  
    ;; get app if above threshold 
    if (get-score > get-threshold) [get-app]
  ]

end

to get-app
  ;; if they don't already have it 
  if (not app?) [
   set app? true 
   set color orange
   set last-app-get-tick ticks 
     foreach [0 1 2 3 4 5 6 7 8 9] [  
      if (member? ?1 grouplist) [array:set groupsHaveCount ?1 (array:item groupsHaveCount ?1 + 1)]       
        ]
  ]
end 
@#$#@#$#@
GRAPHICS-WINDOW
261
10
700
418
16
14
13.0
1
10
1
1
1
0
1
1
1
-16
16
-14
14
0
0
1
ticks
30.0

BUTTON
3
10
69
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

BUTTON
70
10
133
43
NIL
go\n
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

PLOT
6
321
206
471
Totals Users With app
time
totals
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot count people with [app? = true]"

SLIDER
716
203
964
236
number-people-start-with-app
number-people-start-with-app
0
100
0
1
1
NIL
HORIZONTAL

SLIDER
718
95
1048
128
number-of-people
number-of-people
0
300
300
1
1
NIL
HORIZONTAL

SLIDER
16
71
248
104
app-utility-rating
app-utility-rating
0
10
4.2
.1
1
NIL
HORIZONTAL

SLIDER
17
105
249
138
app-funness-rating
app-funness-rating
0
10
4.2
.1
1
NIL
HORIZONTAL

SLIDER
15
140
249
173
app-user-friendliness-rating
app-user-friendliness-rating
0
10
4.5
.1
1
NIL
HORIZONTAL

SLIDER
15
175
250
208
app-cost
app-cost
0
10
0
.1
1
NIL
HORIZONTAL

SLIDER
15
209
249
242
app-sharing-capability
app-sharing-capability
0
10
4.9
.1
1
NIL
HORIZONTAL

PLOT
715
240
1268
678
Percent group members have app
time 
percent
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"group 0" 1.0 0 -16777216 true "" "plot (array:item groupsHaveCount 0 / array:item groupSizes 0 ) * 100"
"group 1" 1.0 0 -7500403 true "" "plot (array:item groupsHaveCount 1 / array:item groupSizes 1 ) * 100"
"group 2" 1.0 0 -5207188 true "" "plot (array:item groupsHaveCount 2 / array:item groupSizes 2 ) * 100"
"group 3" 1.0 0 -955883 true "" "plot (array:item groupsHaveCount 3 / array:item groupSizes 3 ) * 100"
"group 4" 1.0 0 -12440034 true "" "plot (array:item groupsHaveCount 4 / array:item groupSizes 4 ) * 100"
"group 5" 1.0 0 -1184463 true "" "plot (array:item groupsHaveCount 5 / array:item groupSizes 5 ) * 100"
"group 6" 1.0 0 -7858858 true "" "plot (array:item groupsHaveCount 6 / array:item groupSizes 6 ) * 100"
"group 7" 1.0 0 -13840069 true "" "plot (array:item groupsHaveCount 7 / array:item groupSizes 7) * 100"
"group 8" 1.0 0 -2064490 true "" "plot (array:item groupsHaveCount 8 / array:item groupSizes 8 ) * 100"
"group 9" 1.0 0 -11221820 true "" "plot (array:item groupsHaveCount 9 / array:item groupSizes 9 ) * 100"

SWITCH
718
24
851
57
show-groups?
show-groups?
1
1
-1000

BUTTON
159
16
222
49
NIL
step
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

CHOOSER
716
158
865
203
start-choice
start-choice
"one-per-group" "top-influential" "least-influential" "random-people" "highest-app-score"
0

INPUTBOX
867
28
1022
88
randomseed
308876
1
0
Number

MONITOR
6
274
206
319
Total people with app
count people with [app? = true]
17
1
11

MONITOR
265
448
385
493
NIL
last-app-get-tick
17
1
11

MONITOR
420
452
629
497
NIL
conversations-between-friends
17
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
NetLogo 5.1.0
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
