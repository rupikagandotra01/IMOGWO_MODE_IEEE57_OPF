function [Best_pos,final_conv,pdata]=IMOGWO_algorithm(...
    nbus,int_pop_size,no_of_iter,...
    min_val22,max_val22,...
    min_val1,max_val1,...
    min_val2,max_val2,...
    min_val3,max_val3,...
    xfmin,xfmax,...
    vvrmin,vvrmax,...
    delvrmin,delvrmax,...
    vcrmin,vcrmax,...
    delcrmin,delcrmax,...
    data_pass_to_loadflow)

SearchAgents_no=int_pop_size;

dim=length(min_val22)+5;

lb=[min_val22' min_val1 min_val2 min_val3 xfmin];
ub=[max_val22' max_val1 max_val2 max_val3 xfmax];

%% INITIALIZATION
Positions=zeros(SearchAgents_no,dim);

for i=1:SearchAgents_no
    for j=1:dim
        Positions(i,j)=lb(j)+rand()*(ub(j)-lb(j));
    end
end

%% OBL
Opp_Positions=zeros(size(Positions));

for i=1:SearchAgents_no
    for j=1:dim
        Opp_Positions(i,j)=lb(j)+ub(j)-Positions(i,j);
    end
end
Opp_Positions=max(Opp_Positions,lb);
Opp_Positions=min(Opp_Positions,ub);

fitness=zeros(SearchAgents_no,2);

for i=1:SearchAgents_no

    [f1,f2]=multiobjective_function(...
        Positions(i,:),data_pass_to_loadflow);

    [fo1,fo2]=multiobjective_function(...
        Opp_Positions(i,:),data_pass_to_loadflow);

    fit=[f1 f2];
    fito=[fo1 fo2];

    if dominates(fito,fit)
        Positions(i,:)=Opp_Positions(i,:);
        fitness(i,:)=fito;
    else
        fitness(i,:)=fit;
    end

end
rank=non_dominated_sorting(fitness);

[~,idx]=sort(rank);

Alpha_pos=Positions(idx(1),:);
Beta_pos=Positions(idx(2),:);
Delta_pos=Positions(idx(3),:);

for iter=1:no_of_iter

    a=2-iter*(2/no_of_iter);

    for i=1:SearchAgents_no

        for j=1:dim

            r1=rand();
            r2=rand();

            A1=2*a*r1-a;
            C1=2*r2;

            D_alpha=abs(C1*Alpha_pos(j)-Positions(i,j));
            X1=Alpha_pos(j)-A1*D_alpha;

            r1=rand();
            r2=rand();

            A2=2*a*r1-a;
            C2=2*r2;

            D_beta=abs(C2*Beta_pos(j)-Positions(i,j));
            X2=Beta_pos(j)-A2*D_beta;

            r1=rand();
            r2=rand();

            A3=2*a*r1-a;
            C3=2*r2;

            D_delta=abs(C3*Delta_pos(j)-Positions(i,j));
            X3=Delta_pos(j)-A3*D_delta;
 Positions(i,j)=(X1+X2+X3)/3;

        end
    end

    Positions=max(Positions,lb);
    Positions=min(Positions,ub);

    for i=1:SearchAgents_no

        [f1,f2]=multiobjective_function(...
            Positions(i,:),data_pass_to_loadflow);

        fitness(i,:)=[f1 f2];

    end

    rank=non_dominated_sorting(fitness);

    [~,idx]=sort(rank);

    Alpha_pos=Positions(idx(1),:);
    Beta_pos=Positions(idx(2),:);
    Delta_pos=Positions(idx(3),:);

    final_conv(iter)=fitness(idx(1),1);

end

Best_pos=Alpha_pos;
pdata=fitness;

end
