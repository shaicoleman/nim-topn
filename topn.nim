import strutils, algorithm, strfmt, times, sequtils, parseopt2, os

type
  TItem* = int64
  TItemSeq* = seq[TItem]
  TItemIterator* = iterator(): TItem

proc file_iterator*(filename: string): TItemIterator =
  result = iterator(): TItem =
    let file = open(filename)
    for line in file.lines:
      yield parseInt(line)
    close(file)

proc seq_iterator*(items: TItemSeq): TItemIterator =
  result = iterator(): TItem =
    for i in items:
      yield i

proc topn*(topn: int, iter: TItemIterator): auto =
  if topn <= 0: raise newException(ValueError, "invalid topn value")
  var items = 0
  # initialize results array with minimum int value
  var results = newSeqWith(topn, low(TItem))
  var min_val = low(TItem)
  for val in iter():
    inc(items)
    # compare the number with the smallest item in the array
    if val > min_val:
      # overwrite the last smallest item in the array
      results[topn - 1] = val
      # sort results in descending order
      results.sort(system.cmp[TItem], Descending)
      # cache the smallest item in array
      min_val = results[topn - 1]
  # shrink array if not enough items
  if items < topn:
    results.setlen(items)
  return (results, items)

proc display_results(results: TItemSeq) =
  for i in 0..high(results):
    echo "{:3d}. {:16d}".fmt(i + 1, results[i])

proc display_stats(topn: int, filename: string, items: int, elapsed: float) =
  let filesize = getFileSize(filename)
  echo ""
  echo " Top n items: {:d}".fmt(topn)
  echo "    Filename: {:s}".fmt(filename)
  echo "Elapsed time: {:.3f} sec".fmt(elapsed)
  echo "       Items: {:s}".fmt(insertSep($items, ','))
  echo " Speed items: {:.2f}M items/sec".fmt(float(items) / elapsed / 1_000_000)
  echo "  Speed size: {:.2f} MB/sec".fmt(float(filesize) / elapsed / 1_000_000)
  if not defined(release):
    echo "Compile mode: debug"

template time_it(actions: stmt): float =
  let start_time = cpuTime()
  actions
  cpuTime() - start_time

proc parse_args(): auto =
  var filename = "numbers.out"
  var topn = 100
  const usageString = unindent """
    Usage: ./readdata -n=<n> -i=<input_file>

    Options:
      -i, --input=<path>  input file
      -n, --topn=<n>      top n items
      -h, --help          print this help"""
  for kind, key, val in getopt():
    case key
    of "n", "topn":  topn = parseInt(val)
    of "i", "input": filename = val
    else: echo usageString; return
  return (topn, filename)

proc main() =
  let (topn, filename) = parse_args()
  let elapsed = time_it do:
    let (results, items) = topn(topn=topn, iter=file_iterator(filename))
  display_results(results)
  display_stats(topn=topn, filename=filename, items=items, elapsed=elapsed)

when isMainModule: main()
