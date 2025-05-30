# ErnGearRandomizer

This is a Morrowind [OpenMW](https://openmw.org/) NPC gear randomizer. It randomly swaps out clothing, weapons, and armor on Morrowind NPCs.

This has *no dependencies* on any other mods and will *work with all content*, whether provided by a mod or with the base game.

Every playthrough will result in different gear for NPCs.

Even though there are safeties in place to not break Vanilla or Expansion quests, it's possible that quests might be harder or broken. Quests provided by mods are susceptible to breaking more.

This is a screenshot of the game when randomization chance is maximized:
![example](ErnGearRandomizerExample.png)


## Installing
Extract [main](https://github.com/erinpentecost/ErnGearRandomizer/archive/refs/heads/main.zip) to your `mods/` folder.


In your `openmw.cfg` file, and add these lines in the correct spots:

```yaml
data="/wherevermymodsare/mods/ErnGearRandomizer-main"

content=ErnGearRandomizer.omwscripts
```

## Configuring

You can change the settings for the mod in-game.

* Randomization chance per item.
* Enable/Disable clothing swaps.
* Enable/Disable armor swaps.
* Enable/Disable weapon swaps.
* Enable/Disable enchanted item swaps.
* Enable/Disable similar-item swap restrictions.
* Exclude classes of NPCs by a comma-separated list of [patterns](http://lua-users.org/wiki/PatternsTutorial).
* Exclude additional items by a comma-separated list of [patterns](http://lua-users.org/wiki/PatternsTutorial).


## FAQ

### Why am I seeing a bunch of yellow triangles or missing body parts?
Some other mod you installed came with items that have really busted meshes or items that only have meshes for one race or sex. You can fix this by adding the IDs of those bad items in the item ban list setting.

### Does this conflict with mods that change guard armor?
It will still work, but you may wish to disable changes to guards by this mod by adding `guard` to the class ban list setting.

### Why do I keep hearing spell effects trigger when I enter a new area?
This is because you enabled enchanted item swaps. When an NPC equips a magic item, it plays a short magical effect. That's what you're hearing (and seeing, if you can catch it in time). You'll only hear this the first time you enter an area.

## I'm making a mod. How do I make sure my items aren't in the swap tables?
Make sure items you don't want included have one of these strings in their ID:
* `theater`
* `unique`
* `dummy`
* `reward`
* `curse`

## Contributing

Feel free to submit a PR to the [repo](https://github.com/erinpentecost/ErnGearRandomizer) provided:

* You assert that all code submitted is your own work.
* You relinquish ownership of the code upon merge to `main`.
* You acknowledge your code will be governed by the project license.
