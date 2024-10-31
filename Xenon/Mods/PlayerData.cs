using GDWeave.Godot.Variants;
using GDWeave.Godot;
using GDWeave.Modding;
using System.Collections.Generic;
using GDWeave;
using WebfishingSampleMod;
using System.Reflection.Metadata;

namespace Xenon.Mods
{
    public class PlayerData : IScriptMod
    {
        private Config Config;
        private IModInterface modInterface;

        public PlayerData(IModInterface modInterface)
        {
            modInterface.Logger.Information("[XENON]: Loading modifications for Scenes/Singletons/playerdata.gdc");
            this.Config = modInterface.ReadConfig<Config>();
            this.modInterface = modInterface;
        }

        public bool ShouldRun(string path) => path == "res://Scenes/Singletons/playerdata.gdc";

        public IEnumerable<Token> Modify(string path, IEnumerable<Token> tokens)
        {
            var newlineConsumer = new TokenConsumer(t => t.Type is TokenType.Newline);

            foreach (var token in tokens)
            {
                if (newlineConsumer.Check(token))
                {
                    continue;
                }

                if (newlineConsumer.Ready)
                {
                    yield return token;
                    newlineConsumer.Reset();
                }
                
                    yield return token;
            }
        }
    }
}
