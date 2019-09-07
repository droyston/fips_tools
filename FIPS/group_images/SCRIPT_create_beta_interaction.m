% 2019-06-19 Dylan Royston
%
% First take at creating between-task effect maps
% Adapted from RFX_parametric_analysis from Tim Verstynen
%
% Initial goal: create interactions between Motor_Overt conditions for a given subject (should highlight "hand" area)
%
%
%
%
%%

clear; clc;

source_data_dir =   '/home/dar147/data/VAShare/CovertMapping/data_generated/SUBJECT_DATA_STORAGE/%s/NIFTI/%s';
active_data_dir =   '/home/dar147/data/VAShare/CovertMapping/data_generated/SUBJECT_DATA_STORAGE/%s/BETAS/%s';

% multi-subject
% active_data_dir =   '/home/dar147/data/VAShare/CovertMapping/data_generated/SUBJECT_DATA_STORAGE/multi_subject_betas/motor_overt_fingers';

subject_list =      {'CMC03'};



% MOTOR OVERT
% subject_list =          {'CMC01', 'CMC03', 'CMC04', 'CMC05', 'CMC07', 'CMC10', 'CMC11', 'CMC12', 'CMC13', 'CMC14', 'CMC15', 'CMC17',...
%                         'CMC18', 'CMC19', 'CMC22', 'CMC23', 'CMC24', 'CMC25', 'CMC26', 'CMC27',...
%                         'CMS01', 'CMS02', 'CMS03', 'CMS04', 'CMS07', 'CMS13'};


task_list =         {'Motor_overt'};
con_list =          [2, 3, 4];

num_subjects =      length(subject_list);
num_tasks =         length(task_list);
num_cons =          length(con_list);



%% 2019-07-02: multi-subject basic maps

for task_idx = 1 : num_tasks
    
    for con_idx = 1 : num_cons
        
        
%         if ~exist(active_path); mkdir(active_path); end;
        
        for subj_idx = 1 : num_subjects
            
            
            % load beta-contrast images for specified conditions
            target_path =   sprintf( source_data_dir, subject_list{subj_idx}, task_list{task_idx});
%             active_path =   sprintf( active_data_dir, subject_list{subj_idx}, task_list{task_idx});
            
            contrast_name =         sprintf('con_%4.4i.nii', con_list(con_idx) );
            contrast_filepath =     fullfile( target_path, contrast_name );
            new_filepath =          fullfile( active_path, contrast_name );
            
            % optional file copying
%             eval(sprintf('!cp %s %s', contrast_filepath, new_filepath));
            
            nii =                   load_untouch_nii(new_filepath);
            IMG(:, :, :, subj_idx) = nii.img;
            
        end% FOR con_idx
        
        
        
        % calculate new T-contrast of between-condition effect size
        mIMG =     squeeze(mean(IMG, 4));% mean image
        sIMG =     squeeze(std(IMG, [], 4)./sqrt(size(IMG, 4) ) );% standard error of mean image
        tIMG =     mIMG./sIMG;% t contrast
        pIMG =     1-tcdf( abs(tIMG), size(IMG,4)-1);% p values
        
        % save new contrast files with original header information
        m_nii =     nii;
        m_nii.img = mIMG;
        save_untouch_nii(m_nii, fullfile(active_path,'mean.nii') );
        clearvars mIMG;
        
        s_nii =     nii;
        s_nii.img = sIMG;
        save_untouch_nii(s_nii, fullfile(active_path,'sem.nii') );
        clearvars sIMG;
        
        t_nii =     nii;
        t_nii.img = tIMG;
        save_untouch_nii(t_nii, fullfile(active_path,'T.nii') );
        clearvars tIMG;
        
        p_nii =     nii;
        p_nii.img = pIMG;
        save_untouch_nii(p_nii, fullfile(active_path,'P.nii') );
        
        % memory issues currently
%         q = FDR(pIMG(:), 0.05);
%         q = mafdr(pIMG(:));
        
        
    end% FOR task_idx
    
end% FOR subj_idx


%% subject-specific interaction between "hand"-related Motor_Overt conditions

