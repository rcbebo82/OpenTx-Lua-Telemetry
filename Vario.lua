local MAXPOINTS = 92
local index = 0
local altitudes = {}
local launches = {}
local lastTime = 0
local lastTimerValue = 0
local lastMaxAltitude = 0
local time
local altitude
local timer

local vario = "VSpd"
local height = "Alt"
local heightmax = "Alt+"

local function init()
  for i=0,MAXPOINTS-1 do
    altitudes[i] = 0
  end
  for i=0,3 do
    launches[i] = { duration=0, maxHeight=0 }
  end
end

local function background()
  time = getTime()
  altitude = getValue(getTelemetryId(height))
  
  if time > lastTime + 100 then
    lastTime = time
    altitudes[index % MAXPOINTS] = altitude
    index = index+1
  end
  
  timer = model.getTimer(0)
  if timer.value < lastTimerValue then
    launches[3] = launches[2]
    launches[2] = launches[1]
    launches[1] = launches[0]
    launches[0] = { duration=lastTimerValue, maxHeight=lastMaxAltitude }
	lastMaxAltitude = 0
  end
  lastTimerValue = timer.value
  if altitude > lastMaxAltitude then
    lastMaxAltitude = altitude
  end
end

local function run(event)
  background()
  lcd.clear()
  
  print(event)
    
  -- left column / Timer with altitude
  lcd.drawTimer(1, 0, timer.value, MIDSIZE)
  local maxAltitude = getValue(getTelemetryId(heightmax))
  lcd.drawNumber(79, 0, 10*maxAltitude, MIDSIZE+PREC1)
  lcd.drawPixmap(0, 12, "altitude-0.bmp")
  for i=0,3 do
    if launches[i].duration > 0 then
      lcd.drawTimer(10, 29+i*9, launches[i].duration, 0)
      lcd.drawNumber(70, 29+i*9, 10*launches[i].maxHeight, PREC1)
    end
  end
  
  -- middle column / Altitude
  lcd.drawRectangle(80, 0, MAXPOINTS+2, 64)
  for i=1,61,2 do
    lcd.drawPoint(79, i)
    lcd.drawPoint(79+MAXPOINTS+1, i)
  end
  for i=0,MAXPOINTS-1 do
    local timeIdx
    local arrayIdx
    if index < MAXPOINTS then
      timeIdx = i
      arrayIdx = i
    else
      timeIdx = index+i
      arrayIdx = (index+i) % MAXPOINTS
    end
    local altitude = altitudes[arrayIdx]
    if altitude > 0 then
      local y = 63 - (58*altitude) / maxAltitude
      lcd.drawPoint(80+i+1, y)
      lcd.drawLine(80+i+1, y, 80+i+1, 58, SOLID, GREY_DEFAULT)
    end
    local bar = 0
    if timeIdx % 12 == 0 then
      bar = 3
    elseif timeIdx % 2 == 0 then
      bar = 2 
    end
    if bar > 0 and i<MAXPOINTS-1 then
      lcd.drawLine(80+i+1, 62-bar, 80+i+1, 62, SOLID, 0)
    end
  end
  
  -- right column / Vario VSpd
  lcd.drawPixmap(177, 36, "altitude-1.bmp")
  lcd.drawNumber(211, 0, 10*altitude, MIDSIZE+PREC1)
  local vario = getValue(getTelemetryId(vario))
  if vario > 5 then
    lcd.drawFilledRectangle(176, 21, 34, 4, 0)
  else
    lcd.drawRectangle(176, 21, 34, 4)
  end
  if vario > 2 then
    lcd.drawFilledRectangle(187, 26, 23, 4, 0)
  else
    lcd.drawRectangle(187, 26, 23, 4)
  end
  if vario > 0 then
    lcd.drawFilledRectangle(196, 31, 14, 4, 0)
  else
    lcd.drawRectangle(196, 31, 14, 4)
  end
  if vario < 0 then
    lcd.drawFilledRectangle(196, 46, 14, 4, 0)
  else
    lcd.drawRectangle(196, 46, 14, 4)
  end
  if vario < -2 then
    lcd.drawFilledRectangle(187, 51, 23, 4, 0)
  else
    lcd.drawRectangle(187, 51, 23, 4)
  end
  if vario < -5 then
    lcd.drawFilledRectangle(176, 26, 34, 4, 0)
  else
    lcd.drawRectangle(176, 56, 34, 4)
  end
end

function getTelemetryId(name)
  field = getFieldInfo(name)
  if getFieldInfo(name) then return field.id end
  return -1
end

return { init=init, background=background, run=run }