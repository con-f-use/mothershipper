Mothershipper
=============

Very basic terminal character generator for the [Mothership](https://www.tuesdayknightgames.com/pages/mothership-rpg) pen & paper RPG.

I don't expect this to be useful for anyone but me and my friends.

![image](https://github.com/user-attachments/assets/570d5cb7-e89f-4437-a713-949b71e6d56e)

Usage
=====

Command Line
------------

Either [install nix](https://nixos.org/download/) and use:

```shell
$ nix run 'github:con-f-use/mothershipper' -- 2  # <-- number of chars to generate (optional)

---
        Stats:  33  34  36  33
        Saves:  18  17  21
        Health: 16
        Trinket: Golf Club (Putter)
        Patch: “Fuck Forever” (Roses)
        Rules:
            Scientist (base): +10 Int; +5 to one Stats; +30 Sanity; 1M, 1T
            Convict    (all): +20 Spd; +30 San; -5 to one Save; Saves made close to friendly PCs [-]; Jury-Rigging, Rimwise, 1T, 1E
        Loadout:   100cr
            Scientist (base): Civilian Clothes (AP 1), Briefcase, Prescription Pad, Fountain Pen (Poison Injector)
            Convict    (all): Prison Guard's uniform (AP 1), Stun Baton, Handcuffs, Flashlight, Short Range Comms
        Facitlity/Crime: Deep Tech Asphyxia Brig (Civil Disobedience)

---
        Stats:  32  42  27  41
        Saves:  20  23  22
        Health: 16
        Trinket: Pendant: Two Astronauts form a Skull
        Patch: Heart
        Rules:
            Marine (base): +10 Com; +10 Bdy; +20 Fear, +1 W; close friendly player fear save on panic; Military Training, Athletics, 1E or 2T
            Lawyer  (all): +10 Int; +5 Str; +20 Bdy; +10 San; Min Stress: 10, any over 20 increases a save; Linguistics, Rimwise, Jury-Rigging, Law (+20), 1T
        Loadout:   120cr
            Marine (base): Standard Battle Dress (AP 7), Combat Shotgun (4 rounds), Rucksack, Camping Gear
            Lawyer  (all): Prison Jumpsuit (AP 1), Crowbar, Personal Locator, Stimpak x5
        Training: Westies Crime Syndicate. Hostage negotiation and privateering database entry.  Dismissal: Moonlighting. Fined and indebted 1d100mcr.
```

...or copy the datafiles and script to the same directory and run:

```
python mothershipper.py 2  # <-- number of chars to generate (optional)
```

Webserver
---------

Start a WSGI webserver, e.g. micro wsgi with:

```
uwsgi --plugin python3 --http :9280 --wsgi-file src/mothershipper.py
```

or using nix:

```
nix run 'github:con-f-use/mothershipper' -- 9280
```

Once running, you should be able to make requests:

```
curl http://127.0.0.1:9280?n=2  # number of chars to generate (optional, ten thousand max)
```

You might want to open your firewall, if mothershipper should be
externally available.

NixOS Module
------------

```nix
inputs.mothershipper.url = "github:con-f-use/mothershipper";

outputs = inputs: {
    nixosConfiguration.nixos = inputs.nixpkgs.lib.nixosSystem {
      modules = [ inputs.mothershipper.nixosModules.mothershipper ];
    };
};
```

or in a NixOS light-weight virtual machine:

```
nixos-rebuild build-vm --flake "./#test-vm" --builders '' && result/bin/run-nixos-vm
```
