#include "mapNode.lua"
#include "AStarSearch.lua"


--[[
**********************************************************************
*
* FILEHEADER: Elboydo's Armed Vehicles Framework (AVF) AI V3 - The Racing Edition 
*
* FILENAME :        mapBuilder.lua             
*
* DESCRIPTION :
*   File that constructs the map based on scanning positions for materials
*   Buidls a 2d array representing a weighted graph of every map location
*   

*
* NOTES :
*       
*
* AUTHOR :    elboydo        START DATE   :    Jan  2021
*                Release Date :    29 Nov 2021 
*
]]


RACESTARTED = false
map = {
  xIndex = 0,
  data = {

  },

  validSurfaceColours ={ 
      [1] = {
        r = 0.20,
        g = 0.20,
        b = 0.20,
        range = 0.01
      },
    },
}

-- negative grid pos is solved by simply showing 
mapSize = {
			x=400,
			y=400,
			grid = 5,
      gridHeight = 1,
      gridResolution = 0.5,
      gridThres      = 0.2,

      scanHeight = 100,

      scanLength = 200,

      weights = {
          goodTerrain = 0.1,
          badTerrain   = 10,
          avoidTerrain = 25,
          impassableTerrain = 50,
      }
		}
    path = nil

function init()
  local pos = Vec(0,0,0)
  local gridCost = 0
  local maxVal  = {math.modf((mapSize.x)/mapSize.grid),math.modf((mapSize.y)/mapSize.grid)}
	for y= -mapSize.y/2,mapSize.y/2,mapSize.grid do
    pos = posToInt(Vec(0,0,y))
    map.data[pos[3]] = {}
    for x= -mapSize.x,mapSize.x/2,mapSize.grid do
        pos = posToInt(Vec(x,0,y))
        gridCost,validTerrain,avgHeight =  scanGrid(x,y) 
        -- if(pos[3] ~= nil and pos[1]~= nil) then
          
          map.data[pos[3]][pos[1]] = deepcopy(mapNode) 
          map.data[pos[3]][pos[1]]:push(x,avgHeight,y,gridCost,pos[3],pos[1],validTerrain,maxVal )

        -- end
  		  -- DebugPrint(x.." | "..y)
    end
	end
	

  pos = posToInt(GetPlayerPos())
   goalPos = map.data[60][30]
   startPos = map.data[55][72]
  startPos = map.data[pos[3]][pos[1]]



  paths = {}
  gateState = {}
  gates = {}
  triggers = FindTriggers("gate",true)
  for i=1,#triggers do
    gateState[tonumber(GetTagValue(triggers[i], "gate"))] = 0
    gates[tonumber(GetTagValue(triggers[i], "gate"))] = triggers[i]
  end

  for i =1,#triggers do 
    startPos = posToInt(GetTriggerTransform(gates[i]).pos)
    startPos = map.data[startPos[3]][startPos[1]]
    if(i==#triggers) then 
      goalPos = posToInt(GetTriggerTransform(gates[1]).pos )
    else
      goalPos = posToInt(GetTriggerTransform(gates[i+1]).pos )
    end
    goalPos = map.data[goalPos[3]][goalPos[1]]
    paths[#paths+1] =  AStar:AStarSearch(map.data, startPos, goalPos)
  end

  --- AStar:AStarSearch(graph, start, goal)

 
  -- local cameFromIndex = cameFrom[current:getIndex()[2]][current:getIndex()[1]]:getIndex()
end


function scanMap( ... )
	-- body
end

function scanGrid(x,y)
  local pos = Vec(0,0,0)
  local gridScore = 1
  local spotScore = 0 
  local hitHeight = mapSize.scanHeight
  local heightOrigin = 1000000
  local minHeight = heightOrigin
  local maxHeight = -heightOrigin
  local validTerrain  = true
  for y1= y, y+mapSize.grid, mapSize.gridResolution do
    for x1= x, x+mapSize.grid, mapSize.gridResolution do
      spotScore,hitHeight,hit =  getMaterialScore3(x,y)
      if(hitHeight == mapSize.scanHeight or IsPointInWater(Vec(x,hitHeight,y))or not hit) then
        minHeight = -mapSize.scanLength
        maxHeight = mapSize.scanLength
        validTerrain = false
      elseif(minHeight == heightOrigin or maxHeight == heightOrigin) then
        minHeight = hitHeight
        maxHeight = hitHeight
      elseif(hitHeight < minHeight) then
        minHeight = hitHeight
      elseif(hitHeight > maxHeight) then
        maxHeight = hitHeight
      end

      -- local hit,height,hitPos, shape = getHeight(x,y)
      -- spotScore =  getMaterialScore2(hit,hitPos,shape)
      gridScore = gridScore + spotScore

    end
  end
  --DebugPrint("max: "..maxHeight.." min: "..minHeight.." sum: "..(((maxHeight - minHeight) / (mapSize.gridHeight*mapSize.gridThres)))  )  
  if(((maxHeight - minHeight) /  (mapSize.gridHeight*mapSize.gridThres))>1) then
    validTerrain = false
  end  
  if(((maxHeight) - (minHeight)) ~=0 ) then
    gridScore = gridScore * (1+math.log(((maxHeight) - (minHeight)))*2)
  end
  return gridScore,validTerrain, minHeight
end


function tick(dt)
  if InputPressed("r") and not RACESTARTED  then
    RACESTARTED = true
     path =  AStar:AStarSearch(map.data, startPos, goalPos)
  elseif(RACESTARTED and path)then 
    -- AStar:drawPath(map.data,path)
    DebugWatch("running",#paths)
    for key,val in ipairs(paths) do  
       AStar:drawPath2(map.data,val)
    end
  end
  local playerTrans = GetPlayerTransform()
  playerTrans.pos,pos2 = posToInt(playerTrans.pos)
  -- DebugWatch("Player Pos: ",playerTrans.pos)
  --  DebugWatch("original Player Pos: ", GetPlayerTransform().pos)
   -- DebugWatch("Pos 2: ",pos2) 
   local pos = VecCopy(playerTrans.pos)
   if(pos[3] ~= nil and pos[1]~= nil) then
    -- DebugPrint(pos[3].." | "..pos[1])
     -- DebugWatch("player Grid Cost: ",map.data[pos[3]][pos[1]]:getCost())

     -- DebugWatch("player Grid neighbors: ",#map.data[pos[3]][pos[1]].neighbors)

     local totalCost = 0
     for key, val in ipairs(map.data[pos[3]][pos[1]]:getNeighbors()) do
          totalCost = totalCost + map.data[val.y][val.x]:getCost()
     end

     -- DebugWatch("player Grid neighbor: ",totalCost)

     -- DebugWatch("player Grid VALID: ",map.data[pos[3]][pos[1]].validTerrain)
  else

  end

  
end

function getHeight(x,y)

  local probe = Vec(x,mapSize.scanHeight,y)
  local hit, dist,normal,shape = QueryRaycast(probe, Vec(0,-1,0), mapSize.scanLength)
  local hitHeight = 0
  if hit then
    hitHeight = mapSize.scanHeight - dist
  end 
  return hit,hitHeight,VecAdd(probe, VecScale(Vec(0,-1,0), dist)),shape

end

function getMaterialScore(x,z,y)
  local score = 0
  local probe = Vec(x,z+(mapSize.gridHeight/2),y)
  QueryRequire("physical static")
  local hit, dist,norm,shape = QueryRaycast(probe, Vec(0,-1,0), mapSize.gridHeight)
  if hit then
    local hitPoint = VecAdd(probe, VecScale(Vec(0,-1,0), dist))
    local mat,r,g,b  = GetShapeMaterialAtPosition(shape, hitPoint)
    if(mat =="masonry") then
      for colKey, validSurfaceColours in ipairs(map.validSurfaceColours) do 
        
        local validRange = validSurfaceColours.range
        if(inRange(validSurfaceColours.r-validRange,validSurfaceColours.r+validRange,r)
         and inRange(validSurfaceColours.g-validRange,validSurfaceColours.g+validRange,g) 
         and inRange(validSurfaceColours.b-validRange,validSurfaceColours.b+validRange,b))
          then 
            score = 0.1
        end
      end
    else

      score = 1
    end    
  else
    score = 10
  end

  return score

end

function getMaterialScore2(hit,hitPoint,shape)
  local score = 0
  if hit then
    local mat,r,g,b  = GetShapeMaterialAtPosition(shape, hitPoint)
    if(mat =="masonry") then
      for colKey, validSurfaceColours in ipairs(map.validSurfaceColours) do 
        
        local validRange = validSurfaceColours.range
        if(inRange(validSurfaceColours.r-validRange,validSurfaceColours.r+validRange,r)
         and inRange(validSurfaceColours.g-validRange,validSurfaceColours.g+validRange,g) 
         and inRange(validSurfaceColours.b-validRange,validSurfaceColours.b+validRange,b))
          then 
            score = 0.1
        end
      end
    else

      score = 1
    end    
  else
    score = 10
  end

  return score

end


function getMaterialScore3(x,y)
  local score = 0
  local probe = Vec(x,mapSize.scanHeight,y)
  local hit, dist,normal,shape = QueryRaycast(probe, Vec(0,-1,0), mapSize.scanLength)
  if hit then
    local hitPoint = VecAdd(probe, VecScale(Vec(0,-1,0), dist))
    local mat,r,g,b  = GetShapeMaterialAtPosition(shape, hitPoint)
    if(mat =="masonry") then
      for colKey, validSurfaceColours in ipairs(map.validSurfaceColours) do 
        
        local validRange = validSurfaceColours.range
        if(inRange(validSurfaceColours.r-validRange,validSurfaceColours.r+validRange,r)
         and inRange(validSurfaceColours.g-validRange,validSurfaceColours.g+validRange,g) 
         and inRange(validSurfaceColours.b-validRange,validSurfaceColours.b+validRange,b))
          then 
            score = mapSize.weights.goodTerrain
        end
      end
      if(score ~= mapSize.weights.goodTerrain ) then 
        score = mapSize.weights.badTerrain
      end
    else

      score = mapSize.weights.badTerrain
    end    
  else
    score = mapSize.weights.impassableTerrain
  end
  local hitHeight = mapSize.scanHeight - dist

  return score,hitHeight,hit

end

function posToInt(pos)
  local pos2 = VecCopy(pos)
  for i=1,3 do 
    pos[i] = math.modf((pos[i]+200)/mapSize.grid)
    --math.floor(pos[i]))
    pos2[i] = (pos[i]*mapSize.grid)
    if(i == 1 or i == 3 ) then
      pos2[i] = pos2[i] + (mapSize.grid/2)
    end
    pos2[i] = pos2[i] -200
  end
  return pos,pos2
end

function posToIndex(pos)
  local pos2 = VeC(0,0,0)
  for i=1,3 do 
    pos[i] = math.modf((pos[i]+200)/mapSize.grid)
    --math.floor(pos[i]))
    pos2[i] = (pos[i]*mapSize.grid)
    if(i == 1 or i == 3 ) then
      pos2[i] = pos2[i] + (mapSize.grid/2)
    end
    pos2[i] = pos2[i] -200
  end
  return pos,pos2
end


function Heuristic(a, b)
      return Math.Abs(a[1] - b[1]) + Math.Abs(a[3] - b[3]);
 end 

function deepcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[deepcopy(orig_key)] = deepcopy(orig_value)
        end
        setmetatable(copy, deepcopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end



function inRange(min,max,value)
    if(min < value and value<=max) then 
      return true

    else
      return false
    end

end