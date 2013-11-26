
{ zhuyin-mapping } = require './mapping'
{ pinyin-tone } = require './tone'

pinyin-mapping = {}

for key, value of zhuyin-mapping
  pinyin-mapping[value] = key

is-rhymes = (r) ->
  return true if r is 'a' or r is 'e' or r is 'i' or r is 'o' or r is 'u' or r is 'yu' or r is '-'
  return false

is-consonant = (c) ->
  return true if c.match /[a-z]/ and !is-rhymes c
  return false

is-symbol = (s) ->
  return true if s is '˙' or s is 'ˊ' or s is 'ˇ' or s is 'ˋ'
  return false
rhyme-pos = (r) ->
  if is-rhymes r.0
    return r.1 if is-rhymes r.1 and r.length is 3 
    return r.0
  return r.2 if r.match /(jh|sh|ch)/
  return r.1
decode-single-zhuyin = (zhuyin) ->  
  result = []
  tmp = ''
  if zhuyin[zhuyin.length - 1].match /(˙|ˊ|ˇ|ˋ)/
    last-pos = zhuyin.length - 2
  else
    last-pos = zhuyin.length - 1
  for z, i in zhuyin
    if z is 'ㄧ' or z is 'ㄨ' or z is 'ㄩ' 
      if i > 0 and zhuyin[i - 1].match /(ㄐ|ㄑ|ㄒ)/
        z = ''
      if i is last-pos - 1 and !is-symbol zhuyin[i+1] 
        tmp = z + zhuyin[i+1] 
      else 
        tmp = z

    if tmp.length is 0 and zhuyin-mapping[z]
      result.push zhuyin-mapping[z]
    else if i is last-pos and tmp.length > 0
      if tmp is 'ㄧㄛ' or tmp is 'ㄧㄞ' =>
        result.push zhuyin-mapping[tmp]+zhuyin-mapping[z]
      else if !is-symbol z => result.push zhuyin-mapping[tmp]

    if i is zhuyin.length - 1
     switch z
     case '˙' then result.push '0'
     case 'ˊ' then result.push '2'
     case 'ˇ' then result.push '3'
     case 'ˋ' then result.push '4'
     default result.push '1'

  return result

encode-single-pinyin = (proccess-zhuyin) ->
  [ ...proccess, tone] = proccess-zhuyin
  replaced = ''

  for d, i in proccess
    if is-consonant d.0 and proccess-zhuyin.length is 2
      d += 'ih' if d is 'jh' or d is 'ch' or d is 'sh' or d is 'r' or d is 'z' or d is 'c' or d is 's'
    if is-rhymes d.0 and i is 0
      if d.match /^ua/
        d = d.replace 'u', 'w'
      else if d.match /^u/
        d = 'w' + d
      else if d.match /^i/
        if is-rhymes d.1
          d = d.replace 'i', 'y'
        else d = 'y' + d
      else if d.match /^(\-)/
        d = d.replace /(\-)/, 'y'

    if is-rhymes d.0 or d.match /^(y|w|j|c|s|jh|ch|sh|r|z)(a|e|o|i|u)/ 
      rhyme = rhyme-pos d
      r = pinyin-tone.(rhyme).(tone) 
      d = d.replace rhyme, r
    replaced += d
  return replaced

split-multi-zhuyin = (multi-str, mode) ->
  #multi-str = multi-str .replace '　', ' '
  single = ''
  result = []
  if mode is 'symbol'
    sliced = multi-str / /(˙|ˊ|ˇ|ˋ)/
    for s, i in sliced
      single += s
      if is-symbol s or i is sliced.length - 1 
        result.push decode-single-zhuyin single
        single = ''
  else
    sliced = multi-str / ' '
    for s in sliced
      result.push decode-single-zhuyin s
  return result

encode-multi-pinyin = (zhuyins) ->
  result = ''
  for z, i in zhuyins
    result += encode-single-pinyin z
    if i < zhuyins.length - 1
      result += ' '
  return result

#console.log encode-single-pinyin decode-single-zhuyin \ㄧㄚ
#console.log encode-single-pinyin decode-single-zhuyin \ㄉㄧㄚ
#console.log encode-single-pinyin decode-single-zhuyin \ㄤˇ
#console.log encode-single-pinyin decode-single-zhuyin \ㄇㄥˊ
#console.log encode-single-pinyin decode-single-zhuyin \ㄧㄛ
#console.log encode-single-pinyin decode-single-zhuyin \ㄒㄧ
#console.log encode-single-pinyin decode-single-zhuyin \ㄐㄧˋ
#console.log encode-single-pinyin decode-single-zhuyin \ㄆㄧㄥˊ
#console.log encode-multi-pinyin split-multi-zhuyin 'ㄆㄧㄥˊ ㄒㄧ'
#console.log encode-single-pinyin decode-single-zhuyin \ㄅㄨˋ
#console.log encode-single-pinyin decode-single-zhuyin \ㄧㄣ
#console.log encode-single-pinyin decode-single-zhuyin \ㄕˋ
#console.log encode-single-pinyin decode-single-zhuyin \ㄓㄤˇ
#console.log encode-single-pinyin decode-single-zhuyin \ㄗˋ
#console.log encode-single-pinyin decode-single-zhuyin \ㄋㄧㄢˊ
console.log encode-single-pinyin decode-single-zhuyin \ㄡ
#console.log encode-multi-pinyin split-multi-zhuyin 'ㄅㄨˋ ㄧㄣ ㄧ ㄕˋ ㄅㄨˋ ㄓㄤˇ ㄧ ㄓˋ'
#console.log encode-multi-pinyin split-multi-zhuyin 'ㄧ ㄗˋ ㄔㄤˊ ㄕㄜˊ ㄓㄣˋ'
#console.log encode-multi-pinyin split-multi-zhuyin 'ㄔㄥˊ ㄔㄤˊ ㄈㄥ ㄆㄛˋ ㄨㄢˋ ㄌㄧˇ ㄌㄤˋ'
console.log encode-multi-pinyin split-multi-zhuyin 'ㄕˊ ˙ㄍㄜ ㄓˇ ˙ㄊㄡ ㄧㄡˇ ㄔㄤˊ ㄉㄨㄢˇ'
#cconsole.log encode-multi-pinyin split-multi-zhuyin 'ㄅㄨˋ ㄈㄣ ㄋㄢˊ ㄅㄟˇ ㄉㄨㄥ ㄒㄧ ㄅㄨˋ ㄨㄣˋ ㄓㄤ ㄨㄤˊ ㄌㄧˇ ㄓㄠˋ'
console.log encode-multi-pinyin split-multi-zhuyin 'ㄍㄨㄥ ㄐㄧ ㄍㄟˇ ㄏㄨㄤˊ ㄕㄨˇ ㄌㄤˊ ㄅㄞˋ ㄋㄧㄢˊ'