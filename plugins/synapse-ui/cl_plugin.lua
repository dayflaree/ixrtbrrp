for i = 4, 32, 2 do
    surface.CreateFont("synapse.nagonia." .. i, {
        font = "Nagonia",
        size = ScreenScale(i)
    })

    surface.CreateFont("synapse.nagonia.bold." .. i, {
        font = "Nagonia",
        size = ScreenScale(i),
        weight = 700
    })

    surface.CreateFont("synapse.nagonia.italic." .. i, {
        font = "Nagonia",
        size = ScreenScale(i)
    })

    surface.CreateFont("synapse.nagonia.bold.italic." .. i, {
        font = "Nagonia",
        size = ScreenScale(i),
        weight = 700,
        italic = true
    })
end

surface.CreateFont("synapse.hl2.large", {
    font = "HalfLife2",
    size = ScreenScale(32)
})

surface.CreateFont("synapse.hl2.medium", {
    font = "HalfLife2",
    size = ScreenScale(24)
})

surface.CreateFont("synapse.hl2.small", {
    font = "K12HL2",
    size = ScreenScale(16)
})

surface.CreateFont("synapse.din.large", {
    font = "Alte DIN 1451 Mittelschrift",
    size = ScreenScale(24)
})

surface.CreateFont("synapse.din.medium", {
    font = "Alte DIN 1451 Mittelschrift",
    size = ScreenScale(12)
})

surface.CreateFont("synapse.din.small", {
    font = "Alte DIN 1451 Mittelschrift",
    size = ScreenScale(8)
})

sound.Add({
    name = "synapse.button.press",
    channel = CHAN_STATIC,
    volume = 1.0,
    level = 75,
    pitch = 160,
    sound = "buttons/button9.wav"
})

sound.Add({
    name = "synapse.button.hover",
    channel = CHAN_STATIC,
    volume = 0.6,
    level = 75,
    pitch = 200,
    sound = "buttons/button24.wav"
})

sound.Add({
    name = "synapse.button.disabled",
    channel = CHAN_STATIC,
    volume = 0.8,
    level = 75,
    pitch = 120,
    sound = "buttons/button10.wav"
})