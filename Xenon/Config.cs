using System.Text.Json.Serialization;

namespace WebfishingSampleMod;

public class Config {
    [JsonInclude] public float PlayerSprintSpeed = 6.44f;
    [JsonInclude] public float PlayerDiveDistance = 9.0f;
    [JsonInclude] public float PlayerJumpHeight = 7.5f;
    [JsonInclude] public float PlayerSpeedMult = 1f;
    [JsonInclude] public float PlayerGravity = 32.0f;
    [JsonInclude] public float PlayerWalkSpeed = 3.2f;
    [JsonInclude] public bool UncapZoom = false;
    [JsonInclude] public bool AllowFishingWithNoBait = false;
    [JsonInclude] public bool FishAnywhere = false;
    [JsonInclude] public bool InstantCatch = false;
    [JsonInclude] public bool BellySlide = false;
    [JsonInclude] public bool UncapFreecamMovement = false;
    [JsonInclude] public float FreecamMovementSpeed = 4f;
    [JsonInclude] public bool NoItemCooldown = false;
    [JsonInclude] public bool PropsUncapped = false;

}
