"""Kjorer NIST CAVP (SHAVS) byte-orienterte vektorer mot sha256.generate_hash."""

import sys
from pathlib import Path

from sha256 import generate_hash

VECTOR_DIR = Path(__file__).resolve().parent.parent / "vectors" / "shabytetestvectors"


def parse_kat(path):
    """Yter (melding, forventet digest) for hver KAT-vektor i en .rsp-fil."""
    length = msg = None
    for raw in path.read_text(encoding="utf-8").splitlines():
        line = raw.strip()
        if not line or line.startswith(("#", "[")):
            continue
        key, _, value = (p.strip() for p in line.partition("="))
        if key == "Len":
            length = int(value)
        elif key == "Msg":
            msg = bytes.fromhex(value)
        elif key == "MD":
            if length % 8 == 0:
                yield msg[: length // 8], bytes.fromhex(value)
            length = msg = None


def parse_monte(path):
    """Returnerer (seed, [forventet MD per checkpoint])."""
    seed, expected = None, []
    for raw in path.read_text(encoding="utf-8").splitlines():
        line = raw.strip()
        if not line or line.startswith(("#", "[")):
            continue
        key, _, value = (p.strip() for p in line.partition("="))
        if key == "Seed":
            seed = bytes.fromhex(value)
        elif key == "MD":
            expected.append(bytes.fromhex(value))
    return seed, expected


def run_kat(path):
    ok = failures = 0
    for msg, expected in parse_kat(path):
        if generate_hash(msg) == expected:
            ok += 1
        else:
            failures += 1
            print(f"  FEIL  len={len(msg)} bytes")
            print(f"        forventet {expected.hex()}")
            print(f"        fikk      {generate_hash(msg).hex()}")
    print(f"{path.name}: {ok} bestått, {failures} feilet")
    return failures


def run_monte(path):
    seed, expected = parse_monte(path)
    md, failures = seed, 0
    for count, want in enumerate(expected):
        a = b = c = md
        for _ in range(1000):
            a, b, c = b, c, generate_hash(a + b + c)
        md = c
        if md != want:
            failures += 1
            print(f"  FEIL  COUNT={count}")
            print(f"        forventet {want.hex()}")
            print(f"        fikk      {md.hex()}")
            break
    print(f"{path.name}: {len(expected) - failures} bestatt, {failures} feilet")
    return failures


def main():
    if not VECTOR_DIR.is_dir():
        sys.exit(f"fant ikke {VECTOR_DIR}")

    failures = 0
    for name in ("SHA256ShortMsg.rsp", "SHA256LongMsg.rsp"):
        path = VECTOR_DIR / name
        if path.is_file():
            failures += run_kat(path)
        else:
            print(f"{name}: mangler, hoppet over")

    monte = VECTOR_DIR / "SHA256Monte.rsp"
    if monte.is_file() and "--skip-monte" not in sys.argv:
        failures += run_monte(monte)

    print("ALLE BESTÅTT" if failures == 0 else f"{failures} FEIL")
    return 1 if failures else 0


if __name__ == "__main__":
    sys.exit(main())