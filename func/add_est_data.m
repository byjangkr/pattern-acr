function out_est_data = add_est_data(ori_data,scorefile,paraOpt,addfile)
% additive matrix for machine learning from new file
% format
% [spkear_index set_index task_index label ori_features new_features...]

indata = ori_data;
useset = paraOpt.set;
featfile = addfile;
scrfile = scorefile;
trannegfeat = paraOpt.tranneg;

% read score file
if isempty(scrfile),
    error('error!! not exist score file name (fnList.scorefile)\n');
else
    fprintf('load score file -> %s\n',scrfile);
    load(scrfile);
end

% read features
add_feat= [];
if size(featfile,1) ~= length(useset),
    error('error!! not equal the set of file and the use_opt of set');
else
   for i=useset
       add_feat = [add_feat; read_feat(deblank(featfile(i,:)),Map_SpkNum)];
   end
end

fprintf('addtive feature : %d - %d\n',(size(indata,2)-3),(size(indata,2)-4+size(add_feat,2)-3));


sorted_add_feat = equal_index(indata,add_feat);
est_data = [indata sorted_add_feat(:,4:end)];

if trannegfeat,
   scr = est_data(:,4);
   for i=5:size(est_data,2)
       tar = est_data(:,i);
       if corr(scr,tar)<0,
           est_data(:,i) = est_data(:,i)*(-1);
       end     
   end
end

out_est_data = est_data;

end