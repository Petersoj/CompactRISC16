ADDI    r0,     0
ADDI    r1,     1
ADD     r15,    r0
ADD     r15,    r1
MOV     r2,     r15     # r2 = r1 + r0 = 1
ADD     r14,    r1
ADD     r14,    r2
MOV     r3,     r14     # r3 = r2 + r1 = 2
ADD     r13,    r2
ADD     r13,    r3
MOV     r4,     r13     # r4 = r3 + r2 = 3
ADD     r12,    r3
ADD     r12,    r4
MOV     r5,     r12     # r5 = r4 + r3 = 5
ADD     r11,    r4
ADD     r11,    r5
MOV     r6,     r11     # r6 = r5 + r4 = 8
ADD     r10,    r5
ADD     r10,    r6
MOV     r7,     r10     # r7 = r6 + r5 = 13
ADD     r9,     r6
ADD     r9,     r7
MOV     r8,     r9      # r8 = r7 + r6 = 21
