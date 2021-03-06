; This test verifies that the loop vectorizer will not vectorizes low trip count
; loops that require runtime checks (Trip count is computed with profile info).
; REQUIRES: asserts
; RUN: opt < %s -loop-vectorize -loop-vectorize-with-block-frequency -S | FileCheck %s

target datalayout = "E-m:e-p:32:32-i64:32-f64:32:64-a:0:32-n32-S128"

@tab = common global [32 x i8] zeroinitializer, align 1

define i32 @foo_low_trip_count1(i32 %bound) {
; Simple loop with low tripcount. Should not be vectorized.

; CHECK-LABEL: @foo_low_trip_count1(
; CHECK-NOT: <{{[0-9]+}} x i8>

entry:
  br label %for.body

for.body:                                         ; preds = %for.body, %entry
  %i.08 = phi i32 [ 0, %entry ], [ %inc, %for.body ]
  %arrayidx = getelementptr inbounds [32 x i8], [32 x i8]* @tab, i32 0, i32 %i.08
  %0 = load i8, i8* %arrayidx, align 1
  %cmp1 = icmp eq i8 %0, 0
  %. = select i1 %cmp1, i8 2, i8 1
  store i8 %., i8* %arrayidx, align 1
  %inc = add nsw i32 %i.08, 1
  %exitcond = icmp eq i32 %i.08, %bound
  br i1 %exitcond, label %for.end, label %for.body, !prof !1

for.end:                                          ; preds = %for.body
  ret i32 0
}

define i32 @foo_low_trip_count2(i32 %bound) !prof !0 {
; The loop has a same invocation count with the function, but has a low
; trip_count per invocation and not worth to vectorize.

; CHECK-LABEL: @foo_low_trip_count2(
; CHECK-NOT: <{{[0-9]+}} x i8>

entry:
  br label %for.body

for.body:                                         ; preds = %for.body, %entry
  %i.08 = phi i32 [ 0, %entry ], [ %inc, %for.body ]
  %arrayidx = getelementptr inbounds [32 x i8], [32 x i8]* @tab, i32 0, i32 %i.08
  %0 = load i8, i8* %arrayidx, align 1
  %cmp1 = icmp eq i8 %0, 0
  %. = select i1 %cmp1, i8 2, i8 1
  store i8 %., i8* %arrayidx, align 1
  %inc = add nsw i32 %i.08, 1
  %exitcond = icmp eq i32 %i.08, %bound
  br i1 %exitcond, label %for.end, label %for.body, !prof !1

for.end:                                          ; preds = %for.body
  ret i32 0
}

define i32 @foo_low_trip_count3(i1 %cond, i32 %bound) !prof !0 {
; The loop has low invocation count compare to the function invocation count, 
; but has a high trip count per invocation. Vectorize it.

; CHECK-LABEL: @foo_low_trip_count3(
; CHECK: vector.body:

entry:
  br i1 %cond, label %for.preheader, label %for.end, !prof !2

for.preheader:
  br label %for.body

for.body:                                         ; preds = %for.body, %entry
  %i.08 = phi i32 [ 0, %for.preheader ], [ %inc, %for.body ]
  %arrayidx = getelementptr inbounds [32 x i8], [32 x i8]* @tab, i32 0, i32 %i.08
  %0 = load i8, i8* %arrayidx, align 1
  %cmp1 = icmp eq i8 %0, 0
  %. = select i1 %cmp1, i8 2, i8 1
  store i8 %., i8* %arrayidx, align 1
  %inc = add nsw i32 %i.08, 1
  %exitcond = icmp eq i32 %i.08, %bound
  br i1 %exitcond, label %for.end, label %for.body, !prof !3

for.end:                                          ; preds = %for.body
  ret i32 0
}


!0 = !{!"function_entry_count", i64 100}
!1 = !{!"branch_weights", i32 100, i32 0}
!2 = !{!"branch_weights", i32 10, i32 90}
!3 = !{!"branch_weights", i32 10, i32 10000}
