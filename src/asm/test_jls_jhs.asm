     MOVIL  r8, 48  // Frame pointer = 48
main:
     MOVIU  r0, 0x80   // Upper of 32768 is 1000_0000 or 0x80
     MOVIL  r0, 0x00   // Lower of 32768 is 0000_0000 or 0x00  x = 32,768
     MOVIU  r1, 0xff   // Upper of 32763 is 1111_1111 or 0xff
     MOVIL  r1, 0xfb   // Lower of 32763 is 1111_1011 or 0xfb  y = 32,763
     MOVIU  r2, 0xff   // Upper of 32763 is 1111_1111 or 0xff
     MOVIL  r2, 0xfb   // Lower of 32763 is 1111_1011 or 0xfb  z = 32,763
     JUC    .L1
.L2:
     ADDI   r1, 1      // y++
.L1
     CMP    r1, r0     // y <= x
     JLS    .L2
     JUC    .L3
.L4
     SUBI   r1, 1      // y--
.L3
     CMP    r1, r2     // y >= z
     JHS    .L4
     STORE  r8, r1     // y is at the initial address of the frame pointer. y = 0xfffb