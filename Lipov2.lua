-- written by Benjamin Boy (rcbebo82@googlemail.com) on 30.03.2016
-- Version 3
--
-- This scripts shows up to 12S Lipo cells or if only one lipo sensor is attachted some optional stuff like RSSI, RPM and temperature.

-- If you use one lipo sensor cells are displayed on the left side, rpm on the right side. Check the variables mainrotorgear and tailrotorgear to fit it for your use. 
-- Temperature is only displayed in the middle if a tmp sensor is present. If you use a Taranis X9D plus you get the rssi on the right side of the display. 
-- I use this script now for my T-Rex 600 Nitro Pro which only has 2 lipo cells connected.

-- For 12 S you need two FLVS Sensors. Note that you must change the id of one sensor with a SBUS Servo channel changer. Define the names like you want in the telemetry screen 
-- and correct the variables liposensor1, liposensor2.

-- In the middle you see the voltage of all cells together and the receiver voltage below.
-- On the lowest middle position you see the lowest lipo voltage cell of each sensor
-- the right one is liposensor2 and the left one liposensor1.


-- define your gauge scala here
local celminv = 3.46
local celmaxv = 4.26

-- define your heli gearing here
-- Define GVARS in any flight mode u use
local m1 = model.getGlobalVariable(0, 0) -- GVAR1 (Example: 8)
local m2 = model.getGlobalVariable(1, 0) -- GVAR2 (Example: 5)
local t1 = model.getGlobalVariable(2, 0) -- GVAR3 (Example: 4)
local t2 = model.getGlobalVariable(3, 0) -- GVAR4 (Example: 5)
local mainrotorgear = string.format("%d.%d", m1, m2) -- Ends in 8.5
local tailrotorgear = string.format("%d.%d", t1, t2) -- Ends in 4.5

-- waiting for OpenTX 2.2.X to implement this with two global variables, currently only full numbers are supported so normally it
-- would not be possible to use comma seperated gearing like 8.5
-- mainrotorgear = model.getGlobalVariable(0, 0) -- GV1 mainrotor
-- tailrotorgear = model.getGlobalVariable(1, 0) -- GV2 tailrotor

-- define the names of your sensors here
local liposensor1 = "Cels"
local liposensor2 = "Cel1"
local receiverVoltage = "RxBt"

-- Optional stuff to display only if lipo sensor 2 is not used
-- in this case set liposensor2=""
local rssi = "RSSI"
local rpm = "RPM"
local tmp1 = "Tmp1"

-- Do not edit anything under this line if you dont know what to do here
local function init()

end

local function background()
  -- GetData from Lipo Sensor 1 - Cells 1-6
  FLV1 = getTelemetryId(liposensor1)
  -- GetData from Lipo Sensor 2 - Cells 7-12
  FLV2 = getTelemetryId(liposensor2)
  -- GetData from RxBt
  RxBt = getTelemetryId(receiverVoltage)
  --print(getValue(RxBt))
  -- GetData from optional sensors only if Liposensor2 is not present
  if getValue(FLV2) == 0 then
    -- Only get RSSI Data when not using a X9E
    local ver, radio, maj, minor, rev = getVersion()
   if radio ~= "taranisx9e-simu" or radio ~= "taranisx9e" then
      -- GetData from RSSI
      RSSI = getValue(getTelemetryId(rssi))
   end
    -- GetData from RPM
    RPM = getValue(getTelemetryId(rpm))
    -- GetData from TEMP
    TEMP = getValue(getTelemetryId(tmp1))
  else
    RSSI = nil
    RPM = nil
    TEMP = nil
  end

end

local function run(event)
  background() 
  lcd.clear()
   
  -- Lipo Cells  1-6
  cellResult1 = getValue(FLV1)
  local x = 4 --Start drawing on x
  FLV1voltage = 0
  if (type(cellResult1) == "table") then
    for i, v in ipairs(cellResult1) do
      lcd.drawText(2,x,'C' .. i, SMLSIZE)
      lcd.drawText(37, x, "v", SMLSIZE)
      lcd.drawNumber(17, x, v * 100, SMLSIZE + PREC2 + LEFT)
      lcd.drawGauge(45, x, 26, 6, setGaugeFill(v), 100)
      x = x + 10
      FLV1voltage = FLV1voltage + v
    end
    -- draw static parts to the lcd
    lcd.drawLine(14, 1, 14,62, SOLID, GREY_DEFAULT)
  else
    lcd.drawText(2,2, "Telemetry from\30sensor " .. liposensor1 .. "\30not available.", SMLSIZE)
  end
  
  -- Lipo Cells  7-12
  cellResult2 = getValue(FLV2)
  local x = 4 --Start drawing on x
  FLV2voltage = 0
  if (type(cellResult2) == "table") then
    for i, v in ipairs(cellResult2) do
      lcd.drawText(137,x,'C' .. i+6, SMLSIZE)
      lcd.drawText(176, x, "v", SMLSIZE)
      lcd.drawNumber(156, x, v * 100, SMLSIZE + PREC2 + LEFT)
      lcd.drawGauge(184, x, 26, 6, setGaugeFill(v), 100)
      x = x + 10
      FLV2voltage = FLV2voltage + v
    end
    lcd.drawLine(153, 1, 153,62, SOLID, GREY_DEFAULT)
  end  

