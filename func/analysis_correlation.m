function out_corr = analysis_correlation(indata,feainx)
% print correlation data between each features
% indata : row is each x, column is one value (feature) of x
% featinx : feature index to printing (default : 1 ~ size(indata,2) )
% corr_data : correlation coefficient matrix

anal_data = indata;
if nargin < 2,
    feainx = 1:size(anal_data,2);
end

corr_id = feainx;
corr_result = corrFeature(anal_data);
fprintf('Feat.\t'); fprintf('%d\t',feainx); fprintf('\n');
for i=1:length(corr_id)
    fprintf('%d\t',corr_id(i)); fprintf('%0.2f\t',corr_result(i,:)); fprintf('\n');
end
fprintf('\n');
out_corr = corr_result;

    
  function y = corrFeature(data)
  % correlation of each feature 
  % input
  % data : 
  % task_id : task index for correlation analysis
  % output
  % y : correlation matrix (num_feature*num_feature)
  y = zeros([size(data,2) size(data,2)]);
  feaData = data;

  for feaNum=1:size(feaData,2)
      for j=feaNum:size(feaData,2)
          tempCor = corr(feaData(:,feaNum),feaData(:,j));
          y(feaNum,j) = tempCor;
          y(j,feaNum) = tempCor;
      end
  end

  end

end