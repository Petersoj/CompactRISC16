main: ADDI   r0, 0    // r0 = 0
      ADDI   r14, 0   // int i = 0
.L1:  ADDI    r0, 1   // x++
      ADDI    r14, 1  // i++
      CMP     r14, 3  // i - 3, jump if i <= 3.
      MOVIL   r9, 2   // .L1
      JLE     r9
      ADD     r1, r0  // r1 should get final value of x, which is 4