for subj_idx = 1 : num_subjects
    
    for task_idx = 1 : num_tasks
        
        % load beta-contrast images for specified conditions
        target_path =   sprintf( source_data_dir, subject_list{subj_idx}, task_list{task_idx});
        active_path =   sprintf( active_data_dir, subject_list{subj_idx}, task_list{task_idx});
        
        if ~exist(active_path); mkdir(active_path); end;
        
        for con_idx = 1 : num_cons
            
            contrast_name =         sprintf('con_%4.4i.nii', con_list(con_idx) );
            contrast_filepath =     fullfile( target_path, contrast_name );
            new_filepath =          fullfile( active_path, contrast_name );
            
            % optional file copying
            eval(sprintf('!cp %s %s', contrast_filepath, new_filepath));
            
            nii =                   load_untouch_nii(new_filepath);
            IMG(:, :, :, con_idx) = nii.img;
            
        end% FOR con_idx
        
        
        
        % calculate new T-contrast of between-condition effect size
        mIMG =     squeeze(mean(IMG, 4));% mean image
        sIMG =     squeeze(std(IMG, [], 4)./sqrt(size(IMG, 4) ) );% standard error of mean image
        tIMG =     mIMG./sIMG;% t contrast
        pIMG =     1-tcdf( abs(tIMG), size(IMG,4)-1);% p values
        
        % save new contrast files with original header information
        m_nii =     nii;
        m_nii.img = mIMG;
        save_untouch_nii(m_nii, fullfile(active_path,'mean.nii') );
        clearvars mIMG;
        
        s_nii =     nii;
        s_nii.img = sIMG;
        save_untouch_nii(s_nii, fullfile(active_path,'sem.nii') );
        clearvars sIMG;
        
        t_nii =     nii;
        t_nii.img = tIMG;
        save_untouch_nii(t_nii, fullfile(active_path,'T.nii') );
        clearvars tIMG;
        
        p_nii =     nii;
        p_nii.img = pIMG;
        save_untouch_nii(p_nii, fullfile(active_path,'P.nii') );
        
        % memory issues currently
%         q = FDR(pIMG(:), 0.05);
%         q = mafdr(pIMG(:));
        
        
    end% FOR task_idx
    
end% FOR subj_idx


%% single-subject enrichment effect test
% testing with cmc03 fingers (common hub across enrichments, individual overt-covert pairs)

task_type =   'fingers';

comparisons = {'all-covert', 'overt-covert-pairs'};

num_comps =     length(comparisons);

