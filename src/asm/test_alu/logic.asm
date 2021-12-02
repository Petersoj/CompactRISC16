ADDI  r3  15     // Load 000F into r3
ADDI  r4  240    // Load FFF0 into r4
OR    r3  r4     // r3 gets FFFF
ANDI  r3  42     // r3 gets 002A
AND   r3  r4     // r3 gets 0020
NOT   r4  r4     // r4 gets 000F
LSHI  r4  4      // r4 gets 00F0
ADDI  r5  2      // r5 gets 0002
RSH   r4  r5     // r4 gets 003C
ARSHI r4  4      // r4 gets 0003
ALSH  r4  r5     // r4 gets 000C
