1,输入必须是float的，否则要将其转为float,
  I=single(I);

2,I必须是2-band,即I(:,:,1)  I(:,:,2)

3,将输入I中的数据写入到 .flo文件中
  writeFlowFile(I,'flow.flo');

4,img=readFlowFile('flow.flo');

5,img=flowToColor(img);

6,imshow(img)
