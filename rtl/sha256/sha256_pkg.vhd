library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package sha256_pkg is
    type k_array_t is array (0 to 63) of unsigned(31 downto 0);
    constant K : k_array_t;
    function ch(x, y, z : unsigned(31 downto 0)) return unsigned;
    function maj(x, y, z : unsigned(31 downto 0)) return unsigned;
    function sigma0(x : unsigned(31 downto 0)) return unsigned;
    function sigma1(x : unsigned(31 downto 0)) return unsigned;
    function capsigma0(x : unsigned(31 downto 0)) return unsigned;
    function capsigma1(x : unsigned(31 downto 0)) return unsigned;
    function rotr(x : unsigned(31 downto 0); n: natural) return unsigned;
end package;

package body sha256_pkg is

    constant K : k_array_t := (
        x"428a2f98", x"71374491", x"b5c0fbcf", x"e9b5dba5", x"3956c25b", x"59f111f1", x"923f82a4", x"ab1c5ed5",
        x"d807aa98", x"12835b01", x"243185be", x"550c7dc3", x"72be5d74", x"80deb1fe", x"9bdc06a7", x"c19bf174",
        x"e49b69c1", x"efbe4786", x"0fc19dc6", x"240ca1cc", x"2de92c6f", x"4a7484aa", x"5cb0a9dc", x"76f988da",
        x"983e5152", x"a831c66d", x"b00327c8", x"bf597fc7", x"c6e00bf3", x"d5a79147", x"06ca6351", x"14292967",
        x"27b70a85", x"2e1b2138", x"4d2c6dfc", x"53380d13", x"650a7354", x"766a0abb", x"81c2c92e", x"92722c85",
        x"a2bfe8a1", x"a81a664b", x"c24b8b70", x"c76c51a3", x"d192e819", x"d6990624", x"f40e3585", x"106aa070",
        x"19a4c116", x"1e376c08", x"2748774c", x"34b0bcb5", x"391c0cb3", x"4ed8aa4a", x"5b9cca4f", x"682e6ff3",
        x"748f82ee", x"78a5636f", x"84c87814", x"8cc70208", x"90befffa", x"a4506ceb", x"bef9a3f7", x"c67178f2"
        );

    function ch(x, y, z : unsigned(31 downto 0)) return unsigned is
    begin
        return (x and y) xor (not x and z);
    end function;

    function maj(x, y, z : unsigned(31 downto 0)) return unsigned is
    begin
        return (x and y) xor (x and z) xor (y and z);
    end function;

    function sigma0(x : unsigned(31 downto 0)) return unsigned is
    begin
        return rotr(x, 7) xor rotr(x, 18) xor shift_right(x, 3);
    end function;

    function sigma1(x : unsigned(31 downto 0)) return unsigned is
    begin
        return rotr(x, 17) xor rotr(x, 19) xor shift_right(x, 10);
    end function;

    function capsigma0(x : unsigned(31 downto 0)) return unsigned is
    begin
        return rotr(x, 2) xor rotr(x, 13) xor rotr(x, 22);
    end function;

    function capsigma1(x : unsigned(31 downto 0)) return unsigned is
    begin
        return rotr(x, 6) xor rotr(x, 11) xor rotr(x, 25);
    end function;

    function rotr(x : unsigned(31 downto 0); n: natural) return unsigned is
        variable r : unsigned(31 downto 0);
    begin
        r := x(n - 1 downto 0) & x(31 downto n);
        return r;
    end function;

    
end package body;
