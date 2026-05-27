-- Monitors

if _G.HOSTNAME == "death-pc" then
    hl.monitor({
        output = "desc:BNQ BenQ EL2870U 26M05467SL0",
        mode = "2560x1440",
        position = "0x0",
        scale = "1"
    })
    hl.monitor({
        output = "desc:Acer Technologies R240HY T4BAA0012400",
        mode = "1920x1080",
        position = "-1920x0",
        scale = "1"
    })
    hl.monitor({
        output = "desc:WAM U24C 0000000000001",
        mode = "1920x1080",
        position = "2560x0",
        scale = "1"
    })
else
    hl.monitor({
        output = "",
        mode = "preferred",
        position = "auto",
        scale = "1"
    })
end
