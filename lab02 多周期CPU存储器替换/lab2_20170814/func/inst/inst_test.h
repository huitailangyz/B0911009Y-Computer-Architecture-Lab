// file name: inst_test.h

#define LI(reg, imm) \
    lui reg , ((imm>>16) + (imm&0x00008000)>>15)&0x0000ffff; \
    addiu reg, reg, (imm & 0x0000ffff)

#define TEST_LUI(in_a, ref_base) \
    lui   s0, ref_base; \
    lui   t0, in_a;  \
    addu  s0, s0, t1; \
    addu  t1, t1, t2; \
    bne   t0, s0, inst_error; \
    nop

/* 2 */
#define TEST_ADDU(in_a, in_b, ref) \
    LI (t0, in_a); \
    LI (t1, in_b); \
    addu s0, t0, t1; \
    LI (s2, ref); \
    bne s0, s2, inst_error; \
    nop

/* 3 */
#define TEST_ADDIU(in_a, in_b, ref) \
    LI (t0, in_a); \
    addiu s0, t0, in_b; \
    LI (s2, ref); \
    bne s0, s2, inst_error; \
    nop

/* 4 */
#define TEST_BEQ(in_a, in_b, back_flag, front_flag, b_flag_ref, f_flag_ref) \
    LI (t4, back_flag); \
    LI (t5, front_flag); \
    LI (s0, 0x0); \
    LI (s2, 0x0); \
    b 2000f; \
    nop; \
1000:; \
    LI (s0, back_flag); \
    beq t1, t0, 3000f; \
    nop; \
    b 4000f; \
    nop; \
    nop; \
    nop; \
    nop; \
    nop; \
    nop; \
2000:; \
    LI (t0, in_a); \
    LI (t1, in_b); \
    beq t0, t1, 1000b; \
    nop; \
    b 4000f; \
    nop; \
    nop; \
    nop; \
    nop; \
    nop; \
    nop; \
3000:; \
    LI (s2, front_flag); \
4000:; \
    LI (s4, b_flag_ref); \
    bne s0, s4, inst_error; \
    nop; \
    LI (s5, f_flag_ref); \
    bne s2, s5, inst_error; \
    nop

/* 5 */
#define TEST_BNE(in_a, in_b, back_flag, front_flag, b_flag_ref, f_flag_ref) \
    LI (t4, back_flag); \
    LI (t5, front_flag); \
    LI (s0, 0x0); \
    LI (s2, 0x0); \
    b 2000f; \
    nop; \
1000:; \
    LI (s0, back_flag); \
    bne t1, t0, 3000f; \
    nop; \
    b 4000f; \
    nop; \
    nop; \
    nop; \
    nop; \
    nop; \
    nop; \
2000:; \
    LI (t0, in_a); \
    LI (t1, in_b); \
    bne t0, t1, 1000b; \
    nop; \
    b 4000f; \
    nop; \
    nop; \
    nop; \
    nop; \
    nop; \
    nop; \
3000:; \
    LI (s2, front_flag); \
4000:; \
    LI (s4, b_flag_ref); \
    bne s0, s4, inst_error; \
    nop; \
    LI (s5, f_flag_ref); \
    bne s2, s5, inst_error; \
    nop

/* 6 */
#define TEST_LW(data, base_addr, offset, offset_align, ref) \
    LI (t1, data); \
    LI (t0, base_addr); \
    sw t1, offset_align(t0); \
    addiu t0, t0, 4; \
    sw t0, offset_align(t0); \
    addiu t0, t0, -8; \
    sw t0, offset_align(t0); \
    addiu t0, t0, 4; \
    lw s0, offset(t0); \
    LI (s2, ref); \
    bne s0, s2, inst_error; \
    nop

/* 7 */
#define TEST_OR(in_a, in_b, ref) \
    LI (t0, in_a); \
    LI (t1, in_b); \
    or s0, t0, t1; \
    LI (s2, ref); \
    bne s0, s2, inst_error; \
    nop

/* 8 */
#define TEST_SLT(in_a, in_b, ref) \
    LI (t0, in_a); \
    LI (t1, in_b); \
    slt s0, t0, t1; \
    LI (s2, ref); \
    bne s0, s2, inst_error; \
    nop

