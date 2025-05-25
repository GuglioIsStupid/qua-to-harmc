--[[
Hello!! to use this, just put EXTRACTED quaver songs in the quaver folder (easiest way to get them like this is to just click open folder instead of export in Quaver), then run this program
it will make a folder called harmc in the love2d save directory, and fill it with the converted quaver songs
you dont gotta worry about opening the save folder, it will do that for you when it finished converting the songs
--]]

local queue = {}
local currentSongIndex = 1
local currentFileIndex = 1
local totalFiles = 0
local processedFiles = 0
local processingDone = false

function love.load()
    love.filesystem.createDirectory("harmc")
    require("quaParser")
    Tinyyaml = require("Tinyyaml")

    queue = love.filesystem.getDirectoryItems("quaver")
    
    -- count the total number of files (used for progress  bar)
    for i = 1, #queue do
        local filesInDirectory = love.filesystem.getDirectoryItems("quaver/" .. queue[i])
        totalFiles = totalFiles + #filesInDirectory
    end
end

function love.update(dt)
    if processingDone then
        return
    end
    if currentSongIndex > #queue then
        processingDone = true
        openSaveFolder()
        love.event.quit()
        return
    end
    local currentSong = queue[currentSongIndex]
    local filesInDirectory = love.filesystem.getDirectoryItems("quaver/" .. currentSong)

    if currentFileIndex > #filesInDirectory then
        currentSongIndex = currentSongIndex + 1
        currentFileIndex = 1
        return
    end

    local fileName = filesInDirectory[currentFileIndex]
    love.filesystem.createDirectory("harmc/" .. currentSong)
    print("Current File to process: " .. currentSong .. "/" .. fileName)

    local ext = get_file_extension(fileName)
    if ext == "qua" then  -- we need to convert this to harmc
        quaParse("quaver/" .. currentSong .. "/" .. fileName, "harmc/" .. currentSong, fileName)
    else -- it must be an image or audio file, we will just copy it 
        print("Copying file: " .. currentSong .. "/" .. fileName)
        copyFile("quaver/" .. currentSong .. "/" .. fileName, "harmc/" .. currentSong .. "/" .. fileName)
    end

    processedFiles = processedFiles + 1
    currentFileIndex = currentFileIndex + 1
end

function love.draw()
    local barWidth = 400
    local barHeight = 30
    local x = (love.graphics.getWidth() - barWidth) / 2
    local y = (love.graphics.getHeight() - barHeight) / 2
    love.graphics.setColor(0.3, 0.3, 0.3)
    love.graphics.rectangle("fill", x, y, barWidth, barHeight)
    local progress = processedFiles / totalFiles
    love.graphics.setColor(0.2, 0.7, 0.2)
    love.graphics.rectangle("fill", x, y, barWidth * progress, barHeight)
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf(string.format("Processing: %d/%d files (%.1f%%)", processedFiles, totalFiles, progress * 100), x, y + 5, barWidth, "center")
end

function get_file_extension(filename)
  return filename:match("%.([^%.]+)$")
end

function copyFile(sourcePath, destPath)  -- thanks gpt for this function lmao
    local sourceFile = io.open(sourcePath, "rb")
    if not sourceFile then
        return false, "Failed to open source file: " .. sourcePath
    end
    local data = sourceFile:read("*a")
    sourceFile:close()
    local dir = destPath:match("(.*/)")
    if dir then
        love.filesystem.createDirectory(dir)
    end
    local success, err = love.filesystem.write(destPath, data)
    if not success then
        return false, "Failed to write to destination file: " .. err
    else
        print("File copied: " .. destPath)
    end
    return true
end

function openSaveFolder()
    local path = love.filesystem.getSaveDirectory()
    local success, errMsg

    if love.system.getOS() == "Windows" then
        success, errMsg = os.execute('start "" "' .. path .. '"')
    elseif love.system.getOS() == "OS X" then
        success, errMsg = os.execute('open "' .. path .. '"')
    else
        success, errMsg = os.execute('xdg-open "' .. path .. '"')
    end

    if not success then
        print("Failed to open folder: " .. (errMsg or "Unknown error"))
    end
end