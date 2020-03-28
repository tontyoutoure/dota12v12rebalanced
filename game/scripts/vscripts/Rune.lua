local Rune = class({});

function Rune:Initialize()
    GameRules:GetGameModeEntity():SetRuneSpawnFilter( Dynamic_Wrap( Rune, "RuneSpawnFilter" ), Rune );
end

function Rune:RuneSpawnFilter( filterTable )
	local r = RandomInt( 0, 5 );
    if r == 5 then
        r = 6;
    end
	filterTable.rune_type = r;
	return true;
end

return Rune;