-- Calculate sum of cell voltage and show lowest cell frome each sensor, draw receiver voltage
  if FLV1voltage > 0 or FLV2voltage > 0 then
    lcd.drawNumber(84,2, (FLV1voltage + FLV2voltage)*100, DBLSIZE + PREC2 + LEFT)

    local i, v = getlowestvaluefromTable(cellResult1)
    if v > 0 then
      lcd.drawText(77,42, "Cell " .. i, SMLSIZE)
      lcd.drawNumber(81,50, v*100 , MIDSIZE + PREC2 + LEFT)
    end

    local i, v = getlowestvaluefromTable(cellResult2)
    if v > 0 then
      lcd.drawText(107,42, "Cell " .. i, SMLSIZE)
      lcd.drawNumber(111,50, v*100 , MIDSIZE + PREC2 + LEFT)
    end

  end

  if RxBt > 0 then
    lcd.drawNumber(94,22, getValue(RxBt)*100, DBLSIZE + PREC2 + LEFT)
    lcd.drawLine(74, 1, 74,62, SOLID, GREY_DEFAULT)
    lcd.drawLine(75, 20, 133,20, SOLID, GREY_DEFAULT)
    lcd.drawLine(75, 39, 133,39, SOLID, GREY_DEFAULT)
    lcd.drawLine(104, 40, 104,62, SOLID, GREY_DEFAULT)
    lcd.drawLine(134, 1, 134,62, SOLID, GREY_DEFAULT)
  end

-- ####################################
-- ##### Display optional stuff   #####
-- ####################################

-- ##### Optional RSSI ##### --
  if RSSI then
    lcd.drawLine(200, 0, 200, 63, DOTTED, 0) 
    if RSSI >= 0 then
      lcd.drawText(205,18, "R\30S\30S\30I",SMLSIZE)
      percent = round(((math.log(RSSI-28, 10)-1)/(math.log(72, 10)-1))*100)
      if percent > 90 then
        lcd.drawFilledRectangle(202, 0, 9, 64, GREY_DEFAULT)    
      elseif percent > 80 then
        lcd.drawFilledRectangle(202, 6, 9, 58, GREY_DEFAULT)
      elseif percent > 70 then
        lcd.drawFilledRectangle(202, 12, 9, 52, GREY_DEFAULT)
      elseif percent > 60 then
        lcd.drawFilledRectangle(202, 18, 9, 46, GREY_DEFAULT)
      elseif percent > 50 then
        lcd.drawFilledRectangle(202, 24, 9, 40, GREY_DEFAULT)
      elseif percent > 40 then
        lcd.drawFilledRectangle(202, 30, 9, 34, GREY_DEFAULT)
      elseif percent > 30 then
        lcd.drawFilledRectangle(202, 36, 9, 28, GREY_DEFAULT)
      elseif percent > 20 then
        lcd.drawFilledRectangle(202, 42, 9, 22, GREY_DEFAULT)
      elseif percent > 10 then
        lcd.drawFilledRectangle(202, 48, 9, 16, GREY_DEFAULT)
      elseif percent > 0 then
        lcd.drawFilledRectangle(202, 54, 9, 10, GREY_DEFAULT)
      else
        lcd.drawFilledRectangle(202, 60, 9, 4, GREY_DEFAULT)
      end
    end
  end

  -- ##### Optional RPM ##### --
  if RPM then
    if RPM > 0 then
		-- OpenTX 2.2.x needed here
		--if mainrotorgear == nil then
		--	lcd.drawText(140,40, "GVAR1 empty!",SMLSIZE)
		--	lcd.drawText(155,20, "Motor",SMLSIZE)
		--	lcd.drawNumber(191,2, round(RPM,0), DBLSIZE)
		--else			
			lcd.drawText(145,20, "Mainrotor",SMLSIZE)
			lcd.drawNumber(186,2, round(RPM / mainrotorgear,0), DBLSIZE)
		--end
		--if tailrotorgear == nil then
		--	lcd.drawText(140,50, "GVAR2 empty!",SMLSIZE)
		--else
			lcd.drawText(145,50, "Tailrotor",SMLSIZE)
			lcd.drawNumber(186,32, round(RPM / mainrotorgear * tailrotorgear,0), DBLSIZE)
		--end
    end
  end

  -- ##### Optional Temp ##### --
  if TEMP then
    if TEMP > 0 then
      lcd.drawText(107,42, "Temp1", SMLSIZE)
      lcd.drawNumber(130,50, round(TEMP,0), MIDSIZE)
    end
  end
-- function run end
end

function getlowestvaluefromTable(table)
  if (type(table) == "table") then
    local key, min = 1, table[1]
    for k, v in ipairs(table) do
      if table[k] < min then
        key, min = k, v
      end
    end
    return key, min
  else
    return 0, 0
  end
end

function getTelemetryId(name)
  field = getFieldInfo(name)
  if getFieldInfo(name) then return field.id end
  return -1
end

function round(num, idp)
  local mult = 10^(idp or 0)
  return math.floor(num * mult + 0.5) / mult
end

function setGaugeFill(cel)
  -- to get a good scale at the drawn gauge we have to do this 
  -- by example we want to have the gauge displaying 0 percent if the voltage drops below celminv
  -- the complete scala goes from celminv = 0% to celmaxv = 100%
  local percent = round(100 * (cel-celminv) / (celmaxv-celminv), 0)  
  if percent <= 0 then
    percent = 0
  elseif percent >= 100 then
    percent = 100
  else
    percent = percent
  end  
  return percent
end

return { init=init, background=background, run=run }

