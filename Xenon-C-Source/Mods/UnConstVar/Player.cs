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

namespace Xenon.Mods.UnConstVar
{
    public class Player : IScriptMod
    {
        private Config Config;
        private IModInterface modInterface;
        private int modificationCount = 0;

        public Player(IModInterface modInterface)
        {
            modInterface.Logger.Information("[XENON]: Loading const -> var modifications for Scenes/Entities/Player/player.gdc");
            this.Config = modInterface.ReadConfig<Config>();
            this.modInterface = modInterface;
        }

        public bool ShouldRun(string path) => path == "res://Scenes/Entities/Player/player.gdc";

        public IEnumerable<Token> Modify(string path, IEnumerable<Token> tokens)
        {
            foreach (var token in tokens)
            {
                if (modificationCount < 5 && token is {Type: TokenType.PrConst }) // TERRINBLE TERRIBLE TERRIBLE HACKJ
                {
                    this.modInterface.Logger.Information($"[XENON]: Change Const to VAR CAUSE BAIOT DATA IS A CONSTANT IMMA CRY (TOKEN): {token}");
                    token.Type = TokenType.PrVar;
                    modificationCount++;
                }

                yield return token;
            }
        }
    }
}
