local Color = class({});

local radiantIndex = 1;
local radiantColors = {
    {70,70,255},
    {0,255,255},
    {255,0,255},
    {255,255,0},
    {255,165,0},
    {0,255,0},
    {255,0,0},
    {75,0,130},
    {109,49,19},
    {255,20,147},
    {128,128,0},
    {255,255,255}
}

local direIndex = 1;
local direColors = {
    {255,135,195},
    {160,180,70},
    {100,220,250},
    {0,128,0},
    {165,105,0},
    {153,50,204},
    {0,128,128},
    {0,0,165},
    {128,0,0},
    {180,255,180},
    {255,127,80},
    {0,0,0}
}

function Color:Initialize()
    ListenToGameEvent( "npc_spawned", Dynamic_Wrap( Color, "OnNPCSpawned" ), Color );
end

-- forces it to happen only once per player
-- needed for hidden Monkey King clones
local Seen = {};

function Color:OnNPCSpawned( event )
    -- event.entindex
    if not IsServer() then
        return nil;
    end

    local hScript = EntIndexToHScript(event.entindex);

    local playerId = hScript:GetPlayerOwnerID();

    -- do not care about non heroes and only do this once
    if not hScript:IsRealHero() or Seen[playerId] then
        return;
    else
        Seen[playerId] = true;
    end

    local teamId = PlayerResource:GetTeam(playerId);

    local color = nil;
    local team = nil;
    if teamId == DOTA_TEAM_GOODGUYS then
        color = radiantColors[radiantIndex];
        PlayerResource:SetCustomPlayerColor(playerId, color[1], color[2], color[3]);
        radiantIndex = radiantIndex + 1;
        team = "Radiant";
    elseif teamId == DOTA_TEAM_BADGUYS then
        color = direColors[direIndex];
        PlayerResource:SetCustomPlayerColor(playerId, color[1], color[2], color[3]);
        direIndex = direIndex + 1;
        team = "Dire";
    else
        PlayerResource:SetCustomPlayerColor(playerId, 0, 0, 0);
    end
    -- trigger javascript

    CustomGameEventManager:Send_ServerToAllClients( "player_color_set", { playerId = playerId, team = team } );
end


return Color;