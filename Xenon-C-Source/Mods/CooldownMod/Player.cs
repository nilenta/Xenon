﻿using GDWeave.Godot.Variants;
using GDWeave.Godot;
using GDWeave.Modding;
using System.Collections.Generic;
using GDWeave;
using WebfishingSampleMod;
using System.Reflection.Metadata;

namespace Xenon.Mods.CooldownMod
{
    public class Player : IScriptMod
    {
        private Config Config;
        private IModInterface modInterface;

        public Player(IModInterface modInterface)
        {
            modInterface.Logger.Information("[XENON]: Loading CooldownMod Player");
            Config = modInterface.ReadConfig<Config>();
            this.modInterface = modInterface;
        }

        public bool ShouldRun(string path) => path == "res://Scenes/Entities/Player/player.gdc";

        public IEnumerable<Token> Modify(string path, IEnumerable<Token> tokens)
        {
            // var item_cooldown = 30
            var itemCooldownMatch = new MultiTokenWaiter([
                t => t is IdentifierToken { Name: "item_cooldown" },
                t => t.Type is TokenType.OpAssign,
                t => t is ConstantToken {Value: IntVariant {Value: 30}},
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
                    // yield return token;
                    yield return new ConstantToken(new IntVariant(0));
                    this.modInterface.Logger.Information($"[XENON]: {token}");
                    itemCooldownMatch.Reset();
                    // newlineConsumer.SetReady();
                }
                else
                {
                    yield return token;
                }
            }
        }
    }
}
