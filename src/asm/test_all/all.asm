      MOVIL   rsp   0xFF
      MOVIU   rsp   0x03    # initialize stack pointer to 1023
.main
      MOVIL   r0    0     # i
      MOVIU   r0    0
      MOVIL   r1    3     # x
      MOVIU   r1    0
      MOVIL   r2    4     # y
      MOVIU   r2    0
      MOV     r11   r1
      MOV     r12   r2
      CALL    .max(int)$r5
      PUSH    r10   # return value should be 4
      ADDI    r0    1
      MOVIL   r4    0
      MOVIU   r4    0     # j
.L2
      LSHI    r0    1
      ADDI    r4    1
      CMPI    r4    3
      JLT     .L2$r6
      PUSH    r0
      CMPI    r0    8
      JNE     .L1$r7
      MOVIL   r1    0x14    # 20 decimal
      MOVIU   r1    0
.L1
      SUBI    r1    0xA     # 10 decimal, r1 = 10
      MULI    r2    2     # r2 = 8
      PUSH    r1
      STORE   rsp   r2
      SUBI    rsp   1
      JUC     .end$r8
.max(int)
      CMP     r11   r12
      JGE     .L3$r9
      MOV     r10   r12
      RET
      NOP
      NOP
      NOP
      NOP
      NOP
      NOP
      NOP
      NOP
      NOP
      NOP
      NOP
      NOP
      NOP
      NOP
      NOP
      NOP
      NOP
      NOP
      NOP
      NOP
      NOP
      NOP
      NOP
      NOP
      NOP
      NOP
      NOP
      NOP
      NOP
      NOP
      NOP
      NOP
      NOP
      NOP
      NOP
      NOP
      NOP
      NOP
      NOP
      NOP
      NOP
      NOP
      NOP
      NOP
      NOP
      NOP
      NOP
      NOP
      NOP
      NOP
      NOP
      NOP
      NOP
      NOP
      NOP
      NOP
      NOP
      NOP
      NOP
      NOP
      NOP
      NOP
      NOP
      NOP
      NOP
      NOP
      NOP
      NOP
      NOP
      NOP
      NOP
      NOP
      NOP
      NOP
      NOP
      NOP
      NOP
      NOP
      NOP
      NOP
      NOP
      NOP
      NOP
      NOP
      NOP
      NOP
      NOP
      NOP
      NOP
      NOP
      NOP
      NOP
      NOP
      NOP
      NOP
      NOP
      NOP
      NOP
      NOP
      NOP
      NOP
      NOP
      NOP
      NOP
      NOP
      NOP
      NOP
      NOP
      NOP
      NOP
      NOP
      NOP
      NOP
      NOP
      NOP
      NOP
      NOP
      NOP
      NOP
      NOP
      NOP
      NOP
      NOP
      NOP
      NOP
      NOP
      NOP
      NOP
      NOP
      NOP
      NOP
      NOP
      NOP
      NOP
      NOP
      NOP
.L3
      MOV     r10   r11
      RET
.end
      NOP

