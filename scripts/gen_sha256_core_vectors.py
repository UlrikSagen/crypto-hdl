import random
from sha256 import pad, generate_hash

random.seed(42)

lengder = [0, 55, 56, 64, 119, 120] + [random.randint(0, 256) for _ in range(512)]

with open("vectors/sha256_core_vectors.txt", "w") as fh:
    for n in lengder:
        x = random.randbytes(n)
        padded = pad(x)
        digest = generate_hash(x)

        for i in range(0, len(padded), 64):
            first = 1 if i == 0 else 0
            last  = 1 if i + 64 >= len(padded) else 0
            fh.write(f"{first} {last} {padded[i:i+64].hex()} {digest.hex()}\n")