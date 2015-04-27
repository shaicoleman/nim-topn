import random, strfmt

let count   = 1_000_000
let max_int = 10_000_000_000_000_000

var f = open("numbers.out", fmWrite)
for i in countup(1, count):
  let num = randomInt(max_int)
  f.writeln "{:016d}".fmt(num)
f.close
