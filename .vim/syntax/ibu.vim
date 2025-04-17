
if exists("b:current_syntax")
  finish
endif

" Language keywords
syntax keyword ibuKeywords func struct let if else switch case while goto return for

" Comments
syntax region ibuCommentLine start="//" end="$"

" String literals
syntax region ibuString start=/\v"/ skip=/\v\\./ end=/\v"/ contains=ibuEscapes

" Char literals
syntax region ibuChar start=/\v'/ skip=/\v\\./ end=/\v'/ contains=ibuEscapes

" Escape literals \n, \r, ....
syntax match ibuEscapes display contained "\\[nr\"']"

" Set highlights
highlight default link ibuKeywords Keyword
highlight default link ibuCommentLine Comment
highlight default link ibuString String
highlight default link ibuChar Character
highlight default link ibuEscapes SpecialChar

let b:current_syntax = "ibu"

