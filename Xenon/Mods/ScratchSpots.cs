using GDWeave.Godot.Variants;
using GDWeave.Godot;
using GDWeave.Modding;
using System.Collections.Generic;
using GDWeave;
using WebfishingSampleMod;
using System.Reflection.Metadata;

namespace Xenon.Mods
{
    public class ScratchSpots : IScriptMod
    {
        private Config Config;
        private IModInterface modInterface;

        public ScratchSpots(IModInterface modInterface)
        {
            modInterface.Logger.Information("[XENON]: Loading modifications for Scenes/Minigames/ScratchTicket/scratch_spots.gdc");
            this.Config = modInterface.ReadConfig<Config>();
            this.modInterface = modInterface;
        }

        public bool ShouldRun(string path) => path == "res://Scenes/Minigames/ScratchTicket/scratch_spots.gdc";

        public IEnumerable<Token> Modify(string path, IEnumerable<Token> tokens)
        {
            var newlineConsumer = new TokenConsumer(t => t.Type is TokenType.Newline);

            var prizeAmountMatch = new MultiTokenWaiter([
                t => t is IdentifierToken { Name: "_set_price" },
                t => t.Type is TokenType.ParenthesisOpen,
                t => t is IdentifierToken { Name: "prize_amt" },

            ]);

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

                if (prizeAmountMatch.Check(token) && false) // this.Config.OPGambling
                {
                    yield return new ConstantToken(new IntVariant(1000000));
                    this.modInterface.Logger.Information($"[XENON]: Changed gambling prizes. {token}");
                    prizeAmountMatch.Reset();
                    //newlineConsumer.SetReady();
                } else
                {
                    yield return token;
                }
            }
        }
    }
}
