; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc %s -o - -enable-shrink-wrap=true | FileCheck %s --check-prefix=ENABLE
; RUN: llc %s -o - -enable-shrink-wrap=false | FileCheck %s --check-prefix=DISABLE
; We cannot merge this test with the main test for shrink-wrapping, because
; the code path we want to exerce is not taken with ios lowering.
target datalayout = "e-m:e-p:32:32-i64:64-v128:64:128-a:0:32-n8:16:32-S64"
target triple = "armv7--linux-gnueabi"

@skip = internal unnamed_addr constant [2 x i8] c"\01\01", align 1

; Check that we do not restore the before having used the saved CSRs.
; This happened because of a bad use of the post-dominance property.
; The exit block of the loop happens to also lead to defs/uses of CSRs.
; It also post-dominates the loop body and we use to generate invalid
; restore sequence. I.e., we restored too early.

define fastcc i8* @wrongUseOfPostDominate(i8* readonly %s, i32 %off, i8* readnone %lim) {
; ENABLE-LABEL: wrongUseOfPostDominate:
; ENABLE:       @ %bb.0: @ %entry
; ENABLE-NEXT:    .save {r11, lr}
; ENABLE-NEXT:    push {r11, lr}
; ENABLE-NEXT:    cmn r1, #1
; ENABLE-NEXT:    ble .LBB0_6
; ENABLE-NEXT:  @ %bb.1: @ %while.cond.preheader
; ENABLE-NEXT:    cmp r1, #0
; ENABLE-NEXT:    beq .LBB0_5
; ENABLE-NEXT:  @ %bb.2: @ %while.cond.preheader
; ENABLE-NEXT:    cmp r0, r2
; ENABLE-NEXT:    pophs {r11, pc}
; ENABLE-NEXT:    movw r12, :lower16:skip
; ENABLE-NEXT:    sub r1, r1, #1
; ENABLE-NEXT:    movt r12, :upper16:skip
; ENABLE-NEXT:  .LBB0_3: @ %while.body
; ENABLE-NEXT:    @ =>This Inner Loop Header: Depth=1
; ENABLE-NEXT:    ldrb r3, [r0]
; ENABLE-NEXT:    ldrb r3, [r12, r3]
; ENABLE-NEXT:    add r0, r0, r3
; ENABLE-NEXT:    sub r3, r1, #1
; ENABLE-NEXT:    cmp r3, r1
; ENABLE-NEXT:    bhs .LBB0_5
; ENABLE-NEXT:  @ %bb.4: @ %while.body
; ENABLE-NEXT:    @ in Loop: Header=BB0_3 Depth=1
; ENABLE-NEXT:    cmp r0, r2
; ENABLE-NEXT:    mov r1, r3
; ENABLE-NEXT:    blo .LBB0_3
; ENABLE-NEXT:  .LBB0_5: @ %if.end29
; ENABLE-NEXT:    pop {r11, pc}
; ENABLE-NEXT:  .LBB0_6: @ %while.cond2.outer
; ENABLE-NEXT:    @ =>This Loop Header: Depth=1
; ENABLE-NEXT:    @ Child Loop BB0_7 Depth 2
; ENABLE-NEXT:    @ Child Loop BB0_14 Depth 2
; ENABLE-NEXT:    mov r3, r0
; ENABLE-NEXT:  .LBB0_7: @ %while.cond2
; ENABLE-NEXT:    @ Parent Loop BB0_6 Depth=1
; ENABLE-NEXT:    @ => This Inner Loop Header: Depth=2
; ENABLE-NEXT:    add r1, r1, #1
; ENABLE-NEXT:    cmp r1, #1
; ENABLE-NEXT:    beq .LBB0_17
; ENABLE-NEXT:  @ %bb.8: @ %while.body4
; ENABLE-NEXT:    @ in Loop: Header=BB0_7 Depth=2
; ENABLE-NEXT:    cmp r3, r2
; ENABLE-NEXT:    bls .LBB0_7
; ENABLE-NEXT:  @ %bb.9: @ %if.then7
; ENABLE-NEXT:    @ in Loop: Header=BB0_6 Depth=1
; ENABLE-NEXT:    mov r0, r3
; ENABLE-NEXT:    ldrb r12, [r0, #-1]!
; ENABLE-NEXT:    sxtb lr, r12
; ENABLE-NEXT:    cmn lr, #1
; ENABLE-NEXT:    bgt .LBB0_6
; ENABLE-NEXT:  @ %bb.10: @ %if.then7
; ENABLE-NEXT:    @ in Loop: Header=BB0_6 Depth=1
; ENABLE-NEXT:    cmp r0, r2
; ENABLE-NEXT:    bls .LBB0_6
; ENABLE-NEXT:  @ %bb.11: @ %land.rhs14.preheader
; ENABLE-NEXT:    @ in Loop: Header=BB0_6 Depth=1
; ENABLE-NEXT:    cmn lr, #1
; ENABLE-NEXT:    bgt .LBB0_6
; ENABLE-NEXT:  @ %bb.12: @ %land.rhs14.preheader
; ENABLE-NEXT:    @ in Loop: Header=BB0_6 Depth=1
; ENABLE-NEXT:    cmp r12, #191
; ENABLE-NEXT:    bhi .LBB0_6
; ENABLE-NEXT:  @ %bb.13: @ %while.body24.preheader
; ENABLE-NEXT:    @ in Loop: Header=BB0_6 Depth=1
; ENABLE-NEXT:    sub r3, r3, #2
; ENABLE-NEXT:  .LBB0_14: @ %while.body24
; ENABLE-NEXT:    @ Parent Loop BB0_6 Depth=1
; ENABLE-NEXT:    @ => This Inner Loop Header: Depth=2
; ENABLE-NEXT:    mov r0, r3
; ENABLE-NEXT:    cmp r3, r2
; ENABLE-NEXT:    bls .LBB0_6
; ENABLE-NEXT:  @ %bb.15: @ %while.body24.land.rhs14_crit_edge
; ENABLE-NEXT:    @ in Loop: Header=BB0_14 Depth=2
; ENABLE-NEXT:    mov r3, r0
; ENABLE-NEXT:    ldrsb lr, [r3], #-1
; ENABLE-NEXT:    cmn lr, #1
; ENABLE-NEXT:    uxtb r12, lr
; ENABLE-NEXT:    bgt .LBB0_6
; ENABLE-NEXT:  @ %bb.16: @ %while.body24.land.rhs14_crit_edge
; ENABLE-NEXT:    @ in Loop: Header=BB0_14 Depth=2
; ENABLE-NEXT:    cmp r12, #192
; ENABLE-NEXT:    blo .LBB0_14
; ENABLE-NEXT:    b .LBB0_6
; ENABLE-NEXT:  .LBB0_17:
; ENABLE-NEXT:    mov r0, r3
; ENABLE-NEXT:    pop {r11, pc}
;
; DISABLE-LABEL: wrongUseOfPostDominate:
; DISABLE:       @ %bb.0: @ %entry
; DISABLE-NEXT:    .save {r11, lr}
; DISABLE-NEXT:    push {r11, lr}
; DISABLE-NEXT:    cmn r1, #1
; DISABLE-NEXT:    ble .LBB0_6
; DISABLE-NEXT:  @ %bb.1: @ %while.cond.preheader
; DISABLE-NEXT:    cmp r1, #0
; DISABLE-NEXT:    beq .LBB0_5
; DISABLE-NEXT:  @ %bb.2: @ %while.cond.preheader
; DISABLE-NEXT:    cmp r0, r2
; DISABLE-NEXT:    pophs {r11, pc}
; DISABLE-NEXT:    movw r12, :lower16:skip
; DISABLE-NEXT:    sub r1, r1, #1
; DISABLE-NEXT:    movt r12, :upper16:skip
; DISABLE-NEXT:  .LBB0_3: @ %while.body
; DISABLE-NEXT:    @ =>This Inner Loop Header: Depth=1
; DISABLE-NEXT:    ldrb r3, [r0]
; DISABLE-NEXT:    ldrb r3, [r12, r3]
; DISABLE-NEXT:    add r0, r0, r3
; DISABLE-NEXT:    sub r3, r1, #1
; DISABLE-NEXT:    cmp r3, r1
; DISABLE-NEXT:    bhs .LBB0_5
; DISABLE-NEXT:  @ %bb.4: @ %while.body
; DISABLE-NEXT:    @ in Loop: Header=BB0_3 Depth=1
; DISABLE-NEXT:    cmp r0, r2
; DISABLE-NEXT:    mov r1, r3
; DISABLE-NEXT:    blo .LBB0_3
; DISABLE-NEXT:  .LBB0_5: @ %if.end29
; DISABLE-NEXT:    pop {r11, pc}
; DISABLE-NEXT:  .LBB0_6: @ %while.cond2.outer
; DISABLE-NEXT:    @ =>This Loop Header: Depth=1
; DISABLE-NEXT:    @ Child Loop BB0_7 Depth 2
; DISABLE-NEXT:    @ Child Loop BB0_14 Depth 2
; DISABLE-NEXT:    mov r3, r0
; DISABLE-NEXT:  .LBB0_7: @ %while.cond2
; DISABLE-NEXT:    @ Parent Loop BB0_6 Depth=1
; DISABLE-NEXT:    @ => This Inner Loop Header: Depth=2
; DISABLE-NEXT:    add r1, r1, #1
; DISABLE-NEXT:    cmp r1, #1
; DISABLE-NEXT:    beq .LBB0_17
; DISABLE-NEXT:  @ %bb.8: @ %while.body4
; DISABLE-NEXT:    @ in Loop: Header=BB0_7 Depth=2
; DISABLE-NEXT:    cmp r3, r2
; DISABLE-NEXT:    bls .LBB0_7
; DISABLE-NEXT:  @ %bb.9: @ %if.then7
; DISABLE-NEXT:    @ in Loop: Header=BB0_6 Depth=1
; DISABLE-NEXT:    mov r0, r3
; DISABLE-NEXT:    ldrb r12, [r0, #-1]!
; DISABLE-NEXT:    sxtb lr, r12
; DISABLE-NEXT:    cmn lr, #1
; DISABLE-NEXT:    bgt .LBB0_6
; DISABLE-NEXT:  @ %bb.10: @ %if.then7
; DISABLE-NEXT:    @ in Loop: Header=BB0_6 Depth=1
; DISABLE-NEXT:    cmp r0, r2
; DISABLE-NEXT:    bls .LBB0_6
; DISABLE-NEXT:  @ %bb.11: @ %land.rhs14.preheader
; DISABLE-NEXT:    @ in Loop: Header=BB0_6 Depth=1
; DISABLE-NEXT:    cmn lr, #1
; DISABLE-NEXT:    bgt .LBB0_6
; DISABLE-NEXT:  @ %bb.12: @ %land.rhs14.preheader
; DISABLE-NEXT:    @ in Loop: Header=BB0_6 Depth=1
; DISABLE-NEXT:    cmp r12, #191
; DISABLE-NEXT:    bhi .LBB0_6
; DISABLE-NEXT:  @ %bb.13: @ %while.body24.preheader
; DISABLE-NEXT:    @ in Loop: Header=BB0_6 Depth=1
; DISABLE-NEXT:    sub r3, r3, #2
; DISABLE-NEXT:  .LBB0_14: @ %while.body24
; DISABLE-NEXT:    @ Parent Loop BB0_6 Depth=1
; DISABLE-NEXT:    @ => This Inner Loop Header: Depth=2
; DISABLE-NEXT:    mov r0, r3
; DISABLE-NEXT:    cmp r3, r2
; DISABLE-NEXT:    bls .LBB0_6
; DISABLE-NEXT:  @ %bb.15: @ %while.body24.land.rhs14_crit_edge
; DISABLE-NEXT:    @ in Loop: Header=BB0_14 Depth=2
; DISABLE-NEXT:    mov r3, r0
; DISABLE-NEXT:    ldrsb lr, [r3], #-1
; DISABLE-NEXT:    cmn lr, #1
; DISABLE-NEXT:    uxtb r12, lr
; DISABLE-NEXT:    bgt .LBB0_6
; DISABLE-NEXT:  @ %bb.16: @ %while.body24.land.rhs14_crit_edge
; DISABLE-NEXT:    @ in Loop: Header=BB0_14 Depth=2
; DISABLE-NEXT:    cmp r12, #192
; DISABLE-NEXT:    blo .LBB0_14
; DISABLE-NEXT:    b .LBB0_6
; DISABLE-NEXT:  .LBB0_17:
; DISABLE-NEXT:    mov r0, r3
; DISABLE-NEXT:    pop {r11, pc}
entry:
  %cmp = icmp sgt i32 %off, -1
  br i1 %cmp, label %while.cond.preheader, label %while.cond2.outer

while.cond.preheader:                             ; preds = %entry
  %tobool4 = icmp ne i32 %off, 0
  %cmp15 = icmp ult i8* %s, %lim
  %sel66 = and i1 %tobool4, %cmp15
  br i1 %sel66, label %while.body, label %if.end29

while.body:                                       ; preds = %while.body, %while.cond.preheader
  %s.addr.08 = phi i8* [ %add.ptr, %while.body ], [ %s, %while.cond.preheader ]
  %off.addr.07 = phi i32 [ %dec, %while.body ], [ %off, %while.cond.preheader ]
  %dec = add nsw i32 %off.addr.07, -1
  %tmp = load i8, i8* %s.addr.08, align 1, !tbaa !2
  %idxprom = zext i8 %tmp to i32
  %arrayidx = getelementptr inbounds [2 x i8], [2 x i8]* @skip, i32 0, i32 %idxprom
  %tmp1 = load i8, i8* %arrayidx, align 1, !tbaa !2
  %conv = zext i8 %tmp1 to i32
  %add.ptr = getelementptr inbounds i8, i8* %s.addr.08, i32 %conv
  %tobool = icmp ne i32 %off.addr.07, 1
  %cmp1 = icmp ult i8* %add.ptr, %lim
  %sel6 = and i1 %tobool, %cmp1
  br i1 %sel6, label %while.body, label %if.end29

while.cond2.outer:                                ; preds = %while.body24.land.rhs14_crit_edge, %while.body24, %land.rhs14.preheader, %if.then7, %entry
  %off.addr.1.ph = phi i32 [ %off, %entry ], [ %inc, %land.rhs14.preheader ], [ %inc, %if.then7 ], [ %inc, %while.body24.land.rhs14_crit_edge ], [ %inc, %while.body24 ]
  %s.addr.1.ph = phi i8* [ %s, %entry ], [ %incdec.ptr, %land.rhs14.preheader ], [ %incdec.ptr, %if.then7 ], [ %lsr.iv, %while.body24.land.rhs14_crit_edge ], [ %lsr.iv, %while.body24 ]
  br label %while.cond2

while.cond2:                                      ; preds = %while.body4, %while.cond2.outer
  %off.addr.1 = phi i32 [ %inc, %while.body4 ], [ %off.addr.1.ph, %while.cond2.outer ]
  %inc = add nsw i32 %off.addr.1, 1
  %tobool3 = icmp eq i32 %off.addr.1, 0
  br i1 %tobool3, label %if.end29, label %while.body4

while.body4:                                      ; preds = %while.cond2
  %tmp2 = icmp ugt i8* %s.addr.1.ph, %lim
  br i1 %tmp2, label %if.then7, label %while.cond2

if.then7:                                         ; preds = %while.body4
  %incdec.ptr = getelementptr inbounds i8, i8* %s.addr.1.ph, i32 -1
  %tmp3 = load i8, i8* %incdec.ptr, align 1, !tbaa !2
  %conv1525 = zext i8 %tmp3 to i32
  %tobool9 = icmp slt i8 %tmp3, 0
  %cmp129 = icmp ugt i8* %incdec.ptr, %lim
  %or.cond13 = and i1 %tobool9, %cmp129
  br i1 %or.cond13, label %land.rhs14.preheader, label %while.cond2.outer

land.rhs14.preheader:                             ; preds = %if.then7
  %cmp1624 = icmp slt i8 %tmp3, 0
  %cmp2026 = icmp ult i32 %conv1525, 192
  %or.cond27 = and i1 %cmp1624, %cmp2026
  br i1 %or.cond27, label %while.body24.preheader, label %while.cond2.outer

while.body24.preheader:                           ; preds = %land.rhs14.preheader
  %scevgep = getelementptr i8, i8* %s.addr.1.ph, i32 -2
  br label %while.body24

while.body24:                                     ; preds = %while.body24.land.rhs14_crit_edge, %while.body24.preheader
  %lsr.iv = phi i8* [ %scevgep, %while.body24.preheader ], [ %scevgep34, %while.body24.land.rhs14_crit_edge ]
  %cmp12 = icmp ugt i8* %lsr.iv, %lim
  br i1 %cmp12, label %while.body24.land.rhs14_crit_edge, label %while.cond2.outer

while.body24.land.rhs14_crit_edge:                ; preds = %while.body24
  %.pre = load i8, i8* %lsr.iv, align 1, !tbaa !2
  %cmp16 = icmp slt i8 %.pre, 0
  %conv15 = zext i8 %.pre to i32
  %cmp20 = icmp ult i32 %conv15, 192
  %or.cond = and i1 %cmp16, %cmp20
  %scevgep34 = getelementptr i8, i8* %lsr.iv, i32 -1
  br i1 %or.cond, label %while.body24, label %while.cond2.outer

if.end29:                                         ; preds = %while.cond2, %while.body, %while.cond.preheader
  %s.addr.3 = phi i8* [ %s, %while.cond.preheader ], [ %add.ptr, %while.body ], [ %s.addr.1.ph, %while.cond2 ]
  ret i8* %s.addr.3
}

!llvm.module.flags = !{!0, !1}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{i32 1, !"min_enum_size", i32 4}
!2 = !{!3, !3, i64 0}
!3 = !{!"omnipotent char", !4, i64 0}
!4 = !{!"Simple C/C++ TBAA"}
