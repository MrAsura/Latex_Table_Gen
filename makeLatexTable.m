function code = makeLatexTable(varargin)
% Returns latextable code for the array assembled from the chunks given.
% 
% Chunks:
% makeLatexTable('chunk', pos, data, ...)
% pos: 1-by-2 matrix. datas position in the table. Indexs where the first
% value in data is put.
% data: m-by-n matrix of data
% 
% Style:
% makeLatexTable('style', cols, ...)
% cols: a string containing the columstyle to be used. Must contain as many
% colums a the chunks form. E.g '|c|c|'
% 
% Span:
% makeLatexTable('span', area, cols, content, ...)
% area: a 1-by-3 matrix ([m n w]) that gives the row(m) and column(n),
% where the span begins and the column(w) it ends in. Span can only be a
% single line. Content is spread over the area.
% cols: a string containing the columstyle to be used. Must contain as many
% colums a the chunks form. E.g '|c|'
% content: string of what to span.
% 
% Vlines:
% makeLatexTable('vlines', columns, span, style)
% columns: columns the style is applied. Takes a 1-by-n
% span: rows the vertical line spans. [s e] where s is the start row and e
% the last row
% style: the style applied to line eg. '|c|'
% (apply after data)
%
% HLines:
% makeLatexTable('hlines', rows, ...)
% rows: defines rows([r1,r2,...rp]) for witch horizontal lines should be
% inserted.
% 
% CLines:
% makeLatexTable('clines', rows, span, ...)
% rows: defines rows([r1,r2,...rp]) for witch horizontal lines should be
% inserted.
% span: defines columnrange witch the line should span [i j].

C = cell(1); %user added data
Mod = cell(1); %modifiers such as hcline and span
varInd = 1;

CSEP = '&'; %seperator for columns
LSEP = '\\'; %line seperator
TBEG = @(s) ['\begin{tabular}{' s '}']; %begin command for tabular
TEND = '\end{tabular}';
HLINE = '\hline'; %hline command
CLINE = @(first,last) ['\cline{' num2str(first) '-' num2str(last) '}']; 
SPAN = @(w,s,c) ['\multicolumn{' w '}{' s '}{' c '}'];
PREC = 5; %How many digits to have
multilines = []; %idices for spanned cells
num2strWrap = @(C) num2str(C,PREC); %wrapper to incude precission

while varInd < nargin
   switch varargin{varInd}
       case 'chunk'
           pos = varargin{varInd+1};
           data = varargin{varInd+2};
           varInd = varInd + 3;
           [m,n] = size(data); %dimensions of data array
           %Check if array or cell
           if isnumeric(data)
               temp = cellfun(num2strWrap, num2cell(data), 'UniformOutput', false );
           else
               temp = data;
           end
           C(pos(1):pos(1)+m-1,pos(2):pos(2)+n-1) = temp;
           
       case 'style'
           style = varargin{varInd + 1};
           varInd = varInd + 2;
           
       case 'span'
           area = varargin{varInd + 1};
           m = area(1); n = area(2); w = area(3);
           cols = varargin{varInd + 2};
           content  = varargin{varInd + 3};
           if ~ischar(content)
               content = char(content);
           end
           varInd = varInd + 4;
           
           if any( size(Mod) < [m n] )
               Mod{m,n} = '';
           end
           Mod{m,n} = joiner(Mod{m,n},(SPAN(num2str(w),cols,content)));

           if w > 1
               multilines = [multilines [ones(1,w)*m ; (n):(n+w-1)]]; %#ok<AGROW>
           end
           
       case 'vlines'
           columns = varargin{varInd + 1};
           span = varargin{varInd + 2};
           start = span(1); stop = span(2);
           linestyle = varargin{varInd + 3};
           varInd = varInd + 4;
           
           if any([stop max(columns)] > size(Mod))
               Mod{stop,max(columns)} = '';
           end
           
           for col = columns
               for row = start:stop
                   cont = '';
                   if all( size(C) >= [row,col] )
                       cont = C{row,col};
                       C{row,col} = '';
                   end
                   Mod{row,col} = joiner(Mod{row,col}, (SPAN(num2str(1),linestyle,cont)));
               end
           end
           
       case 'hlines'
           
           if size(Mod,1) < max((varargin{varInd + 1}))
               Mod{max((varargin{varInd + 1})),size(Mod,2)} = [];
           end
           for i = drange(varargin{varInd + 1})
               Mod{i,1} = joiner(HLINE,Mod{i,1});
           end
           varInd = varInd + 2;
           
       case 'clines'
           rows = varargin{varInd + 1};
           sp = varargin{varInd + 2};
           varInd = varInd + 3;
           
           for i = drange(rows)
               Mod{i,1} = joiner(CLINE(sp(1),sp(1,2)),Mod{i,1});
           end
           
       otherwise
           error('Invalid input')
   end
end

[m1, n1] = size(C);
[m2, n2] = size(Mod);

Msize = max([m1 m2]) + 1;
Nsize = max([n1 n2]);

C{Msize,Nsize} = [];
C{Msize,1} = HLINE;
Mod{Msize,Nsize} = [];

% cell array with seperators
Sep = repmat({CSEP},Msize,Nsize);
Sep(Msize,:) = cell(1,Nsize);

% remove column separators from spanned cells.
if size(multilines) ~= size([])
    Sep( sub2ind(size(Sep),multilines(1,:),multilines(2,:)) ) = repmat({' '}, 1, size(multilines,2));
end

% Add line separators
Sep(:,Nsize) = [repmat({LSEP},Msize-1,1) ; {[]}];

%for joining the M and C
Final = cellfun(@joiner, Mod, C, Sep, 'UniformOutput', false);

code = cell(Msize,1);

for ind = drange(1:Msize)
    help = Final(ind,:);
    code{ind} = strjoin( help );
end

% disp(TBEG(style));
% disp(C);
% disp(Mod);

code = strjoin([{TBEG(style)} {strjoin(code,'\n')} {TEND}],'\n');

end

function J = joiner( varargin )
% Helperfunction for joining n number of (char)elements into one (cell)
J = cell(1,nargin);
for ind = drange(1:nargin)
    if ischar(varargin{ind})
        new = varargin{ind};
    else
        new = '';
    end
    J{ind} = new;
end

J = strjoin(J);

end