/* 9 */
#define TEST_SLTI(in_a, in_b, ref) \
    LI (t0, in_a); \
    slti s0, t0, in_b; \
    LI (s2, ref); \
    bne s0, s2, inst_error; \
    nop

/* 10 */
#define TEST_SLTIU(in_a, in_b, ref) \
    LI (t0, in_a); \
    sltiu s0, t0, in_b; \
    LI (s2, ref); \
    bne s0, s2, inst_error; \
    nop

/* 11 */
#define TEST_SLL(in_a, in_b, ref) \
    LI (t0, in_a); \
    sll s0, t0, in_b; \
    LI (s2, ref); \
    bne s0, s2, inst_error; \
    nop

/* 12 */
#define TEST_SW(data, base_addr, offset, offset_align, ref) \
    LI (t1, data); \
    LI (t0, base_addr); \
    sw t1, offset(t0); \
    addiu t0, t0, 4; \
    sw t0, offset(t0); \
    addiu t0, t0, -4; \
    lw s0, offset_align(t0); \
    LI (s2, ref); \
    bne s0, s2, inst_error; \
    nop

/* 13 */
#define TEST_J(back_flag, front_flag, b_flag_ref, f_flag_ref) \
    LI (t4, back_flag); \
    LI (t5, front_flag); \
    LI (s0, 0x0); \
    LI (s2, 0x0); \
    b 2000f; \
    nop; \
1000:; \
    LI (s0, back_flag); \
    j 3000f; \
    nop; \
    b 4000f; \
    nop; \
    nop; \
    nop; \
    nop; \
    nop; \
    nop; \
2000:; \
    j 1000b; \
    nop; \
    b 4000f; \
    nop; \
    nop; \
    nop; \
    nop; \
    nop; \
    nop; \
3000:; \
    LI (s2, front_flag); \
4000:; \
    LI (s4, b_flag_ref); \
    bne s0, s4, inst_error; \
    nop; \
    LI (s5, f_flag_ref); \
    bne s2, s5, inst_error; \
    nop

/* 14 */
#define TEST_JAL(back_flag, front_flag, b_flag_ref, f_flag_ref) \
    addu s6, zero, $31; \
    LI (t4, back_flag); \
    LI (t5, front_flag); \
    LI (s0, 0x0); \
    LI (s2, 0x0); \
    b 2000f; \
    nop; \
1000:; \
    LI (s0, back_flag); \
1001:; \
    jal 3000f; \
    nop; \
    b 4000f; \
    nop; \
    nop; \
    nop; \
    nop; \
    nop; \
    nop; \
2000:; \
    jal 1000b; \
    nop; \
    b 4000f; \
    nop; \
    nop; \
    nop; \
    nop; \
    nop; \
    nop; \
3000:; \
    LI (s2, front_flag); \
4000:; \
    addu s4, zero, $31; \
    addu $31, zero, s6; \
    la s5, 1001b; \
    LI (t5, b_flag_ref); \
    bne s0, t5, inst_error; \
    nop; \
    LI (t4, f_flag_ref); \
    bne s2, t4, inst_error; \
    nop; \
    addiu s5, s5, 8; \
    bne s4, s5, inst_error; \
    nop

/* 15 */
#define TEST_JR(back_flag, front_flag, b_flag_ref, f_flag_ref) \
    LI (t4, back_flag); \
    LI (t5, front_flag); \
    LI (s0, 0x0); \
    LI (s2, 0x0); \
    la t0, 1000f; \
    la t1, 3000f; \
    b 2000f; \
    nop; \
1000:; \
    LI (s0, back_flag); \
    jr t1; \
    nop; \
    b 4000f; \
    nop; \
    nop; \
    nop; \
    nop; \
    nop; \
    nop; \
2000:; \
    jr t0; \
    nop; \
    b 4000f; \
    nop; \
    nop; \
    nop; \
    nop; \
    nop; \
    nop; \
3000:; \
    LI (s2, front_flag); \
4000:; \
    LI (s4, b_flag_ref); \
    bne s0, s4, inst_error; \
    nop; \
    LI (s5, f_flag_ref); \
    bne s2, s5, inst_error; \
    nop
