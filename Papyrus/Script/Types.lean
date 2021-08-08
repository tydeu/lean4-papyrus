import Papyrus.IR.Types

namespace Papyrus.Script

def i8 := int8Type
def i16 := int16Type
def i32 := int32Type
def i64 := int64Type
def i128 := int128Type

scoped postfix:max "*" => pointerType