for subj_idx = 1 : num_subjects
    
    for comp_idx = 1 : num_comps
        
        curr_comp =     comparisons{comp_idx};
        
        switch curr_comp
            case 'all-covert'
                
                con_list =      [1 2 3 4];
                num_cons =      length(con_list);
                
                task_name =     'Motor_covert_fingers';
                
                % load beta-contrast images for specified conditions
                target_path =   sprintf( source_data_dir, subject_list{subj_idx}, task_name);
                active_path =   sprintf( active_data_dir, subject_list{subj_idx}, [task_type '_' curr_comp]);
                
                
                if ~exist(active_path); mkdir(active_path); end;
                
                for con_idx = 1 : num_cons
                    
                    contrast_name =         sprintf('con_%4.4i.nii', con_list(con_idx) );
                    contrast_filepath =     fullfile( target_path, contrast_name );
                    new_filepath =          fullfile( active_path, contrast_name );
                    
                    % optional file copying
                    eval(sprintf('!cp %s %s', contrast_filepath, new_filepath));
                    
                    nii =                   load_untouch_nii(new_filepath);
                    IMG(:, :, :, con_idx) = nii.img;
                    
                end% FOR con_idx
                
                
                % calculate new T-contrast of between-condition effect size
                mIMG =     squeeze(mean(IMG, 4));% mean image
                sIMG =     squeeze(std(IMG, [], 4)./sqrt(size(IMG, 4) ) );% standard error of mean image
                tIMG =     mIMG./sIMG;% t contrast
                pIMG =     1-tcdf( abs(tIMG), size(IMG,4)-1);% p values
                
                % save new contrast files with original header information
                m_nii =     nii;
                m_nii.img = mIMG;
                save_untouch_nii(m_nii, fullfile(active_path,'mean.nii') );
                clearvars mIMG;
                
                s_nii =     nii;
                s_nii.img = sIMG;
                save_untouch_nii(s_nii, fullfile(active_path,'sem.nii') );
                clearvars sIMG;
                
                t_nii =     nii;
                t_nii.img = tIMG;
                save_untouch_nii(t_nii, fullfile(active_path,'T.nii') );
                clearvars tIMG;
                
                p_nii =     nii;
                p_nii.img = pIMG;
                save_untouch_nii(p_nii, fullfile(active_path,'P.nii') );
                
            case 'overt-covert pairs'
                
                
                
                
                
                
                con_list =      [1 2 3 4];
                num_cons =      length(con_list);
                
                overt_name =      'Motor_overt';
                covert_name =     'Motor_covert_fingers';
                
                % load beta-contrast images for specified conditions                
                active_path =   sprintf( active_data_dir, subject_list{subj_idx}, [task_type '_' curr_comp]);
                if ~exist(active_path); mkdir(active_path); end;
                
                
                overt_path =   sprintf( source_data_dir, subject_list{subj_idx}, overt_name);
                
                contrast_name =         sprintf('con_%4.4i.nii', 4 );
                contrast_filepath =     fullfile( overt_path, contrast_name );
                new_filepath =          fullfile( active_path, 'overt_con_0004.nii' );
                
                % optional file copying
                eval(sprintf('!cp %s %s', contrast_filepath, new_filepath));
                
                nii =                   load_untouch_nii(new_filepath);
                IMG(:, :, :, 1) =       nii.img;
                    
                    
                    
                    
                
                for con_idx = 1 : num_cons
                    
                    contrast_name =         sprintf('con_%4.4i.nii', con_list(con_idx) );
                    contrast_filepath =     fullfile( target_path, contrast_name );
                    new_filepath =          fullfile( active_path, contrast_name );
                    
                    % optional file copying
                    eval(sprintf('!cp %s %s', contrast_filepath, new_filepath));
                    
                    nii =                   load_untouch_nii(new_filepath);
                    IMG(:, :, :, 2) =       nii.img;
                    
                    
                    
                    % calculate new T-contrast of between-condition effect size
                    mIMG =     squeeze(mean(IMG, 4));% mean image
                    sIMG =     squeeze(std(IMG, [], 4)./sqrt(size(IMG, 4) ) );% standard error of mean image
                    tIMG =     mIMG./sIMG;% t contrast
                    pIMG =     1-tcdf( abs(tIMG), size(IMG,4)-1);% p values
                    
                    % save new contrast files with original header information
                    m_nii =     nii;
                    m_nii.img = mIMG;
                    save_untouch_nii(m_nii, fullfile(active_path, [num2str(con_idx) '_mean.nii']) );
                    clearvars mIMG;
                    
                    s_nii =     nii;
                    s_nii.img = sIMG;
                    save_untouch_nii(s_nii, fullfile(active_path,[num2str(con_idx) '_sem.nii']) );
                    clearvars sIMG;
                    
                    t_nii =     nii;
                    t_nii.img = tIMG;
                    save_untouch_nii(t_nii, fullfile(active_path,[num2str(con_idx) '_T.nii']) );
                    clearvars tIMG;
                    
                    p_nii =     nii;
                    p_nii.img = pIMG;
                    save_untouch_nii(p_nii, fullfile(active_path,[num2str(con_idx) '_P.nii']) );
                    
                end% FOR con_idx
                
                
                
                
                
                
                
        end% SWITCH curr_comp
        
        
        
        
        
        
        
        
        
        % load beta-contrast images for specified conditions
        target_path =   sprintf( source_data_dir, subject_list{subj_idx}, task_list{comp_idx});
        active_path =   sprintf( active_data_dir, subject_list{subj_idx}, task_list{comp_idx});
        
        if ~exist(active_path); mkdir(active_path); end;
        
        for con_idx = 1 : num_cons
            
            contrast_name =         sprintf('con_%4.4i.nii', con_list(con_idx) );
            contrast_filepath =     fullfile( target_path, contrast_name );
            new_filepath =          fullfile( active_path, contrast_name );
            
            % optional file copying
            eval(sprintf('!cp %s %s', contrast_filepath, new_filepath));
            
            nii =                   load_untouch_nii(new_filepath);
            IMG(:, :, :, con_idx) = nii.img;
            
        end% FOR con_idx
        
        
        
        % calculate new T-contrast of between-condition effect size
        mIMG =     squeeze(mean(IMG, 4));% mean image
        sIMG =     squeeze(std(IMG, [], 4)./sqrt(size(IMG, 4) ) );% standard error of mean image
        tIMG =     mIMG./sIMG;% t contrast
        pIMG =     1-tcdf( abs(tIMG), size(IMG,4)-1);% p values
        
        % save new contrast files with original header information
        m_nii =     nii;
        m_nii.img = mIMG;
        save_untouch_nii(m_nii, fullfile(active_path,'mean.nii') );
        clearvars mIMG;
        
        s_nii =     nii;
        s_nii.img = sIMG;
        save_untouch_nii(s_nii, fullfile(active_path,'sem.nii') );
        clearvars sIMG;
        
        t_nii =     nii;
        t_nii.img = tIMG;
        save_untouch_nii(t_nii, fullfile(active_path,'T.nii') );
        clearvars tIMG;
        
        p_nii =     nii;
        p_nii.img = pIMG;
        save_untouch_nii(p_nii, fullfile(active_path,'P.nii') );
        
        % memory issues currently
%         q = FDR(pIMG(:), 0.05);
%         q = mafdr(pIMG(:));
        
        
    end% FOR task_idx
    
end% FOR subj_idx


















