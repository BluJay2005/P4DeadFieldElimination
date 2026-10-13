#include "llvm/IR/PassManager.h"
#include "llvm/IR/Instructions.h"
#include "llvm/Support/raw_ostream.h"
#include "llvm/Passes/PassBuilder.h"
#include "llvm/Plugins/PassPlugin.h"
#include <set>

using namespace llvm;

namespace {
class P4DeadFieldElimination : public PassInfoMixin<P4DeadFieldElimination> {
public:
    PreservedAnalyses run(Function &F, FunctionAnalysisManager &AM) {
        std::set<int64_t> accessedIndices;
        errs() << "Analyzing Network Pipeline Function: " << F.getName() << "\n";

        // Step 1: Scan all instructions to find what packet attributes are used
        for (BasicBlock &BB : F) {
            for (Instruction &I : BB) {
                if (auto *gep = dyn_cast<GetElementPtrInst>(&I)) {
                    if (gep->getSourceElementType()->isStructTy()) {
                        if (gep->getNumOperands() >= 3) {
                            if (auto *ci = dyn_cast<ConstantInt>(gep->getOperand(2))) {
                                accessedIndices.insert(ci->getSExtValue());
                            }
                        }
                    }
                }
            }
        }

        // Step 2: Report unused indices so the hardware allocator can drop them
        errs() << "--- OPTIMIZATION REPORT FOR AMD ASIC --- \n";
        errs() << "» Field (Source IP): " << (accessedIndices.count(0) ? "ACTIVE" : "DEAD - STRIP IT") << "\n";
        errs() << "» Field (Telemetry Tag): " << (accessedIndices.count(1) ? "ACTIVE" : "DEAD - STRIP IT") << "\n";

        return PreservedAnalyses::all();
    }
};
} // namespace

// ============================================================================
//  REQUIRED LLVM NEW PASS MANAGER PLUGIN REGISTRATION BOILERPLATE
// ============================================================================
llvm::PassPluginLibraryInfo getP4OptimizerPluginInfo() {
    return {
        LLVM_PLUGIN_API_VERSION, 
        "P4Optimizer", 
        LLVM_VERSION_STRING,
        [](PassBuilder &PB) {
            PB.registerPipelineParsingCallback(
                [](StringRef Name, FunctionPassManager &FPM,
                   ArrayRef<PassBuilder::PipelineElement>) {
                    if (Name == "p4-dead-field-elim") {
                        FPM.addPass(P4DeadFieldElimination());
                        return true;
                    }
                    return false;
                });
        }
    };
}

extern "C" LLVM_ATTRIBUTE_WEAK ::llvm::PassPluginLibraryInfo llvmGetPassPluginInfo() {
    return getP4OptimizerPluginInfo();
}
