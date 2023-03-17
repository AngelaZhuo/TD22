function res=instantaneousFR(spM,tbins,same,w)
    if ~same
    %     sd=0.5;
        sd=0.2;
        iFR=nan(size(spM,1), size(tbins,1)-1);
        for u=1:size(spM,1)
          %u
          k=find(~isnan(spM(u,:)));
          h0(u)=sd*std(diff(spM(u,k)));
          iFR(u,:)=STtoGfAvg_optim(spM(u,k),tbins,h0(u));
        end
        res.iFR=iFR;
        res.Tmtx=tbins(1:end-1)+mean(diff(tbins))/2;
        res.h=h0;
    else
        iFR=nan(size(spM,1), size(tbins,1)-1);
        for u=1:size(spM,1)
          %u
          h0(u)=w;
          k=find(~isnan(spM(u,:)));
          iFR(u,:)=STtoGfAvg_optim(spM(u,k),tbins,h0(u));
        end
        res.iFR=iFR;
        res.Tmtx=tbins(1:end-1)+mean(diff(tbins))/2;
        res.h=h0;
    end



end
