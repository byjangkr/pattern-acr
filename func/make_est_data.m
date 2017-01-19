function out_est_data = make_est_data(featfile,scorefile,paraOpt)

% make matrix for machine learning from est database
% format
% [spkear_index set_index task_index label features... ]

scoretype = paraOpt.scoretype;
scrfile = scorefile;
flufeatfile = featfile;
useset = paraOpt.set;
scoretypeinx = paraOpt.scoretypeinx;
trannegfeat = paraOpt.tranneg;

% read score file
if isempty(scrfile),
    error('error!! not exist score file name (fnList.scorefile)\n');
else
    fprintf('load score file -> %s\n',scrfile);
    load(scrfile);
end

% read features
flu_feat= [];
if size(flufeatfile,1) ~= length(useset),
    error('error!! not equal the set of file and the use_opt of set');
else
   for i=useset
       flu_feat = [flu_feat; read_feat(deblank(flufeatfile(i,:)),Map_SpkNum)];
   end
end

fprintf('fluency feature : %d - %d\n',1,size(flu_feat(:,4:end),2));

est_data = [];
if strcmp(scoretype,'level'),
    if scoretypeinx==1,
        for i=1:size(flu_feat,1)
            est_data = [est_data; flu_feat(i,1:3) Map_SpkLev(flu_feat(i,1)) flu_feat(i,4:end)]; 
        end
    else
        sorted_task_lev = equal_index(flu_feat,task_lev);
        est_data = [flu_feat(:,1:3) sorted_task_lev(:,4) flu_feat(:,4:end)]; 
    end
elseif strcmp(paraOpt.scoretype,'rubric'),
    sorted_score = equal_index(flu_feat,score);
    if scoretypeinx == 0,        
        est_data = [flu_feat(:,1:3) mean(sorted_score(:,4:end),2) flu_feat(:,4:end)];
    else
        sorted_score = [flu_feat(:,1:3) sorted_score(:,scoretypeinx+3) flu_feat(:,4:end)];
    end
    
else
    error('error !!! not exist score type : %s\n',paraOpt.scoretype);
    
end

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