#!/usr/bin/env python3

import re
import os.path
import itertools
from inspect import cleandoc as dedent
from random import randint, choice

datadir = os.path.dirname(os.path.abspath(__file__)) + "/../data"


def d10(n):
    return sum(randint(1, 10) for _ in range(n))


def read_data(fname):
    with open(f"{datadir}/{fname}") as fh:
        return [
            re.split(r"\s\s+", x.strip())
            for x in fh.read().splitlines()
            if not re.match(r"^(\s*#.*|\s*)$", x)
        ]


def facility():
    if not hasattr(facility, "data"):
        facility.data = read_data(f"convict_facilities.txt")
    return f"{choice(facility.data)[2]} {choice(facility.data)[3]} {choice(facility.data)[4]} ({choice(facility.data)[1]})"


def lawyer():
    if not hasattr(lawyer, "data"):
        lawyer.data = read_data("lawyer_training_dismissial.txt")
    return f"{choice(lawyer.data)[2]}  Dismissal: {choice(lawyer.data)[1]}"


def loadout(klass):
    if not loadout.data.get(klass):
        loadout.data[klass] = read_data(f"{klass.lower()}_loadout.txt")
    return f"{choice(loadout.data[klass])[1]}"


loadout.data = {}


trinkets = read_data("trinkets.txt")
patches = read_data("patches.txt")
classd = {
    "Marine": "+10 Com; +10 Bdy; +20 Fear, +1 W; close friendly player fear save on panic; Military Training, Athletics, 1E or 2T",
    "Scientist": "+10 Int; +5 to one Stats; +30 Sanity; 1M, 1T",
    "Teamster": "+5 Stats; +10 to Saves; Industrial Equipment, Zero-G, 1T, 1E",
    "Android": "+20 Int; -10 to one Stat; +60 Fear; +1W; Linguistics, Computers, Mathematics, 1E, 2T",
    "Lawyer": "+10 Int; +5 Str; +20 Bdy; +10 San; Min-Stress: 10, any over 20 increases a Save; Linguistics, Rimwise, Jury-Rigging, Law (+20), 1T",
    "Convict": "+20 Spd; +30 San; -5 to one Save; Fear Saves made close to friendly PCs [-]; Jury-Rigging, Rimwise, 1T, 1E",
}
classes = list(classd)


def char_stream():
    while True:
        stats = (d10(2) + 25 for _ in range(4))
        saves = (d10(2) + 10 for _ in range(3))
        klass = choice(classes[0:3])
        klass_all = choice(classes)
        malen = max(len(klass), len(klass_all))
        yield dedent(
            f"""
            Stats:  {'  '.join(map(str,stats))}
            Saves:  {'  '.join(map(str,saves))}
            Health: {d10(1)+10}
            Trinket: {choice(trinkets)[1]}
            Patch: {choice(patches)[1]}
            Rules:
                {klass:{malen}} (base): {classd[klass]}
                {klass_all:{malen}}  (all): {classd[klass_all]}
            Loadout:   {d10(2)*10}cr
                {klass:{malen}} (base): {loadout(klass)}
                {klass_all:{malen}}  (all): {loadout(klass_all)}
            {'Facitlity/Crime: {}\n'.format(facility()) if klass_all == 'Convict' else ''}"""
            f"{'Training: {}\n'.format(lawyer()) if klass_all == 'Lawyer' else ''}"
            "\n---\n"
        )


def char_strings(num):
    return "\n".join(itertools.islice(char_stream(), int(num)))


# uWSGI entrypoint
def application(env, start_response):
    start_response("200 OK", [("Content-Type", "text/plain; charset=utf-8")])
    m = re.search(r"n=(\d+)", env["QUERY_STRING"])
    num_chars = 1 if m is None else int(m.group(1))
    num_chars = min(num_chars, 10_000)
    return [char_strings(num_chars).encode("utf-8")]


# CLI entrypoint
if __name__ == "__main__":
    import sys

    args = sys.argv[1:] or [1]
    print(char_strings(args[0]))
