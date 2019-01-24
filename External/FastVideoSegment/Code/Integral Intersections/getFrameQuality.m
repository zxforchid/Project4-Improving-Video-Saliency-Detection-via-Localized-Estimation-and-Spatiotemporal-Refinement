% Computes a quality value for the given inside-outside map based on size and
% compactness
%
%    Copyright (C) 2013  Anestis Papazoglou
%
%    You can redistribute and/or modify this software for non-commercial use
%    under the terms of the GNU General Public License as published by
%    the Free Software Foundation, either version 3 of the License, or
%    (at your option) any later version.
%
%    This program is distributed in the hope that it will be useful,
%    but WITHOUT ANY WARRANTY; without even the implied warranty of
%    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%    GNU General Public License for more details.
%
%    You should have received a copy of the GNU General Public License
%    along with this program.  If not, see <http://www.gnu.org/licenses/>.
%
%    For commercial use, contact the author for licensing options.
%
%    Contact: a.papazoglou@sms.ed.ac.uk

function quality = getFrameQuality( frame )

    % Note: A good frame is one that has a single, high confidence blob

    [ height, width ] = size( frame );
    
    data = reshape( frame, [], 1 );  %将矩阵重新排成一列
    quality = sum( data );
    
    if( quality == 0 ), return, end;
    
    rowId = 1: height;
    columnId = 1: width;
    
    rowId = bsxfun( @times, ones( size( frame ) ),  rowId' );     %返回 height*width 大小矩阵，每一行都是相同的行号
    columnId = bsxfun( @times, ones( size( frame ) ),  columnId );%返回 height*width 大小矩阵，每一列都是相同的列号
    
    x = reshape( frame .* rowId, [], 1 );                       %将满足条件的坐标点的标出相应的横坐标
    y = reshape( frame .* columnId, [], 1 );                    %将满足条件的坐标点的标出相应的纵坐标
    
    meanx = sum( x ) / quality;                                 %区域的平均坐标
    meany = sum( y ) / quality;
    
    x = reshape( ( rowId - meanx ), [], 1 );
    y = reshape( ( columnId - meany ), [], 1 );
    
    varx = ( data .* x )' * x / quality;                         %区域的坐标方差
    vary = ( data .* y )' * y / quality;
    
    %keyboard
    
    variability = sqrt( varx * varx + vary * vary );
    
    if( variability == 0 ), quality = 0; return, end
    
    quality = quality / ( variability ^ 2 );
    
end
