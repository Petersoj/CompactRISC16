       MOVIL  r8, 48  // Frame pointer = 48
.main: MOVIU  r0, 0x80   // Upper of 32768 is 1000_0000 or 0x80
       MOVIL  r0, 0x00   // Lower of 32768 is 0000_0000 or 0x00  r0 = 32,768
       MOVIU  r1, 0x7f   // Upper of 32763 is 0111_1111 or 0x7f
       MOVIL  r1, 0xfd   // Lower of 32763 is 1111_1011 or 0xfb  r1 = 32,766
       MOVIL  r9, 8     // .L1
       JUC    r9
.L2:   ADDI   r1, 1      // r1++
.L1:   MOVIL  r10, 7     // .L2
       CMP    r1, r0     // r1 < r0
       JLO    r10
       CMP    r1, r0     // r1 == r0