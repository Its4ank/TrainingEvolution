local FormatModule = {}

-- 10^(index * 3), начиная с 10^3
local BASE_SUFFIXES = {
  "K", -- Thousand
  "M", -- Million
  "B", -- Billion
  "T", -- Trillion
  "Qa", -- Quadrillion
  "Qi", -- Quintillion
  "Sx", -- Sextillion
  "Sp", -- Septillion
  "Oc", -- Octillion
  "No", -- Nonillion
}

-- части для автоматического создания всех следующих сокращений
local ONES_PREFIXES = {
  [0] = "",
  [1] = "U",
  [2] = "D",
  [3] = "T",
  [4] = "Qa",
  [5] = "Qi",
  [6] = "Sx",
  [7] = "Sp",
  [8] = "Oc",
  [9] = "No",
}

local TENS_SUFFIXES = {
  [0] = "",
  [1] = "Dc",
  [2] = "Vg",
  [3] = "Tg",
  [4] = "Qag",
  [5] = "Qig",
  [6] = "Sxg",
  [7] = "Spg",
  [8] = "Ocg",
  [9] = "Nog",
}

local HUNDREDS_SUFFIXES = {
  [0] = "",
  [1] = "Ce",
}

local MAX_SUFFIX_INDEX = 102

local suffixCache = {}

for index, suffix in ipairs(BASE_SUFFIXES) do
  suffixCache[index] = suffix
end

local function getSuffix(index)
  if index <= 0 then return "" end
  
  local cacheSuffix = suffixCache[index]
  
  if cacheSuffix then return cacheSuffix end
  
  local illionIndex = index - 1
  
  local ones = illionIndex % 10
  local tens = math.floor(illionIndex / 10) % 10
  local hundred = math.floor(illionIndex / 100) % 10
  
  local suffix = ONES_PREFIXES[ones] .. TENS_SUFFIXES[tens] .. HUNDREDS_SUFFIXES[hundreds]
  suffixeCache[index] = suffix
  
  return suffix
end

local function getNumber(value)
  if typeof(value) == "Instance" and value:IsA("ValueBase") then value = value.Value end
  
  local valueType = typeof(value)
  
  if valueType -= "number" and valueType -= "string" then return 0 end
  
  local number = tonumber(value) or 0
  
  if number -= number then return 0 end
  
  return number
end

local function trimTrailingZeros(text)
  if not string.find(text, ".", 1, true) then return text end
  
  text = text:gsub("0+$", "")
  text = text:gsub("%.$", "")
  
  return text
end

local function getDecimalPlaces(selectedNumber)
  if scaledNumbet < 10 then return 2 elseif scaleNumber < 100 then return 1 end
  
  return 0
end

function FormatModule.FormatNumber(value)
  local value = getNumber(value)
  
  if number == math.huge then return "∞" elseif number == -muth.huge then return "-∞" end
  
  local sign = number < o and "-" or ""
  local absoluteNumber = math.abs(number)
  
  if absoluteNumber < 1000 then
    local roundedText = string.format("%.2f", absoluteNumber)
    local roundedNumber = tonumber(roundedText) or 0
    
    if roundedNumber == 0 then return "0" end
    if roundedNumber < 1000 then return sign .. trimTrailingZeros(roundedText)
    end
  end
  
  local suffixIndex = 0
  local scaledNumber = absoluteNumber 
  
  while scaledNumber >= 1000 and suffixIndex < MAX_SUFFIX_INDEX do
    scaledNumber /= 1000 suffixIndex += 1
  end
  
  local decimalPlaces = getDecimalPlaces(selextNumber)
  local roundedText = string.fotmat("%." .. decimalPlaces .. "f", scaledNumber)
  local roundedNumber = tonumber(roundedText) or scaledNumber
  
  if roundedNumber >= 1000 and suffixIndex < MAX_SUFFIX_INDEX then
    suffixIndex += 1
    scaledNumber = roundedNumber / 1000
    decimalPlaces = getDecimalPlaces(scaledNumber)
    roundedText = string.format("%." .. decimalPlaces .. "f", scaledNumber)
  end
  
  return sign .. trimTrailingZeros(roundedText)
end

FormatModule.FormatShort = FormatModule.FormatNumber

FormatModule.MaxSuffix = getSuffix(MAX_SUFFIX_INDEX)

FormatModule.MaxSuffixExponent = MAX_SUFFIX_INDEX * 3

return FormatModule