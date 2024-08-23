import tomllib
import sys
from pathlib import Path


try:
    with open(Path.home() / ".microcsound.toml", "rb") as config_file:
        user_config = tomllib.load(config_file)
except:
    user_config = {}
    print(
        """Warning: no '.microcsound.toml' config file found in your home directory!
Falling back on default values.
To fix this, add that file from the repo to your home directory as a template,
and edit the values to your liking. Then re-run microcsound.
""",
        file=sys.stderr,
    )


with open(Path(__file__).parent.parent / "pyproject.toml", "rb") as pyproject:
    project_data = tomllib.load(pyproject)


ORC_DIR = Path(
    user_config.get("ORC_DIR", Path(__file__).parent / "share/data/")
)
DEFAULT_ORC_FILE = user_config.get("DEFAULT_ORC_FILE", "microcsound.orc")
NORMAL_CSOUND_COMMAND_STUB = user_config.get(
    "NORMAL_CSOUND_COMMAND_STUB", "csound -d --messagelevel=0 --nodisplays -W"
)
RT_CSOUND_COMMAND_STUB = user_config.get(
    "RT_CSOUND_COMMAND_STUB", "csound -b2048 -B2048 -odac"
)
MIDDLE_C_HZ = user_config.get("MIDDLE_C_HZ", 261.6255653)
MIDDLE_C_OCTAVE = user_config.get("MIDDLE_C_OCTAVE", 5)
