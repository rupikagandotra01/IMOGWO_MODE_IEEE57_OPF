clc
clear all
close all
warning off;

%% PARAMETERS
int_pop_size=50;
no_of_iter=100;
no_of_runs=30;
nbus=57;

%% LOAD DATA
[busdata,gendata,branchdata,costcoeff]=bus_line_data;
Generator_Power_MW=gendata(:,2);

%% DG AND FACTS LIMITS
xfmin=0.2;
xfmax=0.8;
dgmax=100;
vvrmin=0.9;
vvrmax=1.05;

delvrmin=0;
delvrmax=180;

vcrmin=0.9;
vcrmax=1.05;

delcrmin=0;
delcrmax=180;

dgmin=30;
%% SEARCH SPACE
min_val1=1;
max_val1=80;
min_val2=2;
max_val2=50;

min_val3=dgmin;
max_val3=dgmax;

voltage_minimum=0.95;
voltage_maximum=1.08;

data_pass_to_loadflow{1}=voltage_minimum;
data_pass_to_loadflow{2}=voltage_maximum;

data_pass_to_loadflow{11}=costcoeff;

min_val22=costcoeff(:,2);
max_val22=costcoeff(:,3);
%% LOAD LEVEL
for load_percent=[100]

    data_pass_to_loadflow{37}=load_percent;

    [busdata,gendata,branchdata]=bus_line_data;

    load_over=(load_percent/100);

    busdata(:,3)=busdata(:,3)*load_over;

    maxdglimit=sum(busdata(:,3));

    dgmin=30;
    dgmax=maxdglimit;

    min_val3=dgmin;
    max_val3=dgmax;

    %% BASE LOAD FLOW
    finalout=load_flow_normal(data_pass_to_loadflow);
    voltage_normal=finalout{9};
    voltage_angle=finalout{12};
    admittance_data=finalout{13};

    data_pass_to_loadflow{32}=voltage_normal;
    data_pass_to_loadflow{33}=voltage_angle;
    data_pass_to_loadflow{34}=admittance_data;

    %% NUMBER OF DG
    for no_ofdg=1:4

        data_pass_to_loadflow{43}=no_ofdg;

        %% ================= IMOGWO ====================

        IMOGWO_results=[];
for run=1:no_of_runs
        end

        %% WELCH T-TEST

        [h,p,ci,stats]=ttest2(IMOGWO_results,...
            MODE_results,...
            'Vartype','unequal');

        fprintf('\n====================================\n');
        fprintf('IEEE-57 BUS SYSTEM\n');
        fprintf('DG Units = %d\n',no_ofdg);
        fprintf('====================================\n');

        fprintf('IMOGWO Mean = %f\n',mean(IMOGWO_results));
        fprintf('MODE Mean   = %f\n',mean(MODE_results));

        fprintf('IMOGWO STD  = %f\n',std(IMOGWO_results));
        fprintf('MODE STD    = %f\n',std(MODE_results));

        fprintf('t-statistic = %f\n',stats.tstat);
        fprintf('p-value     = %f\n',p);

        %% BOXPLOT
        figure;

        boxplot([IMOGWO_results(:),MODE_results(:)],...
            'Labels',{'IMOGWO','MODE'});

        ylabel('Active Power Loss (MW)');

        title(['IEEE-57 Statistical Analysis ',...
            num2str(no_ofdg),' DG']);

        grid on;

        %% CONVERGENCE
        figure;

        plot(final_conv_IMOGWO,'r','LineWidth',2);
        hold on;

        plot(final_conv_MODE,'b','LineWidth',2);

        xlabel('Iteration');
        ylabel('Objective Function');

        legend('IMOGWO','MODE');

        title(['Convergence Characteristics-',...
            num2str(no_ofdg),' DG']);

        grid on;

        %% STATISTICAL TABLE
        Statistical_Result=table(...
            mean(IMOGWO_results),...
            std(IMOGWO_results),...
            mean(MODE_results),...
            std(MODE_results),...
            p);

        disp(Statistical_Result);

    end
 
