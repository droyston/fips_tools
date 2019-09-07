% List of open inputs
nrun = X; % enter the number of runs here
jobfile = {'R:\data_generated\human\covert_mapping\CM Analysis Tools\Batches\CM_indiv_smooth_new_auto_job.m'};
jobs = repmat(jobfile, 1, nrun);
inputs = cell(0, nrun);
for crun = 1:nrun
end
spm('defaults', 'FMRI');
spm_jobman('run', jobs, inputs{:});
