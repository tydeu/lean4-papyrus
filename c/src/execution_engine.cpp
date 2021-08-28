#include "papyrus.h"
#include "papyrus_ffi.h"

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
    lean_register_external_class(&deleteFinalize<EEExternal>, &nopForeach);
	return c;
}

// Wrap a ExecutionEngine in a Lean object.
lean::object* mkExecutionEngineRef(EEExternal* ee) {
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
  builder.setMArch(refOfString(marchStr));
  builder.setMCPU(refOfString(mcpuStr));
  LEAN_ARRAY_TO_REF(std::string, string_to_std, mattrsObj, mattrs);
  builder.setMAttrs(mattrs);
  // Try to construct the execution engine
  if (ExecutionEngine* ee = builder.create()) {
    auto eee = new EEExternal(ee, errMsg);
    eee->modules.push_back(toModule(modObj));
    return io_result_mk_ok(mkExecutionEngineRef(eee));
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
(b_obj_arg funRef, b_obj_arg eeRef, b_obj_arg argsObj, obj_arg /* w */)
{
  LEAN_ARRAY_TO_REF(GenericValue, *toGenericValue, argsObj, args);
  auto ret = toExecutionEngine(eeRef)->runFunction(toFunction(funRef), args);
  return io_result_mk_ok(mkGenericValueRef(new GenericValue(ret)));
}

/*
  A helper function to wrap the behavior of `runFunction`
  to handle common task of starting up a `main` function with the usual
  `argc`, `argv`, and `envp` parameters.

  Instead of using LLVM's `runFunctionAsMain` directly,
  we adapt its code to Lean's data structures.
*/
extern "C" obj_res papyrus_execution_engine_run_function_as_main
(b_obj_arg funRef,  b_obj_arg eeRef, b_obj_arg argsObj, b_obj_arg envObj,  obj_arg /* w */)
{
  auto fn = toFunction(funRef);
  auto fnTy = fn->getFunctionType();
  auto& ctx = fnTy->getContext();
  auto fnArgc = fnTy->getNumParams();
  auto ppInt8Ty = Type::getInt8PtrTy(ctx)->getPointerTo();

  if (fnArgc > 3)
    return io_result_mk_error(mk_string("Invalid number of arguments of main() supplied"));
  if (fnArgc >= 3 && fnTy->getParamType(2) != ppInt8Ty)
    return io_result_mk_error(mk_string("Invalid type for third argument of main() supplied"));
  if (fnArgc >= 2 && fnTy->getParamType(1) != ppInt8Ty)
    return io_result_mk_error(mk_string("Invalid type for second argument of main() supplied"));
  if (fnArgc >= 1 && !fnTy->getParamType(0)->isIntegerTy(32))
    return io_result_mk_error(mk_string("Invalid type for first argument of main() supplied"));
  if (!fnTy->getReturnType()->isIntegerTy() && !fnTy->getReturnType()->isVoidTy())
    return io_result_mk_error(mk_string("Invalid return type of main() supplied"));

  auto ee = toExecutionEngine(eeRef);
  unsigned ptrSize = ee->getDataLayout().getPointerSize();

  GenericValue args[fnArgc];
  auto argsArr = lean_to_array(argsObj);
  auto argc = argsArr->m_size;
  auto argv = std::make_unique<char[]>(argc*ptrSize);
  auto envArr = lean_to_array(envObj);
  auto envc = envArr->m_size;
  auto envv = std::make_unique<char[]>(envc*ptrSize);

  if (fnArgc > 0) {
    args[0].IntVal = APInt(32, argc);
    if (fnArgc > 1) {
      auto pInt8Ty = Type::getInt8PtrTy(ctx);
      auto argsd = argsArr->m_data;
      for (auto i = 0; i < argc; i++) {
        auto str = lean_to_string(argsd[i]);
        auto arg = std::make_unique<char[]>(str->m_size);
        std::copy(str->m_data, str->m_data + str->m_size, arg.get());
        // endian safe: argv[i] = arg.get()
        ee->StoreValueToMemory(PTOGV(arg.get()),
          (GenericValue*)(&argv[argc*ptrSize]), pInt8Ty);
      }
      args[1].PointerVal = argv.get();
      if (fnArgc > 2) {
        auto envd = envArr->m_data;
        for (auto i = 0; i < envc; i++) {
          auto str = lean_to_string(envd[i]);
          auto env = std::make_unique<char[]>(str->m_size);
          std::copy(str->m_data, str->m_data + str->m_size, env.get());
          // endian safe: envv[i] = var
          ee->StoreValueToMemory(PTOGV(env.get()),
            (GenericValue*)(&envv[envc*ptrSize]), pInt8Ty);
        }
        args[2].PointerVal = envv.get();
      }
    }
  }

  auto gRc = ee->runFunction(toFunction(funRef), ArrayRef<GenericValue>(args, fnArgc));
  return io_result_mk_ok(box_uint32(gRc.IntVal.getZExtValue()));
}

} // end namespace papyrus
