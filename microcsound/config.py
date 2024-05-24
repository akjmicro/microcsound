import tomllib
from pathlib import Path

try:
    with open(Path.home() / ".microcsound.toml", "rb") as config_file:
        user_config = tomllib.load(config_file)
except:
    user_config = {}
    print("Warning: no '.microcsound.toml' config file found in your home directory!")
    print("Falling back on default values.")
    print(
        "To fix these, add that file from the repo to your home directory as a template, "
    )
    print("and edit the values to your liking. Then re-run microcsound.")


ORC_DIR = user_config.get("ORC_DIR", "/usr/local/share/microcsound")
DEFAULT_ORC_FILE = user_config.get("DEFAULT_ORC_FILE", "8bit.orc")
NORMAL_CSOUND_COMMAND_STUB = user_config.get(
    "NORMAL_CSOUND_COMMAND_STUB", "csound -d --messagelevel=0 --nodisplays -W"
)
RT_CSOUND_COMMAND_STUB = user_config.get(
    "RT_CSOUND_COMMAND_STUB", "csound -b2048 -B2048 -odac"
)
MIDDLE_C_HZ = user_config.get("MIDDLE_C_HZ", 261.6255653)
MIDDLE_C_OCTAVE = user_config.get("MIDDLE_C_OCTAVE", 5)
