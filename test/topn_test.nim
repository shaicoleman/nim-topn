import "../topn", unittest

suite "Test topn":
  test "normal case":
    let (results, items) = topn(topn=3, iter=seq_iterator(@[1'i64,2,3,4,5,6,7,8,9,10]))
    assert results == @[10'i64,9,8]
  test "negative numbers":
    let (results, items) = topn(topn=3, iter=seq_iterator(@[-10'i64,-5,-3,-10,-5]))
    assert results == @[-3'i64,-5,-5]
  test "not enough items":
    let (results, items) = topn(topn=10, iter=seq_iterator(@[1'i64,2,3]))
    assert results == @[3'i64,2,1]
  test "equal amount of items":
    let (results, items) = topn(topn=5, iter=seq_iterator(@[1'i64,1,1,1,1]))
    assert results == @[1'i64,1,1,1,1]
  test "no items":
    let (results, items) = topn(topn=5, iter=seq_iterator(@[]))
    assert results == @[]
  test "invalid topn":
    expect(ValueError):
      let (results, items) = topn(topn=0, iter=seq_iterator(@[1'i64,1,1,1,1]))
