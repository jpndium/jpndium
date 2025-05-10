import argparse
import json
import sys
from sudachipy import Dictionary, SplitMode


parser = argparse.ArgumentParser(
    prog="tokenizer", description="Tokenize Japanese text"
)
parser.add_argument(
    "-u", "--unique", action="store_true", help="Ignore duplicate tokens"
)
args = parser.parse_args()
unique = args.unique

tokenizer = Dictionary().create()
split_modes = [SplitMode.C, SplitMode.B, SplitMode.A]

seen = set()


def tokenize(text):
    rows = []

    if not text or (unique and text in seen):
        return rows
    seen.add(text)

    morphemes = None
    for split_mode in split_modes:
        morphemes = tokenizer.tokenize(text, split_mode)
        if len(morphemes) > 1:
            for morpheme in morphemes:
                for row in tokenize(morpheme.surface().strip()):
                    rows.append(row)
            break

    rows.append(build_row(text, morphemes))

    return rows


def build_row(text, morphemes):
    return {
        "text": text,
        **build_composition(morphemes),
        **build_morpheme(morphemes),
    }


def build_composition(morphemes):
    if len(morphemes) <= 1:
        return {}

    composition = " ".join([m.surface() for m in filter(None, morphemes)])
    return {"composition": composition}


def build_morpheme(morphemes):
    if len(morphemes) != 1:
        return {}

    morpheme = morphemes[0]
    if morpheme.is_oov():
        return {}

    return {
        "surface": morpheme.surface(),
        "part_of_speech": ",".join(morpheme.part_of_speech()),
        "dictionary_form": morpheme.dictionary_form(),
        "normalized_form": morpheme.normalized_form(),
        "reading_form": morpheme.reading_form(),
    }


for line in sys.stdin:
    for row in tokenize(line.strip()):
        sys.stdout.write(json.dumps(row, ensure_ascii=False))
        sys.stdout.write("\n")
