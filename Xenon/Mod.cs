using GDWeave;

namespace WebfishingSampleMod;

public class Mod : IMod {
    public Config Config;

    public Mod(IModInterface modInterface) {
        this.Config = modInterface.ReadConfig<Config>();
        modInterface.RegisterScriptMod(new Xenon.Mods.Player(modInterface)); // load player mods
        modInterface.RegisterScriptMod(new Xenon.Mods.PlayerNL(modInterface)); // load other player mods

        if (this.Config.NoItemCooldown)
        {
            modInterface.RegisterScriptMod(new Xenon.Mods.CooldownMod.Player(modInterface));
            modInterface.RegisterScriptMod(new Xenon.Mods.CooldownMod.AbilityResource(modInterface));
        }

        // done
        modInterface.Logger.Information("[XENON]: Loaded successfully!");
    }

    public void Dispose() {}
}
