# scripts/gen_sha256_pkg_vectors.py
import random
from sha256 import sigma0, sigma1, capsigma0, capsigma1, rotate, ch, maj

random.seed(42)
with open("vectors/sha256_pkg_functions.txt", "w") as fh:
    for _ in range(500):
        x = random.getrandbits(32)
        y = random.getrandbits(32)
        z = random.getrandbits(32)
        fh.write(f"{x:08x} {y:08x} {z:08x}"
                f" {rotate(x,7):08x} {sigma0(x):08x} {sigma1(x):08x}"
                f" {capsigma0(x):08x} {capsigma1(x):08x}"
                f" {ch(x,y,z):08x} {maj(x,y,z):08x}\n")