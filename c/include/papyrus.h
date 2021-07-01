#pragma once
#include <lean/object.h>

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
	class Instruction;
	class BasicBlock;
	class Function;
	class GenericValue;
}

namespace papyrus {

lean::object* mkNatFromAP(const llvm::APInt& ap);
lean::object* mkIntFromAP(const llvm::APInt& ap);
const llvm::APInt apOfNat(unsigned numBits, lean::object* obj);
const llvm::APInt apOfInt(unsigned numBits, lean::object* obj);

lean::object* mkStringFromRef(const llvm::StringRef& str);
const llvm::StringRef refOfString(lean::object* str);

llvm::MemoryBuffer* toMemoryBuffer(lean::object* ref);

lean::object* mkContextRef(llvm::LLVMContext* ctx);
llvm::LLVMContext* toLLVMContext(lean::object* ref);

lean::object* mkModuleRef(lean::object* ctx, llvm::Module* ptr);
llvm::Module* toModule(lean::object* ref);

lean::object* mkTypeRef(lean::object* ctxRef, llvm::Type* type);
llvm::Type* toType(lean::object* ref);
llvm::IntegerType* toIntegerType(lean::object* ref);
llvm::FunctionType* toFunctionType(lean::object* ref);

lean::object* mkValueRef(lean::object* ctxRef, llvm::Value* value);
lean::object* getValueContext(lean::object* ref);
lean::object* borrowValueContext(lean::object* ref);
llvm::Value* toValue(lean::object* ref);
llvm::Instruction* toInstruction(lean::object* ref);
llvm::BasicBlock* toBasicBlock(lean::object* ref);
llvm::Function* toFunction(lean::object* ref);

lean::object* mkGenericValueRef(llvm::GenericValue* val);
llvm::GenericValue* toGenericValue(lean::object* ref);

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
