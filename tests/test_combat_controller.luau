--!strict
--[[
    test_combat_controller.luau
    Automatisierter Lune Unit-Test zur Verifikation von CombatController.luau.
]]

local ProfileTemplate = require("../src/Shared/Config/ProfileTemplate")
local DataController = require("../src/Client/Controllers/DataController")
local CombatController = require("../src/Client/Controllers/CombatController")

print("🧪 Starte CombatController Verifikation...")

-- 1. Test: Initialisierung & Profil setzen
DataController:Init()
DataController:Start()
CombatController:Init()
CombatController:Start()

DataController:SetLocalProfile(ProfileTemplate.GetDefault())

-- 2. Test: Angriff & Cooldown-Gate
assert(CombatController:CanAttack() == true, "CanAttack muss initial true sein")

local performedWeapon = ""
local performedTarget: any = nil
CombatController.AttackPerformed:Connect(function(wId, target)
    performedWeapon = wId
    performedTarget = target
end)

local mockMob = { Name = "EarthSlime_Target" }
local attackSuccess = CombatController:PerformAttack(mockMob)
assert(attackSuccess == true, "Erster Angriff muss erfolgreich sein")
assert(performedWeapon == "BasicBlade", "Ausgerüstete Waffe muss BasicBlade sein")
assert(performedTarget == mockMob, "Ziel-Mob muss übergeben worden sein")
assert(CombatController:CanAttack() == false, "Direkt nach Angriff muss CanAttack false sein (Cooldown)")

-- Cooldown-Spam Versuch
local spamAttack = CombatController:PerformAttack(mockMob)
assert(spamAttack == false, "Spam-Angriff während des Cooldowns muss blockiert werden")

-- 3. Test: Reichweiten-Validierung (20 Studs Entfernung bei 12 Studs Range)
CombatController._lastAttackTime = 0 -- Cooldown zurücksetzen
local playerPos = { X = 0, Y = 0, Z = 0 }
local outOfRangeTargetPos = { X = 20, Y = 0, Z = 0 }

local rangeFail = CombatController:PerformAttack(mockMob, playerPos, outOfRangeTargetPos)
assert(rangeFail == false, "Angriff auf Ziel außerhalb von 12 Studs muss blockiert werden")

-- 4. Test: Begleiter-Aktivierung (FirePhoenix)
assert(CombatController:CanCastSummon() == true, "Begleiter-Cast muss initial bereit sein")

local triggeredSummon = ""
CombatController.SummonTriggered:Connect(function(sId)
    triggeredSummon = sId
end)

local castSuccess = CombatController:CastSummon()
assert(castSuccess == true, "Erster Begleiter-Cast muss erfolgreich sein")
assert(triggeredSummon == "FirePhoenix", "Ausgelöster Begleiter muss FirePhoenix sein")
assert(CombatController:CanCastSummon() == false, "Direkt nach Cast muss Begleiter auf Cooldown sein")

local castSpam = CombatController:CastSummon()
assert(castSpam == false, "Begleiter-Cast während Cooldown muss fehlschlagen")

-- 5. Test: Treffer-Feedback Reaktivität
local receivedDamage = 0
local receivedCrit = false
CombatController.DamageFeedbackReceived:Connect(function(feedback)
    receivedDamage = feedback.damage
    receivedCrit = feedback.isCrit
end)

CombatController.DamageFeedbackReceived:Fire({
    targetModel = mockMob,
    damage = 38,
    isCrit = true,
    isHeal = false,
})

assert(receivedDamage == 38 and receivedCrit == true, "CombatFeedback Signal muss korrekt verarbeitet werden")

print("✅ CombatController zu 100% erfolgreich validiert!")
