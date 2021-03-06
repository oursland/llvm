; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc -O0 -mattr=+avx512f < %s | FileCheck %s

target datalayout = "e-m:o-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-apple-macosx10.11.0"

define i32 @test(float %a, float %b)  {
; CHECK-LABEL: test:
; CHECK:       ## BB#0:
; CHECK-NEXT:    pushq %rax
; CHECK-NEXT:    .cfi_def_cfa_offset 16
; CHECK-NEXT:    vcmpeqss %xmm1, %xmm0, %k0
; CHECK-NEXT:    kmovw %k0, %eax
; CHECK-NEXT:    movb %al, %cl
; CHECK-NEXT:    xorb $-1, %cl
; CHECK-NEXT:    testb $1, %cl
; CHECK-NEXT:    jne LBB0_1
; CHECK-NEXT:    jmp LBB0_2
; CHECK-NEXT:  LBB0_1: ## %L_0
; CHECK-NEXT:    callq ___assert_rtn
; CHECK-NEXT:  LBB0_2: ## %L_1
; CHECK-NEXT:    xorl %eax, %eax
; CHECK-NEXT:    popq %rcx
; CHECK-NEXT:    retq
  %x10 = fcmp oeq float %a, %b
  %x11 = xor i1 %x10, true
  br i1 %x11, label %L_0, label %L_1

L_0:                                     ; preds = %2
  call void @__assert_rtn()
  unreachable
                                                  ; No predecessors!
L_1:                                     ; preds = %2
  ret i32 0
}

; Function Attrs: noreturn
declare void @__assert_rtn()

