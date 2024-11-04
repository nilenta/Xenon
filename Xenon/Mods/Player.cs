using GDWeave.Godot.Variants;
using GDWeave.Godot;
using GDWeave.Modding;
using System.Collections.Generic;
using GDWeave;
using WebfishingSampleMod;

// this can be done better ik lol
// i really gotta make this better thios sucks 
namespace Xenon.Mods
{
    public class Player : IScriptMod
    {
        private Config Config;
        private IModInterface modInterface;

        public Player(IModInterface modInterface)
        {
            modInterface.Logger.Information("[XENON]: Loading modifications for Scenes/Entities/Player/player.gdc");
            this.Config = modInterface.ReadConfig<Config>();
            this.modInterface = modInterface;
        }

        public bool ShouldRun(string path) => path == "res://Scenes/Entities/Player/player.gdc";

        public IEnumerable<Token> Modify(string path, IEnumerable<Token> tokens)
        {
            // var sprint_speed = 
            var sprintMatch = new MultiTokenWaiter([
                t => t.Type is TokenType.PrVar,
                t => t is IdentifierToken { Name: "sprint_speed" },
                t => t.Type is TokenType.OpAssign
            ]);

            var walkSpeedMatch = new MultiTokenWaiter([
                t => t.Type is TokenType.PrVar,
                t => t is IdentifierToken { Name: "walk_speed" },
                t => t.Type is TokenType.OpAssign
            ]);

            // "": {
            var catchStructureMatch1 = new MultiTokenWaiter([
                t => t is ConstantToken { Value: StringVariant { Value: "catch" } },
                t => t.Type is TokenType.Colon,
                t => t is ConstantToken { Value: RealVariant { Value: 0.0 } },
            ]);

            var catchStructureMatch2 = new MultiTokenWaiter([
                t => t is ConstantToken { Value: StringVariant { Value: "max_tier" } },
                t => t.Type is TokenType.Colon,
                t => t is ConstantToken { Value: IntVariant { Value: 0 } },
            ]);

            var catchStructureMatch3 = new MultiTokenWaiter([
                t => t is ConstantToken { Value: StringVariant { Value: "quality" } },
                t => t.Type is TokenType.Colon,
                t => t.Type is TokenType.BracketOpen,
                t => t.Type is TokenType.BracketClose,
            ]);

            var instantCatchStructure = new MultiTokenWaiter([
                t => t is ConstantToken { Value: StringVariant { Value: "catch" } },
                t => t.Type is TokenType.Colon,
                t => t is ConstantToken { Value: RealVariant { Value: 0.06 } },
            ]);

            var baitWarnMatch = new MultiTokenWaiter([
                t => t.Type is TokenType.PrVar,
                t => t is IdentifierToken { Name: "bait_warn" },
                t => t.Type is TokenType.OpAssign
            ]);

            // const GRAVITY = 
            var gravityMatch = new MultiTokenWaiter([
                t => t.Type is TokenType.PrConst,
                t => t is IdentifierToken { Name: "GRAVITY" },
                t => t.Type is TokenType.OpAssign
            ]);

            // var speed =
            var freecamMatch1 = new MultiTokenWaiter([
                t => t.Type is TokenType.PrVar,
                t => t is IdentifierToken { Name: "speed" },
                t => t.Type is TokenType.OpAssign,
            ]);

            var freecamMatch2 = new MultiTokenWaiter([
                t => t.Type is TokenType.PrVar,
                t => t is IdentifierToken { Name: "max_dist" },
                t => t.Type is TokenType.OpAssign,
            ]);



            // var is_valid_fishing_spot = 
            var validFishingSpotMatch = new MultiTokenWaiter([
                t => t.Type is TokenType.PrVar,
                t => t is IdentifierToken { Name: "is_valid_fishing_spot" },
                t => t.Type is TokenType.OpAssign
            ]);

            // var dive_distance = 
            var diveDistanceMatch = new MultiTokenWaiter([
                t => t.Type is TokenType.PrVar,
                t => t is IdentifierToken { Name: "dive_distance" },
                t => t.Type is TokenType.OpAssign
            ]);

            // var jump_height = 
            var jumpHeightMatch = new MultiTokenWaiter([
                t => t.Type is TokenType.PrVar,
                t => t is IdentifierToken { Name: "jump_height" },
                t => t.Type is TokenType.OpAssign
            ]);

            // var speed_mult = 
            var speedMultMatch1 = new MultiTokenWaiter([
                t => t.Type is TokenType.PrVar,
                t => t is IdentifierToken { Name: "speed_mult" },
                t => t.Type is TokenType.OpAssign
            ]);

            // if diving: speed mult = 
            var speedMultMatch2 = new MultiTokenWaiter([
                t => t.Type is TokenType.CfIf,
                t => t is IdentifierToken { Name: "diving" },
                t => t.Type is TokenType.Colon,
                t => t is IdentifierToken { Name: "speed_mult" },
                t => t.Type is TokenType.OpAssign,
            ]);

            // gravity_vec += Vector3(0, jump_height * x, 0)
            var speedMultMatch3 = new MultiTokenWaiter([
                t => t is IdentifierToken { Name: "gravity_vec" },
                t => t.Type is TokenType.OpAssignAdd,
                t => t.Type is TokenType.BuiltInType,
                t => t.Type is TokenType.ParenthesisOpen,
                t => t is ConstantToken {Value: IntVariant {Value: 0}},
                t => t.Type is TokenType.Comma,
                t => t is IdentifierToken { Name: "jump_height" },
                t => t.Type is TokenType.OpMul,
            ]);
            

            // camera_zoom = clamp(camera_zoom, 0.0, x
            var cameraZoomClampMatch = new MultiTokenWaiter([
                t => t is IdentifierToken { Name: "camera_zoom" },
                t => t.Type is TokenType.OpAssign,
                t => t.Type is TokenType.BuiltInFunc,
                t => t.Type is TokenType.ParenthesisOpen,
                t => t is IdentifierToken { Name: "camera_zoom" },
                t => t.Type is TokenType.Comma,
                t => t is ConstantToken {Value: RealVariant {Value: 0}},
                t => t.Type is TokenType.Comma
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

                if (sprintMatch.Check(token))
                {
                    yield return token;
                    yield return new ConstantToken(new RealVariant(this.Config.PlayerSprintSpeed));
                    this.modInterface.Logger.Information($"[XENON]: Changed sprint speed to {this.Config.PlayerSprintSpeed}");
                    sprintMatch.Reset();
                    newlineConsumer.SetReady();
                } else if (freecamMatch1.Check(token))
                {
                    yield return token;
                    yield return new ConstantToken(new RealVariant(this.Config.FreecamMovementSpeed));
                    this.modInterface.Logger.Information($"[XENON]: Changed freecam speed multiplier (1) to {this.Config.FreecamMovementSpeed}");
                    freecamMatch1.Reset();
                    newlineConsumer.SetReady();
                }
                else if (freecamMatch2.Check(token) && this.Config.UncapFreecamMovement)
                {
                    yield return token;
                    yield return new ConstantToken(new RealVariant(99999999999));
                    this.modInterface.Logger.Information($"[XENON]: uncapped freecam movement");
                    freecamMatch2.Reset();
                    newlineConsumer.SetReady();
                }
                else if (walkSpeedMatch.Check(token))
                {
                    yield return token;
                    yield return new ConstantToken(new RealVariant(this.Config.PlayerWalkSpeed));
                    this.modInterface.Logger.Information($"[XENON]: Changed walk speed to {this.Config.PlayerWalkSpeed}");
                    walkSpeedMatch.Reset();
                    newlineConsumer.SetReady();
                }
                else if (baitWarnMatch.Check(token))
                {
                    yield return token;
                    yield return new ConstantToken(new IntVariant(3));
                    baitWarnMatch.Reset();
                    newlineConsumer.SetReady();
                }
                else if (catchStructureMatch1.Check(token) && this.Config.AllowFishingWithNoBait)
                {
                    yield return new ConstantToken(new RealVariant(1));
                    this.modInterface.Logger.Information($"[XENON]: Made it possible to catch with no bait (TOKEN): {token}");
                    catchStructureMatch1.Reset();
                    // newlineConsumer.SetReady();
                }
                else if (catchStructureMatch2.Check(token) && this.Config.NoBaitOP)
                {
                    yield return new ConstantToken(new IntVariant(4));
                    catchStructureMatch2.Reset();
                    //newlineConsumer.SetReady();
                }
                else if (catchStructureMatch3.Check(token) && this.Config.NoBaitOP)
                {
                    yield return new ConstantToken(new RealVariant(0.01));
                    yield return new Token(TokenType.Comma);
                    yield return new ConstantToken(new RealVariant(0.01));
                    yield return new Token(TokenType.Comma);
                    yield return new ConstantToken(new RealVariant(0.01));
                    yield return new Token(TokenType.Comma);
                    yield return new ConstantToken(new RealVariant(0.01));
                    yield return new Token(TokenType.Comma);
                    yield return new ConstantToken(new RealVariant(0.01));
                    yield return new Token(TokenType.Comma);
                    yield return new ConstantToken(new RealVariant(1.0));
                    yield return new Token(TokenType.BracketClose);
                    catchStructureMatch3.Reset();
                    //newlineConsumer.SetReady();
                }

                else if (gravityMatch.Check(token))
                {
                    yield return token;
                    yield return new ConstantToken(new RealVariant(this.Config.PlayerGravity));
                    this.modInterface.Logger.Information($"[XENON]: Changed gravity to {this.Config.PlayerGravity}");
                    gravityMatch.Reset();
                    newlineConsumer.SetReady();
                }
                else if (diveDistanceMatch.Check(token))
                {
                    yield return token;
                    yield return new ConstantToken(new RealVariant(this.Config.PlayerDiveDistance));
                    this.modInterface.Logger.Information($"[XENON]: Changed dive distance to {this.Config.PlayerDiveDistance}");
                    diveDistanceMatch.Reset();
                    newlineConsumer.SetReady();
                }
                else if (jumpHeightMatch.Check(token))
                {
                    yield return token;
                    yield return new ConstantToken(new RealVariant(this.Config.PlayerJumpHeight));
                    this.modInterface.Logger.Information($"[XENON]: Changed jump height to {this.Config.PlayerJumpHeight}");
                    jumpHeightMatch.Reset();
                    newlineConsumer.SetReady();
                }
                else if (speedMultMatch1.Check(token))
                {
                    yield return token;
                    yield return new ConstantToken(new RealVariant(this.Config.PlayerSpeedMult));
                    this.modInterface.Logger.Information($"[XENON]: Changed speed multiplier to {this.Config.PlayerSpeedMult}");
                    speedMultMatch1.Reset();
                    newlineConsumer.SetReady();
                }
                else if (speedMultMatch2.Check(token) && this.Config.BellySlide)
                {
                    yield return token;
                    yield return new ConstantToken(new RealVariant(this.Config.PlayerSpeedMult + 0.15));
                    this.modInterface.Logger.Information($"[XENON]: Changed speed multiplier for diving to {this.Config.PlayerSpeedMult + 0.15}");
                    speedMultMatch2.Reset();
                    newlineConsumer.SetReady();
                }
                else if (speedMultMatch3.Check(token) && this.Config.BellySlide)
                {
                    yield return token;
                    yield return new ConstantToken(new RealVariant(1));
                    yield return new Token(TokenType.Comma);
                    yield return new ConstantToken(new IntVariant(0));
                    yield return new Token(TokenType.ParenthesisClose);
                    this.modInterface.Logger.Information($"[XENON]: bely slide");
                    speedMultMatch3.Reset();
                    newlineConsumer.SetReady();
                }
                else if (validFishingSpotMatch.Check(token) && this.Config.FishAnywhere)
                {
                    yield return token;
                    yield return new ConstantToken(new BoolVariant(true));
                    this.modInterface.Logger.Information($"[XENON]: Enabled fishing anywhere.");
                    validFishingSpotMatch.Reset();
                    newlineConsumer.SetReady();

                }
                else if (cameraZoomClampMatch.Check(token) && this.Config.UncapZoom)
                {
                    yield return token;
                    yield return new ConstantToken(new RealVariant(999999999));
                    yield return new Token(TokenType.ParenthesisClose);

                    this.modInterface.Logger.Information($"[XENON]: Uncapped zoom");
                    cameraZoomClampMatch.Reset();
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
