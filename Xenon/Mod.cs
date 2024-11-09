using GDWeave;

namespace WebfishingSampleMod;

public class Mod : IMod {
    public Config Config;

    public Mod(IModInterface modInterface) {
        this.Config = modInterface.ReadConfig<Config>();
        modInterface.RegisterScriptMod(new Xenon.Mods.Player(modInterface));

        modInterface.RegisterScriptMod(new Xenon.Mods.UnConstVar.Player(modInterface));
        
        if (this.Config.NoItemCooldown)
        {
            modInterface.RegisterScriptMod(new Xenon.Mods.CooldownMod.Player(modInterface));
            modInterface.RegisterScriptMod(new Xenon.Mods.CooldownMod.AbilityResource(modInterface));
        }


        if (this.Config.PropsUncapped)
        {
            modInterface.RegisterScriptMod(new Xenon.Mods.UncapProps.Player(modInterface));
        }

        // done
        modInterface.Logger.Information("[XENON]: Loaded successfully!");
    }

    public void Dispose() {}
}
