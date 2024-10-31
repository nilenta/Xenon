using System.Text.Json.Serialization;

namespace WebfishingSampleMod;

public class Config {

    // gamble growth
    [JsonInclude] public bool GrowOnGamble = false;
    [JsonInclude] public float GrowOnGambleAmount = 2f;

    // simple configs
    [JsonInclude] public float PlayerSprintSpeed = 6.88f;
    [JsonInclude] public float PlayerDiveDistance = 15.0f;
    [JsonInclude] public float PlayerJumpHeight = 7.5f;
    [JsonInclude] public float PlayerSpeedMult = 1.35f;
    [JsonInclude] public float PlayerGravity = 32.0f;
    [JsonInclude] public bool UncapZoom = false;

    // HACKS
    [JsonInclude] public bool AllowFishingWithNoBait = false;
    [JsonInclude] public bool NoBaitOP = false;
    [JsonInclude] public bool FishAnywhere = false;


    // PLAYER DATA

}
