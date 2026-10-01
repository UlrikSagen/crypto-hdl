# crypto-hdl

Kryptografiske primitiver implementert fra bunnen av i VHDL, for å forstå algoritmene på registernivå i stedet for å bruke ferdige IP-kjerner.

**Status:** SHA-256 (FIPS 180-4) er fullt implementert og verifisert. SHA-512-familien, ChaCha20 og AES er planlagt.

## Høydepunkter

- **Strømbasert SHA-256** med AXI-stream-lignende grensesnitt (`tdata/tvalid/tready/tlast/tkeep`), ett 32-bits ord per klokkesykel
- **Padding som tilstandsmaskin** som håndterer alle kantfellene i FIPS 180-4: tom melding, melding som fyller nøyaktig én blokk, og melding der lengdefeltet ikke får plass i siste blokk
- **Flerblokks kjeding** (Merkle–Damgård) og on-the-fly message schedule, 65 klokkesykler per blokk
- **Verifikasjon mot én kilde:** En Python-referansemodell er verifisert mot offisielle NIST CAVP-vektorer, og all VHDL testes mot vektorer generert fra samme modell

## Arkitektur

```
32-bits ord/sykel → sha256_pad (FSM) → 512-bit blokk → sha256_core (FSM) → 256-bit digest
```

| Modul | Rolle |
|-------|-------|
| `sha256_pkg` | Konstanter (K, H_INIT) og rene funksjoner (`ch`, `maj`, `sigma`, `rotr`) |
| `sha256_core` | Kompresjonsfunksjonen: `IDLE → ROUND (64 runder) → FINAL` |
| `sha256_pad` | Strømbasert padding: `IDLE → PADDING → EMIT → (EXTRA)` |
| `scripts/sha256.py` | Python-referansemodell, brukt som testorakel |

## Verifikasjonsmetodikk

1. Python-modellen skrives først og verifiseres mot NIST CAVP SHAVS (ShortMsg, LongMsg og Monte Carlo)
2. Testvektorer genereres fra modellen, med lengder valgt for å treffe padding-kantfellene (0, 55, 56, 64, 119, 120) pluss 512 tilfeldige lengder
3. Hver VHDL-modul testes mot vektorene med VUnit og GHDL

Feil kan dermed alltid isoleres til enten modellen eller porteringen, aldri begge samtidig.

## Kom i gang

Krever GHDL, VUnit og Python 3 (for eksempel via OSS CAD Suite).

```bash
# Verifiser Python-referansen mot NIST-vektorer
python scripts/test_vectors.py

# Generer testvektorer for VHDL
python scripts/gen_sha256_pkg_vectors.py
python scripts/gen_sha256_core_vectors.py
python scripts/gen_sha256_pad_vectors.py

# Kjør alle testbenker
python run.py
```

## TODO

- [ ] Ende-til-ende-testbenk som kobler `sha256_pad` direkte til `sha256_core`
- [ ] Toppnivå-wrapper som gjenbrukbar enhet
- [ ] Syntese og ressursrapport for en reell FPGA
- [ ] SHA-512-familien
- [ ] ChaCha20 (RFC 8439)
- [ ] AES (FIPS 197)
