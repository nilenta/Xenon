using GDWeave;
using GDWeave.Godot;
using GDWeave.Godot.Variants;
using GDWeave.Modding;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using WebfishingSampleMod;

namespace Xenon.Mods
{
    public class PlayerNL : IScriptMod
    {
        private Config Config;
        private IModInterface modInterface;

        public PlayerNL(IModInterface modInterface)
        {
            modInterface.Logger.Information("[XENON]: Loading modifications for Scenes/Entities/Player/player.gdc");
            this.Config = modInterface.ReadConfig<Config>();
            this.modInterface = modInterface;
        }

        public bool ShouldRun(string path) => path == "res://Scenes/Entities/Player/player.gdc";

        public IEnumerable<Token> Modify(string path, IEnumerable<Token> tokens)
        {
            foreach (var token in tokens)
            {
                if (token is ConstantToken { Value: RealVariant { Value: 0.06 } } identifierToken && this.Config.InstantCatch) // TERRINBLE TERRIBLE TERRIBLE HACK
                {
                    this.modInterface.Logger.Information($"[XENON]: Instant catch go my scarab (TOKEN): {token}");
                    identifierToken.Value = new RealVariant(1);
                }

                yield return token;
            }
        }
    }
}
