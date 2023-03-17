function Matrices = OrderSessions_ifr_pupil(PVdirectory, ID)
    create = 0;
    if ~exist(PVdirectory + "/Session_ifr", "dir")
        mkdir(PVdirectory + "/Session_ifr")
    end
    if exist(PVdirectory + "/Session_ifr/OrderedSessions_ifr_" + num2str(ID) + ".mat", "file")
        load(PVdirectory + "/Session_ifr/OrderedSessions_ifr_" + num2str(ID) + ".mat")
    else
        load(PVdirectory + "/PVsmall/PVsmall_" + num2str(ID) + ".mat")
        create = 1;
        fileName = "/Session_ifr/OrderedSessions_ifr_" + num2str(ID) + "";
    end
    "Bins contain instantaneous firing rates (Hz) sample"
        
    if create ~= 0
        Regions = ["NAcAnt", "NAcPost", "TuAnt", "TuPost", "VTAdan"];
        Code = [1, 1, 2, 2, 3];
        Ant = [1, 0, 1, 0, 0];
        pvid = [PVsmall.clu_info.PVid];
        did = [PVsmall.clu_info.unit_nr_d];
        mirko_session = [PVsmall.clu_info.mirko_counter];
        region = [PVsmall.clu_info.region_coding];
        antshift =[PVsmall.clu_info.antshift];
        fr = [PVsmall.clu_info.mean_firing_rate];
        DANr = [PVsmall.clu_info.funcDAN_reward] | [PVsmall.clu_info.funcDAN_odorcue] | [PVsmall.clu_info.funcDAN_rewardcue];
    end
    
    if create == 1
        EndTime = 16.8; % in seconds
        OC_time = [PVsmall.info.trial_timing.OC(1), PVsmall.info.trial_timing.OC(2)]/1000;
        Jitter_time = (PVsmall.info.pre(1)+PVsmall.info.post(1))/1000;
        RC_time = [PVsmall.info.pre(1)+PVsmall.info.post(1) + PVsmall.info.trial_timing.RC(1), PVsmall.info.pre(1)+PVsmall.info.post(1) + PVsmall.info.trial_timing.RC(2)]/1000;
        R_time = (PVsmall.info.pre(1)+PVsmall.info.post(1) + PVsmall.info.trial_timing.R)/1000;
        XEvents = [OC_time, Jitter_time, RC_time, R_time, EndTime]*10; XEvents(1:end-1) = XEvents(1:end-1)+1;
        XstartTick = PVsmall.info.timex_overlap{1,1}; XstartTick = XstartTick(1,1);
        
        for teil = 1:numel(Regions)
            if teil ~= 5
                UnitIndex = (region == Code(teil)) & (antshift == Ant(teil)) & (fr < 5); UnitIndex = find(UnitIndex);
            else
                UnitIndex = (region == Code(teil)) & (antshift == Ant(teil)) & (fr > 1) & (fr < 12) & DANr; 
                UnitIndex = find(UnitIndex);
            end
            Matrices.(Regions{teil}).matrix =[];
            Matrices.(Regions{teil}).trialMatrix =[];
            Matrices.(Regions{teil}).jitter = [];
            Matrices.(Regions{teil}).unitPVid = [];
            Matrices.(Regions{teil}).unitDid = [];
            Matrices.(Regions{teil}).mirko_session = [];
            Matrices.(Regions{teil}).spk_rmv = [];
            Matrices.(Regions{teil}).mouse = [""];
            Matrices.(Regions{teil}).tetrode = [""];
            Matrices.(Regions{teil}).events = XEvents;
            % Matrix creation loop:
            Neurons = numel(UnitIndex);
            if Neurons == 0
                continue
            end
            for u = 1:Neurons
                Cell = PVsmall.spikes(UnitIndex(u));
                spM = Cell{1};
                % spM is your spike time array
                skipper = int64(0);
                deleter = [];
                for spike = 1:numel(spM)-1
                    if skipper > 0; skipper = skipper-1; continue; end
                    for nxt = spike+1:numel(spM)
                        if spM(nxt) < (spM(spike)+.002)
                            skipper = skipper+1;
                            deleter = cat(1, deleter, nxt);
                        else
                            break
                        end
                    end
                end
                spM(deleter) = [];

                Session = PVsmall.map(pvid(UnitIndex(u))); Session = PVsmall.events(Session); Session = Session{1};
                Trials = size(Session, 2); % Compare with PVsmall.TrialMatrix(UnitIndex(u), :, :);
                TotalTime = Session(Trials).reward_time + 10;
                BinSize = .100; %Seconds
                
                spM(spM>TotalTime) = [];
                tbins = (0:BinSize:TotalTime)';
                IFR = instantaneousFR(spM, tbins, 1, .15); % (spM, tbins, same, w)
                for tr = 1:Trials
                    % 2-second Baseline; 20 bins of .100s 
                    Bins1 = int64(Session(tr).fv_on_odorcue/BinSize-1) - 2/BinSize :int64(Session(tr).fv_on_odorcue/BinSize-1); Bins1 = Bins1(end-int64(2/BinSize)+1:end);
                    % CS1 plus 1.2 seconds; 24 bins of .100s
                    Bins2 = Bins1(end)+1 : Bins1(end)+1 + 2.4/BinSize; Bins2 = Bins2(1:int64(2.4/BinSize));
                    % 1.2s before CS2; 12 bins of .100s
                    Bins3 = int64(Session(tr).fv_on_rewcue/BinSize-1) - 2/BinSize :int64(Session(tr).fv_on_rewcue/BinSize-1); Bins3 = Bins3(end-int64(1.1/BinSize):end);
                    % CS2, Reward and 8s afrer Reward; 112 bins of .100s
                    Bins4 = Bins3(end)+1 : Bins3(end)+1 + int64(11.2/BinSize); Bins4 = Bins4(1:int64(11.2/BinSize));
                    
                    Matrices.(Regions{teil}).matrix(u, :, tr) = IFR.iFR([Bins1, Bins2, Bins3, Bins4]);
                    Matrices.(Regions{teil}).jitter(u, tr) = Session(tr).jitter_OC_RC;
                end
                Matrices.(Regions{teil}).mouse(u, 1) = string(PVsmall.clu_info(UnitIndex(u)).animal);
                Matrices.(Regions{teil}).tetrode(u, 1) = string(PVsmall.clu_info(UnitIndex(u)).tetrode);
                Matrices.(Regions{teil}).spk_rmv(u, 1) = numel(deleter);
                
            end
            Matrices.(Regions{teil}).trialMatrix = PVsmall.TrialMatrix(UnitIndex, :, :);
            Matrices.(Regions{teil}).unitPVid =  pvid(1,UnitIndex)';
            Matrices.(Regions{teil}).unitDid =  did(1,UnitIndex)';
            Matrices.(Regions{teil}).mirko_session =  mirko_session(1,UnitIndex)';
            Matrices
        end
         save(PVdirectory + fileName, "Matrices");
    end  
    
end

