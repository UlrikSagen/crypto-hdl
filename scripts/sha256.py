

#Constants declaration

#Array or rounds constants
K = [
0x428a2f98, 0x71374491, 0xb5c0fbcf, 0xe9b5dba5, 0x3956c25b, 0x59f111f1, 0x923f82a4, 0xab1c5ed5,
0xd807aa98, 0x12835b01, 0x243185be, 0x550c7dc3, 0x72be5d74, 0x80deb1fe, 0x9bdc06a7, 0xc19bf174,
0xe49b69c1, 0xefbe4786, 0x0fc19dc6, 0x240ca1cc, 0x2de92c6f, 0x4a7484aa, 0x5cb0a9dc, 0x76f988da,
0x983e5152, 0xa831c66d, 0xb00327c8, 0xbf597fc7, 0xc6e00bf3, 0xd5a79147, 0x06ca6351, 0x14292967,
0x27b70a85, 0x2e1b2138, 0x4d2c6dfc, 0x53380d13, 0x650a7354, 0x766a0abb, 0x81c2c92e, 0x92722c85,
0xa2bfe8a1, 0xa81a664b, 0xc24b8b70, 0xc76c51a3, 0xd192e819, 0xd6990624, 0xf40e3585, 0x106aa070,
0x19a4c116, 0x1e376c08, 0x2748774c, 0x34b0bcb5, 0x391c0cb3, 0x4ed8aa4a, 0x5b9cca4f, 0x682e6ff3,
0x748f82ee, 0x78a5636f, 0x84c87814, 0x8cc70208, 0x90befffa, 0xa4506ceb, 0xbef9a3f7, 0xc67178f2
]

def generate_hash(input_message, trace = False):

    if isinstance(input_message, (bytes, bytearray)):
        message = bytearray(input_message)
    else:
        raise TypeError(
            f"forventet bytes eller bytearray, fikk {type(input_message).__name__}"
            " — strenger må kodes først, f.eks. s.encode('utf-8')"
        )

    #Padding
    length = len(message) * 8
    message.append(0x80)
    while(len(message) * 8 + 64) % 512 != 0:
        message.append(0x00)

    message += length.to_bytes(8, 'big')

    #Process message into 512-bit(64 bytes) chunks
    blocks = []
    for i in range(0, len(message), 64):
        blocks.append(message[i:i+64])

    #Initial hash values
    h0 = 0x6a09e667
    h1 = 0xbb67ae85
    h2 = 0x3c6ef372
    h3 = 0xa54ff53a
    h4 = 0x510e527f
    h5 = 0x9b05688c
    h6 = 0x1f83d9ab
    h7 = 0x5be0cd19

    for message_block in blocks:
        w = [0] * 64

        #Device each block in to 32 bit words
        for i in range(16):
            w[i] = int.from_bytes(message_block[i*4:(i+1)*4], 'big')

        for i in range(16, 64):

            t1 = sigma1(w[i-2])
            t2 = w[i-7]
            t3 = sigma0(w[i-15])
            t4 = w[i-16]

            w[i] = (t1 + t2 + t3 + t4) % 2**32

        a = h0
        b = h1
        c = h2
        d = h3
        e = h4
        f = h5
        g = h6
        h = h7    

        for t in range(0, 64):

            T1 = (h + capsigma1(e) + ch(e, f, g) + K[t] + w[t]) % 2**32
            T2 = (capsigma0(a) + maj(a, b, c)) % 2**32

            h = g
            g = f
            f = e
            e = (d + T1) % 2**32
            d = c
            c = b
            b = a
            a = (T1 + T2) % 2**32

            if trace:
                print(f"t={t:2d} {a:08x} {b:08x} {c:08x} {d:08x} "
                      f"{e:08x} {f:08x} {g:08x} {h:08x}")

        h0 = (h0 + a) % 2**32
        h1 = (h1 + b) % 2**32
        h2 = (h2 + c) % 2**32
        h3 = (h3 + d) % 2**32
        h4 = (h4 + e) % 2**32
        h5 = (h5 + f) % 2**32
        h6 = (h6 + g) % 2**32
        h7 = (h7 + h) % 2**32

    return ((h0).to_bytes(4, 'big') + (h1).to_bytes(4, 'big') +
            (h2).to_bytes(4, 'big') + (h3).to_bytes(4, 'big') +
            (h4).to_bytes(4, 'big') + (h5).to_bytes(4, 'big') +
            (h6).to_bytes(4, 'big') + (h7).to_bytes(4, 'big'))

            

def sigma0(num):
    return(rotate(num, 7) ^ rotate(num, 18) ^ num >> 3)

def sigma1(num):
    return(rotate(num, 17) ^ rotate(num, 19) ^ num >> 10)

def capsigma0(num):
    return(rotate(num, 2) ^ rotate(num, 13) ^ rotate(num, 22))

def capsigma1(num):
    return(rotate(num, 6) ^ rotate(num, 11) ^ rotate(num, 25))

def ch(x, y, z):
    return((x & y) ^ (~x & z))

def maj(x, y, z):
    return((x & y) ^ (x & z) ^ (y & z))

def rotate(num, shift):
    return (((num >> shift) | (num << (32 - shift))) & 0xFFFFFFFF)