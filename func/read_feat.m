function output = read_feat(filename,Map_SpkNum)

[fid, message] = fopen(filename);
if fid == -1,
    disp(message);
    disp(filename);
end

featmat = [];
str = fgets(fid);
while str ~= -1
    segStr = regexp(str, '\s', 'split');
    
    tmpmat = [];
    tmpspknum = Map_SpkNum(deblank(segStr{1}));
    tmpset = str2double(segStr{2});
    tmptask = str2double(segStr{3});
    tmpfeat = [];
    for i=4:size(segStr,2)
        if ~isnan(str2double(segStr{i})),
            tmpfeat = [tmpfeat str2double(segStr{i})];
        end
    end
    tmpmat = [tmpspknum tmpset tmptask tmpfeat];
    featmat = [featmat; tmpmat];
    
    str = fgets(fid);
end

output = featmat;
end




%     function output = read_file(filename)
%     para = [];
%     pid = 0;
%     preinfo = '';
% 
% 
%     [fid, message]= fopen(filename); % file open
%     if(fid == -1)
%         disp(message);
%         disp(filename);
%     end
% 
%     str = fgets(fid);
%     while str ~= -1
%         segStr = regexp(str, '\s', 'split');
%         finfo = segStr{1};
%     
%         % save para name : 1st column
%         curinfo = finfo;
%         if isempty(para),
%             pid = pid + 1;
%             para(pid).name = finfo;
%             para(pid).phnary = [];
%             para(pid).durary = [];
%             para(pid).begary = [];
%             preinfo = finfo;        
%         else
%             if ~strcmp(preinfo, curinfo),
%                 pid = pid + 1;
%                 para(pid).name = finfo;
%                 para(pid).phnary = [];
%                 para(pid).durary = [];
%                 para(pid).begary = [];
%                 preinfo = finfo;          
%             end
%         end
%     
%         % save duration array : 3rd column
%         if isempty(para(pid).begary),
%             para(pid).begary = str2double(segStr{3});
%         else
%             para(pid).begary = [para(pid).begary; str2double(segStr{3})];
%         end    
%     
%         % save duration array : 4th column
%         if isempty(para(pid).durary),
%             para(pid).durary = str2double(segStr{4});
%         else
%             para(pid).durary = [para(pid).durary; str2double(segStr{4})];
%         end
%     
%         % save phone array : 5th column
%         if isempty(para(pid).phnary),
%             para(pid).phnary = deblank(segStr{5});
%         else
%             para(pid).phnary = char(para(pid).phnary, deblank(segStr{5}));
%         end
%     
%         str = fgets(fid);
%     end
%     st = fclose(fid);
%     
%     output = para;
% 
%     end