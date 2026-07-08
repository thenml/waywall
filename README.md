# nml's waywall config V3

fully rewritten to be as easily configurable as possible! cooked a little too hard so this may be a little bloated lmao

based on gore's barebones and soup's configs

### features

- ★ WORKS FOR ALL RESOLUTIONS!!! (check [setup](#setup))
- ★ hyper configurable options file with luals types
- ★ patching options with profiles
- ★ quick setup script
- ★ disable remap in chat
- tall/thin/wide and more
- f3 text, pie, glowdar mirrors
- mirror borders
- mpk quickbind

## setup

0. if you already have an existing config, run
   ```bash
   mv ~/.config/waywall ~/.config/waywall.bkp
   ```
   to backup it
1. clone the config
   ```bash
   git clone https://github.com/thenml/waywall-config.git ~/.config/waywall
   ```
2. run `python3 setup.py`

done! (now go fully read the options)

## profile setup

1. add or choose a profile in `profile/`
2. put `waywall wrap --profile profile/{name} --` as your wrapper command (no .lua at the end!)
   - example: `waywall wrap --profile profile/draftout --`

done!

## hermes state output setup

enable experimental scipt that watches hermes `state.json` and converts it to a `wpstateoutput.txt` that waywall can read. also creates a dummy `fakestateoutput.jar` mod to trick waywall into reading the state

put `bash /home/$USER/.config/waywall/scripts/hermes-compat.sh` **before** the waywall wrapper

example: `bash /home/$USER/.config/waywall/scripts/hermes-compat.sh waywall wrap --profile profile/draftout --`

done!

## screenshots

![preemptive](./screenshots/preemptive.png)
![glowdar](./screenshots/glowdar.png)
![eye-measure-19x10](./screenshots/eye-measure-19x10.png)
![preemptive-modern](./screenshots/preemptive-modern.png)