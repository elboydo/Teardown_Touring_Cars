file = GetString("file", "testground.png", "script png")
heightScale = GetInt("scale", 64)
tileSize = GetInt("tilesize", 128)
hollow = GetInt("hollow", 0)

function init()
	matRock = CreateMaterial("rock", 0.3, 0.3, 0.3)
	matDirt = CreateMaterial("dirt", 0.26, 0.23, 0.20, 1, 0, 0.1)
	matGrass1 = CreateMaterial("unphysical", 0.17, 0.21, 0.15, 1, 0, 0.2)
	matGrass2 = CreateMaterial("unphysical", 0.19, 0.24, 0.17, 1, 0, 0.2)
	matTarmac = CreateMaterial("masonry", 0.35, 0.35, 0.35, 1, 0, 0.4)
	matTarmacTrack = CreateMaterial("masonry", 0.2, 0.2, 0.2, 1, 0, 0.3)
	matTarmacLine = CreateMaterial("dirt", 0.66, 0.57, 0.42, 1, 0, 0.1)
	
	LoadImage(file)
	
	w,h = GetImageSize()

	local maxSize = tileSize
	
	local y0 = 0
	while y0 < h-1 do
		local y1 = y0 + maxSize
		if y1 > h-1 then y1 = h-1 end

		local x0 = 0
		while x0 < w-1 do
			local x1 = x0 + maxSize
			if x1 > w-1 then x1 = w-1 end
			Vox(x0, 0, y0)
			Heightmap(x0, y0, x1, y1, heightScale, hollow==0)
			x0 = x1
		end
		y0 = y1
	end
end

