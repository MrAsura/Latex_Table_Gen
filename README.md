# Latex_Table_Gen
Matlab function for generating latex tables

Returns latex table code for the array assembled from the chunks given.
  
Chunks:
---------
  makeLatexTable('chunk', pos, data, ...)
  * pos: 1-by-2 matrix. datas position in the table. Indexs where the first
  * value in data is put.
  * data: m-by-n matrix of data
  
Style:
------  
  makeLatexTable('style', cols, ...)
  * cols: a string containing the columstyle to be used. Must contain as many
  * colums a the chunks form. E.g '|c|c|'
  
Span:
------
  makeLatexTable('span', area, cols, content, ...)
  * area: a 1-by-3 matrix ([m n w]) that gives the row(m) and column(n),
  where the span begins and the column(w) it ends in. Span can only be a
  single line. Content is spread over the area.
  * cols: a string containing the columstyle to be used. Must contain as many
  colums a the chunks form. E.g '|c|'
  * content: string of what to span.
  
Vlines:
------
  makeLatexTable('vlines', columns, span, style)
  * columns: columns the style is applied. Takes a 1-by-n
  * span: rows the vertical line spans. [s e] where s is the start row and e
  the last row
  * style: the style applied to line eg. '|c|'
  (apply after data)
 
HLines:
------
  makeLatexTable('hlines', rows, ...)
  * rows: defines rows([r1,r2,...rp]) for witch horizontal lines should be
  inserted.
  
CLines:
------
  makeLatexTable('clines', rows, span, ...)
  * rows: defines rows([r1,r2,...rp]) for witch horizontal lines should be
  inserted.
  * span: defines columnrange witch the line should span [i j].
