//===- lib/MC/MCInst.cpp - MCInst implementation --------------------------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//

#include "llvm/MC/MCInst.h"
#include "llvm/MC/MCExpr.h"
#include "llvm/MC/MCInstPrinter.h"
#include "llvm/Support/Compiler.h"
#include "llvm/Support/Debug.h"
#include "llvm/Support/raw_ostream.h"

using namespace llvm;

void MCOperand::print(raw_ostream &OS) const {
  OS << "<MCOperand ";
  if (!isValid())
    OS << "INVALID";
  else if (isReg())
    OS << "Reg:" << getReg();
  else if (isImm())
    OS << "Imm:" << getImm();
  else if (isFPImm())
    OS << "FPImm:" << getFPImm();
  else if (isExpr()) {
    OS << "Expr:(" << *getExpr() << ")";
  } else if (isInst()) {
    OS << "Inst:(" << *getInst() << ")";
  } else
    OS << "UNDEFINED";
  OS << ">";
}

#ifdef LLVM_ENABLE_DUMP
LLVM_DUMP_METHOD void MCOperand::dump() const {
  print(dbgs());
  dbgs() << "\n";
}
#endif

void MCInst::print(raw_ostream &OS) const {
  OS << "<MCInst " << getOpcode();
  for (unsigned i = 0, e = getNumOperands(); i != e; ++i) {
    OS << " ";
    getOperand(i).print(OS);
  }
  OS << ">";
}

void MCInst::dump_pretty(raw_ostream &OS, const MCInstPrinter *Printer,
                         StringRef Separator) const {
  OS << "<MCInst #" << getOpcode();

  // Show the instruction opcode name if we have access to a printer.
  if (Printer)
    OS << ' ' << Printer->getOpcodeName(getOpcode());

  for (unsigned i = 0, e = getNumOperands(); i != e; ++i) {
    OS << Separator;
    getOperand(i).print(OS);
  }
  OS << ">";
}

#ifdef LLVM_ENABLE_DUMP
LLVM_DUMP_METHOD void MCInst::dump() const {
  print(dbgs());
  dbgs() << "\n";
}
#endif
