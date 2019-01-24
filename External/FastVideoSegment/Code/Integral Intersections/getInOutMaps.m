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

function output = getInOutMaps( flow )        %����һ���߼�������0��1����ʾһ�����ص��Ƿ����������ڲ�

    frames = length( flow );                  %ÿһ��cell��洢�ǵ�ÿһ֡��flow,flow=data.flow
    output = cell( frames, 1 );

    [ height, width, ~ ] = size( flow{ 1 } );   %size(flow{1})����ֵ�� 300 400 2
    
    % Motion boundaries touching the edges will be cut!   
    sideCut = false( height, width );         %�ھ���������γ�һ���߽��� 20 ��Ϊlogical ��
    sideCut( 1: 20, : ) = true;
    sideCut( end - 20: end, : ) = true;
    sideCut( :, 1: 20 ) = true;
    sideCut( :, end - 20: end ) = true;
    
    for( frame = 1: frames )
        boundaryMap = getProbabilityEdge( flow{ frame }, 3 );          %�߽�ͼ,�Ǹ���ͼô��ÿ�����ص��Ǳ߽�ĸ���

        inVotes = getInPoints( boundaryMap, sideCut, false );         %���ؾ�����һ�����ص㷢����������߾������ߵ������������ж�һ�������������������
        
        if( getFrameQuality( inVotes > 4 ) < 0.2 )
            boundaryMap = calibrateProbabilityEdge( flow{ frame }, 0.71 );   % auto-calibrate the motion bounds lambda weight��ԭ����0.7
            inVotes = getInPoints( boundaryMap, sideCut, false );
        end
        
        output{ frame } = inVotes > 4;   %����һ���߼�����
    end    
    
end
