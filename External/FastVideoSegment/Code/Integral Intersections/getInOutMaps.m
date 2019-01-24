% Function to produce inside-outside maps of a shot given the optical flow
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

function output = getInOutMaps( flow )        %返回一个逻辑矩阵，用0，1来表示一个像素点是否是在物体内部

    frames = length( flow );                  %每一个cell里存储是的每一帧的flow,flow=data.flow
    output = cell( frames, 1 );

    [ height, width, ~ ] = size( flow{ 1 } );   %size(flow{1})返回值如 300 400 2
    
    % Motion boundaries touching the edges will be cut!   
    sideCut = false( height, width );         %在矩阵的四周形成一个边界厚度 20 ，为logical 真
    sideCut( 1: 20, : ) = true;
    sideCut( end - 20: end, : ) = true;
    sideCut( :, 1: 20 ) = true;
    sideCut( :, end - 20: end ) = true;
    
    for( frame = 1: frames )
        boundaryMap = getProbabilityEdge( flow{ frame }, 3 );          %边界图,是概率图么？每个像素点是边界的概率

        inVotes = getInPoints( boundaryMap, sideCut, false );         %返回经过从一个像素点发射出来的射线经过曲线的条数，而来判断一个点是在物体区域与否。
        
        if( getFrameQuality( inVotes > 4 ) < 0.2 )
            boundaryMap = calibrateProbabilityEdge( flow{ frame }, 0.71 );   % auto-calibrate the motion bounds lambda weight，原来是0.7
            inVotes = getInPoints( boundaryMap, sideCut, false );
        end
        
        output{ frame } = inVotes > 4;   %产生一个逻辑矩阵
    end    
    
end
