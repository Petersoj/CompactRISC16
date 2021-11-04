ADDI    r0,     0
ADDI    r1,     1
ADD     r15,    r0
ADD     r15,    r1
STORE   32,     r15
LOAD    r2,     32      # r2 = r1 + r0 = 1
ADD     r14,    r1
ADD     r14,    r2
STORE   33,     r14
LOAD    r3,     33      # r3 = r2 + r1 = 2
ADD     r13,    r2
ADD     r13,    r3
STORE   34,     r13
LOAD    r4,     34      # r4 = r3 + r2 = 3
ADD     r12,    r3
ADD     r12,    r4
STORE   35,     r12
LOAD    r5,     35      # r5 = r4 + r3 = 5
ADD     r11,    r4
ADD     r11,    r5
STORE   36,     r11
LOAD    r6,     36      # r6 = r5 + r4 = 8
ADD     r10,    r5
ADD     r10,    r6
STORE   37,     r10
LOAD    r7,     37      # r7 = r6 + r5 = 13
ADD     r9,     r6
ADD     r9,     r7
STORE   38,     r9
LOAD    r8,     38      # r8 = r7 + r6 = 21
