#include "papyrus.h"

#include <lean/lean.h>
#include <lean/lean_gmp.h>
#include <llvm/ADT/ArrayRef.h>
#include <llvm/ADT/StringRef.h>
#include <llvm/ADT/APInt.h>

// Forward declarations

namespace papyrus {

// Makes a Lean `String` from a non-null terminated string of the given size.
lean_obj_res mkStringFromSized(const char* str, size_t size) {
  size_t real_size = size + 1;
  size_t len = lean_utf8_n_strlen(str, size);
  lean_object* obj = lean_alloc_string(real_size, real_size, len);
  auto lean_data = lean_to_string(obj)->m_data;
  memcpy(lean_data, str, size);
  lean_data[size] = 0;
  return obj;
}

lean_obj_res mkStringFromStd(const std::string& str) {
  return mkStringFromSized(str.data(), str.size());
}

std::string stdOfString(b_lean_obj_arg str) {
  auto strObj = lean_to_string(str);
  assert(strObj->m_size > 0);
  return std::string(strObj->m_data, strObj->m_size - 1);
}

lean_obj_res mkStringFromRef(const llvm::StringRef& str) {
  return mkStringFromSized(str.data(), str.size());
}

llvm::StringRef refOfString(b_lean_obj_arg str) {
  auto strObj = lean_to_string(str);
  return llvm::StringRef(strObj->m_data, strObj->m_size - 1);
}

llvm::StringRef refOfStringWithNull(b_lean_obj_arg str) {
  auto strObj = lean_to_string(str);
  return llvm::StringRef(strObj->m_data, strObj->m_size);
}

#define LEAN_SMALL_NAT_BITS (CHAR_BIT*sizeof(size_t)-1)
#define LEAN_SMALL_INT_BITS (sizeof(void*) == 8 ? (CHAR_BIT*sizeof(int)-1) : 30)

lean_object* mkNatFromAP(const llvm::APInt& ap) {
  if (LEAN_LIKELY(ap.getActiveBits() <= LEAN_SMALL_NAT_BITS)) {
    return lean_box(ap.getZExtValue());
  } else {
    mpz_t val;
    mpz_init(val);
    mpz_import(val, ap.getNumWords(), -1,
      llvm::APInt::APINT_WORD_SIZE, 0, 0, ap.getRawData());
    return lean_alloc_mpz(val);
  }
}

lean_object* mkIntFromAP(const llvm::APInt& ap) {
  if (LEAN_LIKELY(ap.getMinSignedBits() <= LEAN_SMALL_INT_BITS)) {
    return lean_box((unsigned)((int)ap.getSExtValue()));
  } else {
    mpz_t val;
    mpz_init(val);
    auto apAbs = ap.abs();
    mpz_import(val, apAbs.getNumWords(), -1,
      llvm::APInt::APINT_WORD_SIZE, 0, 0, apAbs.getRawData());
    if (ap.isNegative()) mpz_neg(val, val);
    return lean_alloc_mpz(val);
  }
}

llvm::APInt apNatOfMpz(unsigned numBits, const mpz_t& val) {
  auto realNumBits = mpz_sizeinbase(val, 2);
  auto bitsPerWord = llvm::APInt::APINT_BITS_PER_WORD;
  size_t numWords = (realNumBits + (bitsPerWord - 1)) / bitsPerWord;
  llvm::APInt::WordType words[numWords];
  mpz_export(&words, nullptr, -1, llvm::APInt::APINT_WORD_SIZE, 0, 0, val);
  llvm::ArrayRef<uint64_t> wordsRef(words, numWords);
  return llvm::APInt(numBits, wordsRef);
}

llvm::APInt apOfNat(unsigned numBits, b_lean_obj_arg obj) {
  if (lean_is_scalar(obj)) {
    return llvm::APInt(numBits, lean_unbox(obj), false);
  } else {
    mpz_t val;
    mpz_init(val);
    assert(lean_is_mpz(obj));
    lean_mpz_value(obj, val);
    return apNatOfMpz(numBits, val);
  }
}

llvm::APInt apOfInt(unsigned numBits, b_lean_obj_arg obj) {
  if (lean_is_scalar(obj)) {
    return llvm::APInt(numBits, lean_scalar_to_int64(obj), true);
  } else {
    mpz_t val;
    mpz_init(val);
    assert(lean_is_mpz(obj));
    lean_mpz_value(obj, val);
    llvm::APInt apNat = apNatOfMpz(numBits, val);
    return mpz_sgn(val) < 0 ? -apNat : apNat;
  }
}

} // end namespace papyrus
