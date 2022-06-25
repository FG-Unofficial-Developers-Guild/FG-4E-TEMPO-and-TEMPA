[![Build FG-Usable File](https://github.com/FG-Unofficial-Developers-Guild/FG-4E-TEMPO-and-TEMPA/actions/workflows/create-ext.yml/badge.svg)](https://github.com/FG-Unofficial-Developers-Guild/FG-4E-TEMPO-and-TEMPA/actions/workflows/create-ext.yml) [![Luacheck](https://github.com/FG-Unofficial-Developers-Guild/FG-4E-TEMPO-and-TEMPA/actions/workflows/luacheck.yml/badge.svg)](https://github.com/FG-Unofficial-Developers-Guild/FG-4E-TEMPO-and-TEMPA/actions/workflows/luacheck.yml)

# Temporary Hitpoints Effects
This extension adds effects to give temporary hitpoints to characters either on the beginning or end of their turn.
If temp hitpoints are already in place, the higher of the two numbers will be used (this follows the way temp hp works in FG for 4E ruleset).

# Compatibility
This extension has been tested with [FantasyGrounds Unity](https://www.fantasygrounds.com/home/FantasyGroundsUnity.php) 4.2.2 (2022-06-07).

## Examples
### TEMPO
TEMPO: 5 - 5 temp hitpoints on start of turn (if not at 0hp or below and character has 0 temp hitpoints)

TEMPO: 1d4 - 1 to 4 temp hitpoints on start of turn (if not at 0hp or below and character has 0 temp hitpoints)

TEMPO: 5 -- 1 temp hitpoints on end of turn (if not at 0hp or below and character has 4 temp hitpoints)

TEMPO: 5 -- 2 temp hitpoints on end of turn (if not at 0hp or below and character has 3 temp hitpoints)

### TEMPA
TEMPA: 5 -- 5 temp hitpoints on end of turn (if not at 0hp or below and character has 0 temp hitpoints)

TEMPA: 1d4 -- 1 to 4 temp hitpoints on end of turn (if not at 0hp or below and character has 0 temp hitpoints)

TEMPA: 1d4 -- 0 temp hitpoints on end of turn (if not at 0hp or below and character has 4 temp hitpoints)

TEMPA: 1d4 -- 0 to 2 temp hitpoints on end of turn (if not at 0hp or below and character has 2 temp hitpoints) 
