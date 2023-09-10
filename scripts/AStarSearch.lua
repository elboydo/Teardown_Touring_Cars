#include "priorityQueue.lua"
#include "mapNode.lua"


--[[
**********************************************************************
*
* FILEHEADER: Elboydo's Armed Vehicles Framework (AVF) AI V3 - The Racing Edition 
*
* FILENAME :        AStarSearch.lua             
*
* DESCRIPTION :
*       Implements A Star search in Teardown 2020
*
*       
*
*
* NOTES :
*
*       Yes, i know while loops are bad. This can be optimised by 
*       using for loops and making it async       
*
* AUTHOR :    elboydo        START DATE   :    Jan  2021
*                            Release Date :    29 Nov 2021 
*
]]

AStar = {
    maxChecks = 1000,
    cameFrom = {},
    costSoFar = {},
    maxIterations = 10,
    currentIteration = 0,

    heuristicWeight = 1

}





function AStar:Heuristic(a, b)
      return (math.abs(a[1] - b[1]) + math.abs(a[2] - b[2])) * self.heuristicWeight
 end 



function AStar:AStarSearch(graph, start, goal)
    
        frontier =  deepcopy(PriorityQueue)
        frontier:init(#graph,#graph[1])
        frontier:put(deepcopy(start), 0);

        local startIndex = start:getIndex()
        -- DebugPrint(type(start:getIndex()).." | "..type(start:getIndex()[2]))
        -- DebugPrint("Val = " ..startIndex[1]..startIndex[2])
        local cameFrom = {}
        cameFrom[startIndex[2]] = {}
        cameFrom[startIndex[2]][startIndex[1]] = start;
        local lastIndex = nil
        local costSoFar = {}
        costSoFar[startIndex[2]] = {}
        costSoFar[startIndex[2]][startIndex[1]] = start:getCost();

        local current = nil
        local currentIndex = nil
        local nextNode = nil
        local newCost = 0
        local priority = 0
        local currentIndex = nil
        local nodeExists = false

        local totalNodes = 0
        -- DebugPrint(frontier:empty())
        -- for i=1,self.maxChecks do 
        local checks = 0
        for i=1,frontier:size() do 
       --- while not frontier:empty() do
            checks = checks + 1
        
            current = deepcopy(frontier:get()) 

            totalNodes = totalNodes + 1
            if (type(current)~="table" or not current or  current:Equals(goal)) then
                -- DebugPrint("goal found")
                break
            end  
            currentIndex = current:getIndex()
             for key, val in ipairs(current:getNeighbors()) do
                    nextNode =  deepcopy(graph[val.y][val.x])
                
                    newCost = costSoFar[currentIndex[2]][currentIndex[1]] + nextNode:getCost()
                    nodeExists = ( self:nodeExists(costSoFar,val.y,val.x) )
                    if(nextNode.validTerrain and( not nodeExists or (not (cameFrom[currentIndex[2]][currentIndex[1]]:indexEquals({val.y,val.x}))  and 
                                        newCost < costSoFar[val.y][val.x])) )
                    then 
                        if(not nodeExists) then 
                            if(not costSoFar[val.y]) then 
                                costSoFar[val.y] = {}
                                cameFrom[val.y] = {}
                            end
                        end
                        costSoFar[val.y][val.x] = newCost
                        priority =   newCost +  self:Heuristic(nextNode:getIndex(),goal:getIndex())
                        frontier:put(nextNode, priority)
                        cameFrom[val.y][val.x] = deepcopy(current)

                        -- DebugPrint(newCost.." | "..val.y.." | "..val.x.." | ")
                        -- lastIndex = deepcopy(val)
                        
                        -- DebugPrint(nextNode:getIndex()[1].." | "..nextNode:getIndex()[2])
                    --+ graph.Cost(current, next);
                    end
             end
         end
         -- DebugPrint("total checks = "..checks)
         
         local path = self:reconstructPath(graph,cameFrom,current,start,totalNodes)
         -- DebugPrint("total nodes: "..totalNodes)
         return path
 end

 function AStar:nodeExists(listVar,y,x)
     if(listVar[y] and listVar[y][x]) then
        return true
    else
        return false
    end
 end

function AStar:reconstructPath(graph,cameFrom,current,start,totalNodes)
    local path = {}
    local index = current:getIndex()
    -- for i=1,100 do 
    while not current:Equals(start) do
    -- DebugPrint("came from: "..index[1].." | "..index[2])
        path[#path+1] = index
        index = cameFrom[current:getIndex()[2]][current:getIndex()[1]]:getIndex()
        current = deepcopy(graph[index[2]][index[1]])
        
        if(current:Equals(start)) then
                -- DebugPrint("found, nodes: "..totalNodes) 

            break

        end


    end
    local tmp = {}
    for i = #path, 1, -1 do
        tmp[#tmp+1] = path[i]
    end
    path = tmp
    return path


end


 function AStar:drawPath(graph,path)
    local node1,node2 = nil,nil
    for i = 1, #path-1 do
        node1 = graph[path[i][2]][path[i][1]]:getPos()
        node2 = graph[path[i+1][2]][path[i+1][1]]:getPos()
        DebugLine(node1,node2, 1, 0, 0)
    end
 end

 function AStar:drawPath2(graph,path,colours)
    local node1,node2 = nil,nil

    for i = 1, #path-1 do
        node1 = graph[path[i][2]][path[i][1]]:getPos()
        node2 = graph[path[i+1][2]][path[i+1][1]]:getPos()
        DebugLine(node1,node2, 1,0,0)
    end
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
