library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library crypto;
use crypto.sha256_pkg.all;

entity sha256_core is
    port (
        clk : in std_logic;
        rst : in std_logic;
        start : in std_logic;
        first : in std_logic;
        block_in : in unsigned(511 downto 0);
        done : out std_logic;
        busy : out std_logic;
        digest : out unsigned(255 downto 0)
    );
end entity;

architecture rtl of sha256_core is

    type state_t is (IDLE, ROUND, FINAL);
    signal state : state_t := IDLE;

    signal t : natural range 0 to 63 := 0;

    type w_array_t is array (0 to 63) of unsigned(31 downto 0);
    signal w : w_array_t := (others => (others => '0'));

    signal a, b, c, d, e, f, g, h : unsigned(31 downto 0) := (others => '0');

    signal h0, h1, h2, h3 : unsigned(31 downto 0) := (others => '0');
    signal h4, h5, h6, h7 : unsigned(31 downto 0) := (others => '0');

begin
    process(clk)
        variable T1, T2 : unsigned(31 downto 0);
        variable curr_w : unsigned(31 downto 0);
    begin
        if rising_edge(clk) then
            if rst = '1' then
                state <= IDLE;
                done <= '0';
                busy <= '0';
            else
                case state is
                    when IDLE =>
                        if start = '1' then

                            for i in 0 to 15 loop
                                w(i) <= block_in(511 - i*32 downto 480 - i*32);
                            end loop;

                            if first = '1' then
                                a <= H_INIT(0); b <= H_INIT(1); c <= H_INIT(2); d <= H_INIT(3);
                                e <= H_INIT(4); f <= H_INIT(5); g <= H_INIT(6); h <= H_INIT(7);
                                h0 <= H_INIT(0); h1 <= H_INIT(1); h2 <= H_INIT(2); h3 <= H_INIT(3);
                                h4 <= H_INIT(4); h5 <= H_INIT(5); h6 <= H_INIT(6); h7 <= H_INIT(7);
                            else
                                a <= h0; b <= h1; c <= h2; d <= h3;
                                e <= h4; f <= h5; g <= h6; h <= h7;
                            end if;

                            t <= 0;
                            busy <= '1';
                            state <= ROUND;

                        end if;
                    when ROUND =>
                        if t >= 16 then
                            w(t) <= sigma1(w(t-2)) + w(t-7) + sigma0(w(t-15)) + w(t-16);
                            curr_w := sigma1(w(t-2)) + w(t-7) + sigma0(w(t-15)) + w(t-16);
                        else
                            curr_w := w(t);
                        end if;
                        
                        T1 := h + capsigma1(e) + ch(e, f, g) + K(t) + curr_w;
                        T2 := capsigma0(a) + maj(a, b, c);

                        h <= g;
                        g <= f;
                        f <= e;
                        e <= d + T1;
                        d <= c;
                        c <= b;
                        b <= a;
                        a <= T1 + T2;

                        if t = 63 then
                            state <= FINAL;
                        else
                            t <= t + 1;
                        end if;
                    
                    when FINAL =>
                        h0 <= h0 + a; h1 <= h1 + b; h2 <= h2 + c; h3 <= h3 + d;
                        h4 <= h4 + e; h5 <= h5 + f; h6 <= h6 + g; h7 <= h7 + h;

                        done <= '1';
                        busy <= '0';
                        state <= IDLE;
                end case;
            end if;
        end if;
    end process;

    digest <= (h0 & h1 & h2 & h3 & h4 & h5 & h6 & h7);

end architecture;