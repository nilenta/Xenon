using GDWeave.Godot.Variants;
using GDWeave.Godot;
using GDWeave.Modding;
using GDWeave;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using WebfishingSampleMod;

namespace Xenon.Mods.UncapProps
{
    public class Player : IScriptMod
    {
        private Config Config;
        private IModInterface modInterface;

        public Player(IModInterface modInterface)
        {
            modInterface.Logger.Information("[XENON]: Loading InfiniteJump");
            this.Config = modInterface.ReadConfig<Config>();
            this.modInterface = modInterface;
        }

        public bool ShouldRun(string path) => path == "res://Scenes/Entities/Player/player.gdc";

        public IEnumerable<Token> Modify(string path, IEnumerable<Token> tokens)
        {
            var propMatch1 = new MultiTokenWaiter([
                t => t.Type is TokenType.CfIf,
                t => t is IdentifierToken { Name: "prop_ids" },
                t => t.Type is TokenType.Period,
                t => t is IdentifierToken { Name: "size" },
                t => t.Type is TokenType.ParenthesisOpen,
                t => t.Type is TokenType.ParenthesisClose,
                t => t.Type is TokenType.OpGreater,
            ]);

            var notificationMatch = new MultiTokenWaiter([
                t => t is ConstantToken { Value: StringVariant { Value: "invalid prop placement" } },
                t => t.Type is TokenType.Comma,
                t => t is ConstantToken { Value: IntVariant { Value: 1 } },
                t => t.Type is TokenType.ParenthesisClose,
                t => t.Type is TokenType.Newline,
            ]);

            var notificationMatch2 = new MultiTokenWaiter([
                t => t.Type is TokenType.CfIf,
                t => t.Type is TokenType.Dollar,
                t => t is IdentifierToken { Name: "detection_zones" },
                t => t.Type is TokenType.OpDiv,
                t => t is IdentifierToken { Name: "prop_detect" },
                t => t.Type is TokenType.Period,
                t => t is IdentifierToken { Name: "get_overlapping_bodies" },
                t => t.Type is TokenType.ParenthesisOpen,
                t => t.Type is TokenType.ParenthesisClose,
                t => t.Type is TokenType.Period,
                t => t is IdentifierToken { Name: "size" },
                t => t.Type is TokenType.ParenthesisOpen,
                t => t.Type is TokenType.ParenthesisClose,
                t => t.Type is TokenType.OpGreater,
                t => t is ConstantToken { Value: IntVariant { Value: 0 } },
                t => t.Type is TokenType.OpOr,
                t => t.Type is TokenType.OpNot,
                t => t is IdentifierToken { Name: "is_on_floor" },
                t => t.Type is TokenType.ParenthesisOpen,
                t => t.Type is TokenType.ParenthesisClose,
                t => t.Type is TokenType.OpOr,
                t => t.Type is TokenType.OpNot,
                t => t.Type is TokenType.Dollar,
                t => t is IdentifierToken { Name: "detection_zones" },
                t => t.Type is TokenType.OpDiv,
                t => t is IdentifierToken { Name: "prop_ray" },
                t => t.Type is TokenType.Period,
                t => t is IdentifierToken { Name: "is_colliding" },
                t => t.Type is TokenType.ParenthesisOpen,
                t => t.Type is TokenType.ParenthesisClose,
                t => t.Type is TokenType.Colon,
                t => t.Type is TokenType.Newline,
               ]);



            var newlineConsumer = new TokenConsumer(t => t.Type is TokenType.Newline);
            var modified = false;
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

                if (propMatch1.Check(token))
                {
                    yield return token;
                    yield return new ConstantToken(new IntVariant(999999));
                    yield return new Token(TokenType.Colon);

                    this.modInterface.Logger.Information($"[XENON]: {token}");
                    propMatch1.Reset();
                    newlineConsumer.SetReady();
                }
                else if (notificationMatch.Check(token))
                {
                    yield return new Token(TokenType.Newline);
                    notificationMatch.Reset();
                    newlineConsumer.SetReady();
                    modified = true;
                }
                else if (notificationMatch2.Check(token) && modified)
                {
                    yield return new IdentifierToken("_refresh_props");
                    yield return new Token(TokenType.ParenthesisOpen);
                    yield return new Token(TokenType.ParenthesisClose);

                    notificationMatch.Reset();
                    newlineConsumer.SetReady();
                }
                else
                {
                    yield return token;
                }
            }
        }

    }
}
