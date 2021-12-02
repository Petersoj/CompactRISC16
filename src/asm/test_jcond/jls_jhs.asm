    MOVIL  r8  48  # Frame pointer = 48
.main
    MOVIU  r0  0x80   # Upper of 32768 is 1000_0000 or 0x80
    MOVIL  r0  0x00   # Lower of 32768 is 0000_0000 or 0x00  r0 = 32,768
    MOVIU  r1  0x7f   # Upper of 32763 is 0111_1111 or 0x7f
    MOVIL  r1  0xfb   # Lower of 32763 is 1111_1011 or 0xfb  r1 = 32,763
    MOVIU  r2  0x7f   # Upper of 32763 is 0111_1111 or 0x7f
    MOVIL  r2  0xfb   # Lower of 32763 is 1111_1011 or 0xfb  r2 = 32,763
    MOVIL  r9  10     # .L1
    JUC    r9
.L2
    ADDI   r1  1      # r1++
.L1
    CMP    r1  r0     # r1 <= r0
    MOVIL  r10 9      # .L2
    JLS    r10
    MOVIL  r11 16     # .L3
    JUC    r11
.L4
    SUBI   r1  1      # r1--
.L3
    CMP    r1  r2     # r1 >= r2
    MOVIL  r12 15     # .L4
    JHS    r12
    STORE  r8  r1     # r1 is at the initial address of the frame pointer. r1 = 0x7ffa
