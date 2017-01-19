function output = equal_index(tardata,sortdata)

% tardata : this contain standard index (speaker, set, task)
% sortdata : a data is sorted by index of tardata

tarid = [];
if size(tardata,1)~= size(sortdata,1),
    fprintf('Warnnig!!! not eqaulize data size\n');
end
for i=1:size(tardata,1)
   tmpspk = tardata(i,1);
   tmpset = tardata(i,2);
   tmptask = tardata(i,3);
   tarid = [tarid; find(sortdata(:,1)==tmpspk & sortdata(:,2)==tmpset & sortdata(:,3)==tmptask)]; 
    
end

output = sortdata(tarid,:);

end