import random
from sha256 import pad, generate_hash

random.seed(42)

lengder = [0, 55, 56, 64, 119, 120] + [random.randint(0, 256) for _ in range(512)]

KEEP = {0 : "0", 1 : "8", 2 : "c", 3 : "e", 4 : "f"}

with open("vectors/sha256_pad_input_vectors.txt", "w") as fi, \
     open("vectors/sha256_pad_output_vectors.txt", "w") as fo:
    for n in lengder:
        x = random.randbytes(n)
        digest = generate_hash(x)
        padded = pad(x)
        if(len(x) == 0):
            fi.write(f"{KEEP[0]} 1 00000000\n")
        for i in range(0, len(x), 4):
            chunk = x[i:i+4]
            word = chunk.ljust(4, b"\x00")
            tkeep = KEEP[len(chunk)]
            tlast = 1 if i + 4 >= len(x) else 0
            fi.write(f"{tkeep} {tlast} {word.hex()}\n")
        for i in range (0, len(padded), 64):
            first = 1 if i == 0 else 0
            last  = 1 if i + 64 >= len(padded) else 0
            fo.write(f"{first} {last} {padded[i:i+64].hex()}\n")
