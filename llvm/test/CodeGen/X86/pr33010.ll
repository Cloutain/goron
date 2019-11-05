; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc -mtriple=x86_64-linux-generic < %s | FileCheck %s

target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"

; We can't create a select of two TargetFrameIndices since the rest
; of the backend doesn't know how to handle such a construct.
define i32 addrspace(1)* @test(i32 addrspace(1)* %a, i32 addrspace(1)* %b, i1 %which) gc "statepoint-example" {
; CHECK-LABEL: test:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    pushq %rbx
; CHECK-NEXT:    .cfi_def_cfa_offset 16
; CHECK-NEXT:    subq $16, %rsp
; CHECK-NEXT:    .cfi_def_cfa_offset 32
; CHECK-NEXT:    .cfi_offset %rbx, -16
; CHECK-NEXT:    movl %edx, %ebx
; CHECK-NEXT:    movq %rdi, (%rsp)
; CHECK-NEXT:    movq %rsi, {{[0-9]+}}(%rsp)
; CHECK-NEXT:    callq f
; CHECK-NEXT:  .Ltmp0:
; CHECK-NEXT:    testb $1, %bl
; CHECK-NEXT:    je .LBB0_1
; CHECK-NEXT:  # %bb.2: # %entry
; CHECK-NEXT:    movq (%rsp), %rax
; CHECK-NEXT:    jmp .LBB0_3
; CHECK-NEXT:  .LBB0_1:
; CHECK-NEXT:    movq {{[0-9]+}}(%rsp), %rax
; CHECK-NEXT:  .LBB0_3: # %entry
; CHECK-NEXT:    addq $16, %rsp
; CHECK-NEXT:    .cfi_def_cfa_offset 16
; CHECK-NEXT:    popq %rbx
; CHECK-NEXT:    .cfi_def_cfa_offset 8
; CHECK-NEXT:    retq
entry:
  %tok = tail call token (i64, i32, void ()*, i32, i32, ...) @llvm.experimental.gc.statepoint.p0f_isVoidf(i64 0, i32 0, void ()* @f, i32 0, i32 0, i32 0, i32 0, i32 addrspace(1)* %a, i32 addrspace(1)* %b)
  %a.r = tail call coldcc i8 addrspace(1)* @llvm.experimental.gc.relocate.p1i8(token %tok, i32 7, i32 7) ; (%a, %a)
  %b.r = tail call coldcc i8 addrspace(1)* @llvm.experimental.gc.relocate.p1i8(token %tok, i32 8, i32 8) ; (%b, %b)
  %cond.v = select i1 %which, i8 addrspace(1)* %a.r, i8 addrspace(1)* %b.r
  %cond = bitcast i8 addrspace(1)* %cond.v to i32 addrspace(1)*
  ret i32 addrspace(1)* %cond
}

declare void @f()
declare token @llvm.experimental.gc.statepoint.p0f_isVoidf(i64, i32, void ()*, i32, i32, ...)
declare i8 addrspace(1)* @llvm.experimental.gc.relocate.p1i8(token, i32, i32)
