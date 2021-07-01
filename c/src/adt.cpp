#include "papyrus.h"

#include <lean/utf8.h>
#include <llvm/ADT/ArrayRef.h>
#include <llvm/ADT/StringRef.h>
#include <llvm/ADT/APInt.h>

using namespace lean;
using namespace llvm;

namespace papyrus {

lean::object* mkStringFromRef(const llvm::StringRef& str) {
  size_t size  = str.size();
  size_t len = lean::utf8_strlen(str.data(), size);
  size_t realSize = size + 1;
  lean::object* obj = lean_alloc_string(realSize, realSize, len);
  char* data = lean_to_string(obj)->m_data;
  memcpy(data, str.data(), size);
  data[size] = 0;
  return obj;
}

const llvm::StringRef refOfString(lean::object* obj) {
  auto strObj = lean_to_string(obj);
  return llvm::StringRef(strObj->m_data, strObj->m_size - 1);
}

#define LEAN_SMALL_NAT_BITS (CHAR_BIT*sizeof(size_t)-1)
#define LEAN_SMALL_INT_BITS (sizeof(void*) == 8 ? (CHAR_BIT*sizeof(int)-1) : 30)

lean::object* mkNatFromAP(const llvm::APInt& ap) {
  if (LEAN_LIKELY(ap.getActiveBits() <= LEAN_SMALL_NAT_BITS)) {
    return lean_box(ap.getZExtValue());
  } else {
    mpz mpzObj;
    // Hack to get the mpz_t of a lean::mpz
    auto mpzVal = reinterpret_cast<mpz_t&>(mpzObj);
    mpz_import(mpzVal, ap.getNumWords(), -1,
      APInt::APINT_WORD_SIZE, 0, 0, ap.getRawData());
    return lean::alloc_mpz(mpzObj);
  }
}

lean::object* mkIntFromAP(const llvm::APInt& ap) {
  if (LEAN_LIKELY(ap.getMinSignedBits() <= LEAN_SMALL_INT_BITS)) {
    return lean_box((unsigned)((int)ap.getSExtValue()));
  } else {
    mpz mpzObj;
    // Hack to get the mpz_t of a lean::mpz
    auto mpzVal = reinterpret_cast<mpz_t&>(mpzObj);
    // APInt -> mpz conversion
    auto apAbs = ap.abs();
    mpz_import(mpzVal, apAbs.getNumWords(), -1,
      APInt::APINT_WORD_SIZE, 0, 0, apAbs.getRawData());
    if (ap.isNegative()) mpz_neg(mpzVal, mpzVal);
    return lean::alloc_mpz(mpzObj);
  }
}

const llvm::APInt mpz_obj_to_ap_nat(unsigned numBits, const lean::mpz& z) {
  // Hack to extract the `mpz_t` from a lean object
  auto mpzVal = reinterpret_cast<const mpz_t&>(z);
  // mpz -> APInt conversion
  auto realNumBits = mpz_sizeinbase(mpzVal, 2);
  auto bitsPerWord = APInt::APINT_BITS_PER_WORD;
  size_t numWords = (realNumBits + (bitsPerWord - 1)) / bitsPerWord;
  APInt::WordType words[numWords];
  mpz_export(&words, nullptr, -1, APInt::APINT_WORD_SIZE, 0, 0, mpzVal);
  llvm::ArrayRef<uint64_t> wordsRef(words, numWords);
  return llvm::APInt(numBits, wordsRef);
}

const llvm::APInt apOfNat(unsigned numBits, lean::object* obj) {
  if (lean_is_scalar(obj)) {
    return llvm::APInt(numBits, lean_unbox(obj), false);
  } else {
    return mpz_obj_to_ap_nat(numBits, lean::mpz_value(obj));
  }
}

const llvm::APInt apOfInt(unsigned numBits, lean::object* obj) {
  if (lean_is_scalar(obj)) {
    return llvm::APInt(numBits, lean_unbox(obj), true);
  } else {
    auto mpzObj = lean::mpz_value(obj);
    llvm::APInt apNat = mpz_obj_to_ap_nat(numBits, mpzObj);
    return mpzObj.is_neg() ? -apNat : apNat;
  }
}

} // end namespace papyrus
