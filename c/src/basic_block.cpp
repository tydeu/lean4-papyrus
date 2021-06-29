#include "papyrus.h"

#include <lean/io.h>
#include <llvm/IR/BasicBlock.h>

using namespace lean;
using namespace llvm;

namespace papyrus {

// Get the LLVM BasicBlock pointer wrapped in an object.
llvm::BasicBlock* toBasicBlock(lean::object* bbRef) {
    return llvm::cast<BasicBlock>(toValue(bbRef));
}

// Get a reference to a newly created basic block.
extern "C" obj_res papyrus_basic_block_create
(b_obj_arg nameObj, obj_arg ctxRef, obj_arg /* w */)
{
    auto bb = BasicBlock::Create(*toLLVMContext(ctxRef), string_to_ref(nameObj));
    return io_result_mk_ok(mk_value_ref(ctxRef, bb));
}

// Get an array of references to the instructions of the given basic block.
extern "C" obj_res papyrus_basic_block_get_instructions(b_obj_arg bbRef, obj_arg /* w */) {
    auto ctxRef = getBorrowedValueContext(bbRef);
    auto& is = toBasicBlock(bbRef)->getInstList();
    lean_object* arr = lean::alloc_array(0, 8);
    for (llvm::Instruction& i : is) {
        lean_inc_ref(ctxRef);
        arr = lean_array_push(arr, mk_value_ref(ctxRef, &i));
    }
    return io_result_mk_ok(arr);
}

// Add the given instruction to the end of the given basic block.
extern "C" obj_res papyrus_basic_block_append_instruction
(b_obj_arg instRef, b_obj_arg bbRef, obj_arg /* w */)
{
    toBasicBlock(bbRef)->getInstList().push_back(toInstruction(instRef));
    return io_result_mk_ok(box(0));
}

} // end namespace papyrus
