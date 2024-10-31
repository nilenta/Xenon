using GDWeave;

namespace WebfishingSampleMod;

public class Mod : IMod {
    public Config Config;

    public Mod(IModInterface modInterface) {
        this.Config = modInterface.ReadConfig<Config>();
        modInterface.RegisterScriptMod(new Xenon.Mods.Player(modInterface)); // load player mods
        modInterface.RegisterScriptMod(new Xenon.Mods.PlayerData(modInterface)); // load player data mods
        modInterface.RegisterScriptMod(new Xenon.Mods.ScratchSpots(modInterface)); // load scratch off stuff


        // done
        modInterface.Logger.Information("[XENON]: Loaded successfully!");
    }

    public void Dispose() {
        
    }
}
