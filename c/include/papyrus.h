#pragma once
#include <string>
#include <lean/lean.h>

// Forward declarations
namespace llvm {
	class APInt;
	class StringRef;
	class MemoryBuffer;
	class LLVMContext;
	class Module;
	class Type;
	class IntegerType;
	class FunctionType;
	class Value;
	class Constant;
	class Instruction;
	class BasicBlock;
	class GlobalVariable;
	class Function;
	class GenericValue;
}

namespace papyrus {

//------------------------------------------------------------------------------
// Lean Helpers
//------------------------------------------------------------------------------

#define PAPYRUS_DEFAULT_ARRAY_CAPCITY 8

std::string stdOfString(b_lean_obj_arg str);
lean_obj_res mkStringFromStd(const std::string& str);

// Option.some
static inline lean_obj_res mkSome(lean_obj_arg val) {
	lean_obj_res obj = lean_alloc_ctor(1, 1, 0);
	lean_ctor_set(obj, 0, val);
	return obj;
}

static inline lean_obj_res mkStringError(const char* msg) {
	return lean_io_result_mk_error(lean_mk_io_user_error(lean_mk_string(msg)));
}

static inline lean_obj_res mkStdStringError(const std::string& msg) {
	return lean_io_result_mk_error(lean_mk_io_user_error(mkStringFromStd(msg)));
}

//------------------------------------------------------------------------------
// LLVM Interface
//------------------------------------------------------------------------------

lean_object* mkNatFromAP(const llvm::APInt& ap);
lean_object* mkIntFromAP(const llvm::APInt& ap);
llvm::APInt apOfNat(unsigned numBits, b_lean_obj_arg natObj);
llvm::APInt apOfInt(unsigned numBits, b_lean_obj_arg intObj);

lean_obj_res mkStringFromRef(const llvm::StringRef& str);
llvm::StringRef refOfString(b_lean_obj_arg str);
llvm::StringRef refOfStringWithNull(b_lean_obj_arg str);

llvm::MemoryBuffer* toMemoryBuffer(b_lean_obj_arg ref);

lean_obj_res mkContextRef(llvm::LLVMContext* ctx);
llvm::LLVMContext* toLLVMContext(b_lean_obj_res ref);

lean_obj_res mkModuleRef(b_lean_obj_arg ctx, llvm::Module* ptr);
llvm::Module* toModule(b_lean_obj_arg ref);

lean_obj_res mkTypeRef(b_lean_obj_arg ctxRef, llvm::Type* type);
llvm::Type* toType(b_lean_obj_arg ref);
llvm::IntegerType* toIntegerType(b_lean_obj_arg ref);
llvm::FunctionType* toFunctionType(b_lean_obj_arg ref);

lean_obj_res mkValueRef(lean_obj_arg ctxRef, llvm::Value* value);
lean_obj_res getValueContext(b_lean_obj_arg ref);
llvm::Value* toValue(b_lean_obj_arg ref);

lean_obj_res mkConstantRef(lean_obj_arg ctxRef, llvm::Constant* ptr);
llvm::Constant* toConstant(b_lean_obj_arg ref);

llvm::Instruction* toInstruction(b_lean_obj_arg ref);
llvm::BasicBlock* toBasicBlock(b_lean_obj_arg ref);
llvm::GlobalVariable* toGlobalVariable(b_lean_obj_arg ref);
llvm::Function* toFunction(b_lean_obj_arg ref);

lean_obj_res mkGenericValueRef(llvm::GenericValue* val);
llvm::GenericValue* toGenericValue(b_lean_obj_arg ref);

// Covert a Lean Array of references to an LLVM ArrayRef of objects.
// Defined as a macro because it needs to dynamically allocate to the user's stack.
#define LEAN_ARRAY_TO_REF(ELEM_TYPE, CONVERTER, OBJ, REF) \
	auto OBJ##_arr = lean_to_array(OBJ); \
	auto OBJ##_len = OBJ##_arr->m_size; \
	ELEM_TYPE REF##_data[OBJ##_len]; \
	for (auto i = 0; i < OBJ##_len; i++) { \
		REF##_data[i] = CONVERTER(OBJ##_arr->m_data[i]); \
	} \
	ArrayRef<ELEM_TYPE> REF(REF##_data, OBJ##_len)

} // end namespace papyrus
