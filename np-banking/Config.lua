Config = {}

Config.AutoCreateAccount = true

Config.atms = {
    "prop_atm_01",
    "prop_atm_02",
    "prop_atm_03",
    "prop_fleeca_atm"
}

Config.peds = {
    [1] = { -- Pacific Standard
        model = 'u_m_m_bankman',
        coords = vector4(269.36, 217.34, 106.28, 72.13),  
        createAccounts = true
    },
    [2] = {
        model = 'ig_barry',
        coords = vector4(313.84, -280.58, 54.16, 338.31)
    },
    [3] = {
        model = 'ig_barry',
        coords = vector4(149.46, -1042.09, 29.37, 335.43)
    },
    [4] = {
        model = 'ig_barry',
        coords = vector4(-351.23, -51.28, 49.04, 341.73)
    },
    [5] = {
        model = 'ig_barry',
        coords = vector4(-1211.9, -331.9, 37.78, 20.07)
    },
    [6] = {
        model = 'ig_barry',
        coords = vector4(-2961.14, 483.09, 15.7, 83.84)            
    },
    [7] = {
        model = 'ig_barry',
        coords = vector4(1174.8, 2708.2, 38.09, 178.52)
    },
    [8] = { -- paleto
        model = 'u_m_m_bankman',
        coords = vector4(-110.61, 6470.0, 31.63, 220.23), 
        createAccounts = true  
    },
    [9] = { -- maze
        model = 'ig_barry',
        coords = vector4(-1311.47, -823.02, 17.15, 217.17),
        createAccounts = true     
    }
}

