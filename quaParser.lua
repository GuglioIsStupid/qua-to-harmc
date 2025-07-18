function quaParse(file, harmcPath, harmcName
)
    local qua = Tinyyaml.parse(love.filesystem.read(file))
    local metaData = {}
    local timingPoints = {}
    local hitObjects = {}
    local sliderVelocities = {}
    metaData = {
        title = qua.Title,
        audioFile = qua.AudioFile,
        artist = qua.Artist,
        source = "s" .. qua.Source,
        tags = qua.Tags,
        difficultyName = qua.DifficultyName,
        creator = qua.Creator,
        backgroundFile = qua.BackgroundFile,
        bannerFile = qua.BannerFile,
        songPreviewTime = qua.SongPreviewTime,
        gameMode = "mania",
        chartOrigin = "Quaver",
        laneCount = qua.Mode:gsub("Keys", ""),
        initialSV = qua.InitialScrollVelocity or 1,
    }
    for i = 1,#qua.TimingPoints do
        local timingPoint = qua.TimingPoints[i]
        local startTime = timingPoint.StartTime
        if not startTime then goto continue end
        local bpm = (timingPoint.Bpm or 0)
        table.insert(timingPoints, {startTime = startTime, bpm = bpm})
        if i == 1 then 
            metaData.bpm = bpm
        end
        ::continue::
    end
    for i = 1,#qua.HitObjects do
        local hitObject = qua.HitObjects[i]
        local startTime = hitObject.StartTime
        if not startTime then goto continue end
        local endTime = hitObject.EndTime or 0
        local lane = hitObject.Lane
        table.insert(hitObjects, {"note", startTime = startTime, endTime = endTime, lane = lane})
        ::continue::
    end
    for i = 1, #qua.SliderVelocities do
        local sliderVelocity = qua.SliderVelocities[i]
        local startTime = sliderVelocity.StartTime
        local multiplier = sliderVelocity.Multiplier
        if not startTime or not multiplier then goto continue end
        table.insert(sliderVelocities, {startTime = startTime, multiplier = multiplier})
        ::continue::
    end
    makeHarmc(metaData, timingPoints, hitObjects, sliderVelocities, harmcPath, harmcName)
end



function makeHarmc(metaData, timingPoints, hitObjects, sliderVelocities, harmcPath, harmcName)
    local string = "[meta]\n"
    for i, Data in pairs(metaData) do
        string = string .. i .. ":" .. Data .. "\n"
    end
    string = string .. "[bpm]\n"
    for i, TimingPoint in ipairs(timingPoints) do
        string = string .. "bpm:" .. TimingPoint.startTime .. ":" .. TimingPoint.bpm .. "\n"
    end
    string = string .. "[sliderVelocities]\n"
    for i , SliderVelocity in ipairs(sliderVelocities) do
        string = string .. "sliderVelocity:" .. SliderVelocity.startTime .. ":" .. SliderVelocity.multiplier .. "\n"
    end
    string = string .. "[hitObjects]\n"
    for i, HitObject in ipairs(hitObjects) do
        string = string .. "note:" .. HitObject.startTime .. ":" .. HitObject.endTime .. "" .. ":" .. HitObject.lane .. "\n"
    end
    saveToFile(harmcPath .. "/" .. harmcName .. ".harmc", string)
end

function saveToFile(filename, content)
    local success, message = love.filesystem.write(filename, content)
    if success then 
        print ('file created')
    else 
        print ('file not created: '.. message)
    end
end