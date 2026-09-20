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