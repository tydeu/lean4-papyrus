#include "papyrus.h"

#include <lean/io.h>
#include <llvm/ExecutionEngine/GenericValue.h>
#include <llvm/ExecutionEngine/ExecutionEngine.h>

using namespace lean;
using namespace llvm;

namespace papyrus {

struct EEExternal {

  // The execution engine handle.
	ExecutionEngine* ee;

  // The modules controlled by the execution engine.
	SmallVector<Module*, 1> modules;

	// The error message owned by the execution engine.
	std::string* errMsg;

	EEExternal(ExecutionEngine* ee, std::string* errMsg)
		: ee(ee), errMsg(errMsg) {}

  EEExternal(const EEExternal&) = delete;

	~EEExternal() {
    // remove all the modules from the execution engine so they don't get deleted
		for (auto it = modules.begin(), end = modules.end(); it != end; ++it) {
      ee->removeModule(*it);
    }
    delete ee;
    delete errMsg;
	}
};

// Lean object class for an LLVM ExecutionEngine.
static external_object_class* getExecutionEngineClass() {
	// Use static to make this thread safe by static initialization rules.
  static external_object_class* c =
    lean_register_external_class(&deletePointer<EEExternal>, &nopForeach);
	return c;
}

// Wrap a ExecutionEngine in a Lean object.
lean::object* mk_execution_engine(EEExternal* ee) {
	return lean_alloc_external(getExecutionEngineClass(), ee);
}

// Get the ExecutionEngine external wrapped in an object.
EEExternal* toEEExternal(lean::object* eeRef) {
	auto external = lean_to_external(eeRef);
	assert(external->m_class == getExecutionEngineClass());
	return static_cast<EEExternal*>(external->m_data);
}

// Get the ExecutionEngine wrapped in an object.
ExecutionEngine* toExecutionEngine(lean::object* eeRef) {
	return toEEExternal(eeRef)->ee;
}

// Unpack the Lean representation of an engine kind into the LLVM one.
EngineKind::Kind unpackEngineKnd(uint8 kind) {
  return kind == 0 ? EngineKind::Either : static_cast<EngineKind::Kind>(kind);
}

//extern "C" lean::object* mk_io_user_error(lean::object* str);

// Create a new execution engine for the given module.
extern "C" obj_res papyrus_execution_engine_create_for_module
(b_obj_arg modObj, uint8 kindObj, b_obj_arg marchStr, b_obj_arg mcpuStr,
  b_obj_arg mattrsObj, uint8 optLevel, uint8 verifyModules, obj_arg /* w */)
{
  // Create an engine builder
	EngineBuilder builder(std::unique_ptr<Module>(toModule(modObj)));
  // Configure the builder
  auto errMsg = new std::string();
  auto kind = unpackEngineKnd(kindObj);
  builder.setEngineKind(kind);
  builder.setErrorStr(errMsg);
  builder.setOptLevel(static_cast<CodeGenOpt::Level>(optLevel));
  builder.setVerifyModules(verifyModules);
  builder.setMArch(string_to_ref(marchStr));
  builder.setMCPU(string_to_ref(mcpuStr));
  LEAN_ARRAY_TO_REF(std::string, string_to_std, mattrsObj, mattrs);
  builder.setMAttrs(mattrs);
  // Try to construct the execution engine
  if (ExecutionEngine* ee = builder.create()) {
    auto eee = new EEExternal(ee, errMsg);
    eee->modules.push_back(toModule(modObj));
    return io_result_mk_ok(mk_execution_engine(eee));
  } else {
    // Steal back the module pointer before it gets deleted
    reinterpret_cast<std::unique_ptr<Module>&>(builder).release();
    auto res = io_result_mk_error(*errMsg);
    delete errMsg;
    return res;
  }
  return io_result_mk_ok(box(0));
}

// Run the given function with given arguments
// in the given execution engine and return the result.
extern "C" obj_res papyrus_execution_engine_run_function
(b_obj_arg funRef, b_obj_arg argsObj,  b_obj_arg eeRef, obj_arg /* w */)
{
  LEAN_ARRAY_TO_REF(GenericValue, *toGenericValue, argsObj, args);
  auto ret = toExecutionEngine(eeRef)->runFunction(toFunction(funRef), args);
  return io_result_mk_ok(mk_generic_value(new GenericValue(ret)));
}

} // end namespace papyrus
