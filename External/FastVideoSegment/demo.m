% Script that gives a demo of the Fast Video Segment algorithm
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

addpath( genpath( '.' ) )

foldername = fileparts( mfilename( 'fullpath' ) );

% The folder where the frames are stored in. Frames should be .jpg files
% and their names should be 8-digit sequential numbers (e.g. 00000001.jpg,
% 00000002.jpg etc)
options.infolder = fullfile( foldername, 'Data', 'inputs', 'animals' );

% The folder where all the outputs will be stored.
options.outfolder = fullfile( foldername, 'Data', 'outputs', 'animals' );

% The optical flow method to be used. Valid names are:
%   broxPAMI2011:     CPU-based optical flow.
%   sundaramECCV2010: GPU-based optical flow. Requires CUDA 5.0
options.flowmethod = 'broxPAMI2011';

% The superpixel oversegmentation method to be used. Valid names are:
%   Turbopixels
%   SLIC
options.superpixels = 'SLIC';

% Create videos of the final segmentation and intermediate results?
options.visualise = true;
% Print status messages on screen
options.vocal = true;

% TODO: add description
options.ranges = [ 1, 33, 48 ];    %   是根据inputs里面的两个不同的文件来决定的，表示的帧的一个范围
options.positiveRanges = [ 1, 2 ];      %表示shot的编号，目前用了两个

% Use default params. For specific value info check inside the function
params = getDefaultParams();

% Create folder to save the segmentation
segmfolder = fullfile( options.outfolder, 'segmentations', 'VideoRapidSegment' );
if( ~exist( segmfolder, 'dir' ) ), mkdir( segmfolder ), end;

for( shot = options.positiveRanges )

    % Load optical flow (or compute if file is not found)
    data.flow = loadFlow( options, shot );
    if( isempty( data.flow ) )
        data.flow = computeOpticalFlow( options, shot );
    end
    
    % Load turbopixels (or compute if not found)
    data.superpixels = loadSuperpixels( options, shot );
    if( isempty( data.superpixels ) )
        data.superpixels = computeSuperpixels( options, shot );
    end
    
    % Cache all frames in memory
    data.imgs = readAllFrames( options, shot );
    
    data.id = shot;
    segmentation = videoRapidSegment( options, params, data );  %保存每一帧的分割结果 cell
    
    % Save output
    filename = fullfile( segmfolder, sprintf( 'segmentationShot%i.mat', shot ) );
    save( filename, 'segmentation', '-v7.3' );
    
end
