import Lean.Parser
import Papyrus.IR.Types

namespace Papyrus.Script

-- # Matcher

partial def isDecimalTail (str : String) (i : String.Pos) : Bool :=
  if str.atEnd i then true else
  if (str.get i).isDigit then isDecimalTail str (str.next i) else
  false

def isDecimal (str : String) (i : String.Pos) : Bool :=
  if str.atEnd i then false else
  if (str.get i).isDigit then isDecimalTail str (str.next i) else false

partial def decodeDecimalTail? (str : String) (i : String.Pos) (val : Nat) : Option Nat :=
  if str.atEnd i then some val
  else
    let c := str.get i
    if c.isDigit then
      decodeDecimalTail? str (str.next i) (10*val + c.toNat - '0'.toNat)
    else none

def decodeDecimal? (str : String) (i : String.Pos) : Option Nat :=
  if str.atEnd i then none else let c := str.get i
  if c.isDigit then decodeDecimalTail? str (str.next i) (c.toNat - '0'.toNat) else none

def isIntTypeLit (str : String) : Bool :=
  let i : String.Pos := 0
  if str.atEnd i then false else
  if str.get i == 'i' then isDecimal str (str.next i) else false

-- # Parser

open Lean

section
open Parser

def intTypeLitFn : ParserFn := fun c s =>
  let errorMsg := "expected integer type literal"
  let initStackSz := s.stackSize
  let startPos := s.pos
  let s := tokenFn [errorMsg] c s
  if s.hasError then s
  else
    match s.stxStack.back with
    | Syntax.ident info rawVal _ _ =>
      let atom := rawVal.toString
      if isIntTypeLit atom then
        let s := s.popSyntax
        s.pushSyntax <| Syntax.mkLit `Papyrus.Script.intTypeLit atom info
      else
        s.mkErrorAt errorMsg startPos initStackSz
    | _ => s.mkErrorAt errorMsg startPos initStackSz

@[inline] def intTypeLitNoAntiquot : Parser := {
  fn := intTypeLitFn
  info := { firstTokens := FirstTokens.tokens [ "intTypeLit", "ident" ] }
}

def intTypeLit : Parser :=
  withAntiquot (mkAntiquot "intTypeLit" `Papyrus.Script.intTypeLit) intTypeLitNoAntiquot

end

-- # Pretty Printer

section
open PrettyPrinter Formatter Parenthesizer

@[combinatorFormatter Papyrus.Script.intTypeLitNoAntiquot]
def intTypeLitNoAntiquot.formatter := identNoAntiquot.formatter

@[combinatorParenthesizer Papyrus.Script.intTypeLitNoAntiquot]
def intTypeLitNoAntiquot.parenthesizer := identNoAntiquot.parenthesizer
end

attribute [runParserAttributeHooks] intTypeLit

-- # Macro

def decodeIntTypeLit? (stx : Lean.Syntax) : Option Nat :=
  OptionM.run do decodeDecimal? (← stx.isLit? ``intTypeLit) 1

def expandIntTypeLitAsNatLit (stx : Syntax) : MacroM Syntax :=
  match stx.isLit? ``intTypeLit with
  | some str => Syntax.mkNumLit (str.drop 1) (SourceInfo.fromRef stx)
  | none => Macro.throwErrorAt stx "ill-formed integer type literal"

def expandIntTypeLitAsType (stx : Syntax) : MacroM Syntax := do
  ``(integerType $(← expandIntTypeLitAsNatLit stx))

def expandIntTypeLitAsRef (stx : Syntax) : MacroM Syntax := do
  ``(IntegerTypeRef.get $(← expandIntTypeLitAsNatLit stx))

scoped macro:max (priority := high) x:intTypeLit : term => expandIntTypeLitAsType x
