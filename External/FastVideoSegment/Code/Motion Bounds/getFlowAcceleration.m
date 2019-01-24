%function to computer the acceleration of the flow
%created by jxlijunhao@163.com 
%2014/3/21
function accleration= getFlowAcceleration(flow)
    
       if(iscell(flow))
           frameNumber=length(flow);
           accAllFrames=cell(1,frameNumber-1);
           for(i=1:frameNumber-1)
               accFrame(:,:,1)=single(flow{i+1}(:,:,1)-flow{i}(:,:,1));  %���u ����ļ��ٶȣ�
               accFrame(:,:,2)=single(flow{i+1}(:,:,2)-flow{i}(:,:,1));  %���v ����ļ��ٶȣ�
               accAllFrames{i}=sqrt(accFrame(:,:,1).*accFrame(:,:,1)+accFrame(:,:,2).*accFrame(:,:,2));
           end
           accleration=accAllFrames;
       else
           [height,width,~]=size(flow);
           accFrame=zeros(height,width,'single');
           
           if( ~isfloat( flow ) )
            flow = single( flow );
           end
            accFrame(:,:,1)=flow{i+1}(:,:,1)-flow{i}(:,:,1);  %���u ����ļ��ٶȣ�
            accFrame(:,:,2)=flow{i+1}(:,:,2)-flow{i}(:,:,1);  %���v ����ļ��ٶȣ�
            accleration=sqrt(accFrame(:,:,1).*accFrame(:,:,1)+accFrame(:,:,2).*accFrame(:,:,2));
       end

end
