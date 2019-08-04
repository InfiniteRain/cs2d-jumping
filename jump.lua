isjumping = {}
count = {}
mode = {}
imageid = {}
aimageid = {}
armor = {}

addhook('join', 'join_hook')
function join_hook(id)
	armor[id] = 0
	isjumping[id] = false
	count[id] = 0
	mode[id] = 0
end

addhook('walkover', 'walkover_hook')
function walkover_hook(id, iid, type, ain, a, mode)
	if isjumping[id] then return 1 end
end

addhook('always', 'always_hook')
function always_hook()
	for id = 1, 32 do
		if not player(id, 'exists') then return end
		if isjumping[id] == true then
			if tile(math.floor((player(id, 'x') + math.sin(math.rad(player(id, 'rot'))) * 3) / 32), math.floor(player(id, 'y') / 32), 'walkable') then
				parse('setpos '.. id ..' '.. math.floor(player(id, 'x') + math.sin(math.rad(player(id, 'rot'))) * 3) ..' '.. player(id, 'y'))
			end
			if tile(math.floor(player(id, 'x') / 32), math.floor((player(id, 'y') + -math.cos(math.rad(player(id, 'rot'))) * 3) / 32), 'walkable') then
				parse('setpos '.. id ..' '.. player(id, 'x') ..' '.. math.floor(player(id, 'y') + -math.cos(math.rad(player(id, 'rot'))) * 3))
			end
		end
	end
end

addhook('ms100', 'ms100_hook')
function ms100_hook()
	for id = 1, 32 do
		if not player(id, 'exists') then return end
		if isjumping[id] == true then
			if mode[id] == 0 then
				count[id] = count[id] + 1
			elseif mode[id] == 1 then
				count[id] = count[id] - 1
			end
			if count[id] > 5 then
				count[id] = 5
				mode[id] = 1
			end
			imagescale(imageid[id], 1 + count[id] / 10, 1 + count[id] / 10)
			if aimageid[id] then
				imagescale(aimageid[id], 1 + count[id] / 10, 1 + count[id] / 10)
			end
		end
	end
end

addhook('attack2', 'attack_hook')
function attack_hook(id)
	if isjumping[id] == false then
		armor[id] = player(id, 'armor')
		parse('setarmor '.. id ..' 0')
		isjumping[id] = true
		parse('speedmod '.. id ..' -100')
		parse('equip '.. id ..' 84')
		timer(1100, "endjump", id)
		local t
		if player(id, 'team') == 1 then t = "T" else t = "CT" end
		t = t .. player(id, 'look') + 1
		imageid[id] = image('gfx/F699/'.. t ..'.png', 1, 0, 200 + id)
		if armor[id] == 206 then
			imagealpha(imageid[id], 0.2)
		end
		if armor[id] > 200 and armor[id] < 206 then
			aimageid[id] = image('gfx/F699/'.. armor[id] ..'.png', 1, 0, 200 + id)
		end
	end
end

addhook('movetile', 'movetile_hook')
function movetile_hook(id, x, y)
	x, y = player(id, 'tilex'), player(id, 'tiley')
	if (entity(x, y, 'typename') == "Trigger_Move" and entity(x, y, 'name') == "death" and isjumping[id] == false) or (tile(x, y, "frame") == 0 and isjumping[id] == false) then
		parse('killplayer '.. id)
	end
end
		
function endjump(id)
	id = tonumber(id)
	isjumping[id] = false
	parse('setarmor '.. id ..' 0')
	if armor[id] > 200 then
		if armor[id] == 201 then
			parse('setarmor '.. id ..' 0')
			parse('equip '.. id ..' 79')
		elseif armor[id] == 202 then
			parse('setarmor '.. id ..' 0')
			parse('equip '.. id ..' 80')
		elseif armor[id] == 203 then
			parse('setarmor '.. id ..' 0')
			parse('equip '.. id ..' 81')
		elseif armor[id] == 204 then
			parse('setarmor '.. id ..' 0')
			parse('equip '.. id ..' 82')
		elseif armor[id] == 205 then
			parse('setarmor '.. id ..' 0')
			parse('equip '.. id ..' 83')
		elseif armor[id] == 206 then
			parse('setarmor '.. id ..' 0')
			parse('equip '.. id ..' 84')
		end
	else
		parse('setarmor '.. id ..' '.. armor[id])
	end
	mode[id] = 0
	parse('speedmod '.. id ..' 0')
	count[id] = 0
	freeimage(imageid[id])
	if aimageid[id] then
		freeimage(aimageid[id])
	end
	local x, y = player(id, 'tilex'), player(id, 'tiley')
	if (entity(x, y, 'typename') == "Trigger_Move" and entity(x, y, 'name') == "death") or (tile(x, y, "frame") == 0) then
		parse('killplayer '.. id)
	end
end

addhook('die', 'die_hook')
function die_hook(id)
	return 1
end