using GDWeave.Godot.Variants;
using GDWeave.Godot;
using GDWeave.Modding;
using System.Collections.Generic;
using GDWeave;
using WebfishingSampleMod;
using System.Reflection.Metadata;

namespace Xenon.Mods.CooldownMod
{
    public class AbilityResource : IScriptMod
    {
        private Config Config;
        private IModInterface modInterface;

        public AbilityResource(IModInterface modInterface)
        {
            modInterface.Logger.Information("[XENON]: Loading CooldownMod AbilityResource");
            Config = modInterface.ReadConfig<Config>();
            this.modInterface = modInterface;
        }

        public bool ShouldRun(string path) => path == "res://Resources/Scripts/ability_resource.gd";

        public IEnumerable<Token> Modify(string path, IEnumerable<Token> tokens)
        {
            // var cooldown = 60
            var itemCooldownMatch = new MultiTokenWaiter([
                t => t is IdentifierToken { Name: "cooldown" },
                t => t.Type is TokenType.OpAssign,
                t => t is ConstantToken {Value: IntVariant {Value: 60}},
            ]);



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

                if (itemCooldownMatch.Check(token))
                {
                    yield return new ConstantToken(new IntVariant(0));
                    this.modInterface.Logger.Information($"[XENON]: GOT {token}");
                    itemCooldownMatch.Reset();
                }
                else
                {
                    yield return token;
                    this.modInterface.Logger.Information($"[XENON]: {token}");
                }
            }
        }
    }
}
