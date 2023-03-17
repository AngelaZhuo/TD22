function Matrices = OrderSessions_pupil(Structure_directory, ID)
    create = 0;
    if ~exist(Structure_directory + "/Session_pupil", "dir")
        mkdir(Structure_directory + "/Session_pupil")
    end
    if exist(Structure_directory + "/Session_pupil/OrderedSessions_pupil_" + num2str(ID) + ".mat", "file")
        load(Structure_directory + "/Session_pupil/OrderedSessions_pupil_" + num2str(ID) + ".mat")
        "loading: Bins contain pupil diameter samples"
    elseif exist(Structure_directory + "/PVsmall/PVsmall_" + num2str(ID) + ".mat")
        load(Structure_directory + "/PVsmall/PVsmall_" + num2str(ID) + ".mat")
        create = 1;
        fileName = "/Session_pupil/OrderedSessions_pupil_" + num2str(ID) + "";
        "creating: Bins contain pupil diameter samples"
    else
        Matrices.Pupil.trialMatrix =[];
        "No data"
    end
        
    if create ~= 0
        Regions = ["Pupil"];
        mirko_session = double([PVsmall.info.session_count])/double(3);
        Mice = size(PVsmall.pupil, 2);
    end
    
    if create == 1
        EndTime = 16.8; % in seconds
        OC_time = [2.1, 3.3];
        Jitter_time = 4.5;
        RC_time = [5.7, 6.9];
        R_time = 8.1;
        XEvents = [OC_time, Jitter_time, RC_time, R_time, EndTime]*10;

        teil = 1;
        Matrices.(Regions{teil}).matrix =[];
        Matrices.(Regions{teil}).trialMatrix =[];
        Matrices.(Regions{teil}).jitter = [];
        Matrices.(Regions{teil}).mirko_session = [];
        Matrices.(Regions{teil}).mouse = [""];
        Matrices.(Regions{teil}).events = XEvents;
        % Matrix creation loop:
        uu = 0;
        for u = 1:Mice
            
            diam = PVsmall.pupil(u).raw_trace;
            diam(diam == 0) = NaN;
            if ~isempty(diam) && ~all(isnan(diam))
                uu = uu+1;
                BinSize = .100; %Seconds
                diamTime = (1:numel(diam)).*BinSize;

                Session = PVsmall.events(u); Session = Session{1};
                Trials = size(Session, 2); % Compare with PVsmall.TrialMatrix(UnitIndex(u), :, :);
                TotalTime = Session(Trials).reward_time + 10;

                diamTime(diamTime>TotalTime) = [];
                diam(numel(diamTime)+1:end) = [];
                for tr = 1:Trials
                    % 2-second Baseline; 20 bins of .100s 
                    Bins1 = int64(Session(tr).fv_on_odorcue/BinSize-1) - 2/BinSize :int64(Session(tr).fv_on_odorcue/BinSize-1); Bins1 = Bins1(end-int64(2/BinSize)+1:end);
                    % CS1 plus 1.2 seconds; 24 bins of .100s
                    Bins2 = Bins1(end)+1 : Bins1(end)+1 + 2.4/BinSize; Bins2 = Bins2(1:int64(2.4/BinSize));
                    % 1.2s before CS2; 12 bins of .100s
                    Bins3 = int64(Session(tr).fv_on_rewcue/BinSize-1) - 2/BinSize :int64(Session(tr).fv_on_rewcue/BinSize-1); Bins3 = Bins3(end-int64(1.1/BinSize):end);
                    % CS2, Reward and 8s afrer Reward; 112 bins of .100s
                    Bins4 = Bins3(end)+1 : Bins3(end)+1 + int64(11.2/BinSize); Bins4 = Bins4(1:int64(11.2/BinSize));

                    Matrices.(Regions{teil}).matrix(uu, :, tr) = diam([Bins1, Bins2, Bins3, Bins4]);
                    Matrices.(Regions{teil}).jitter(uu, tr) = Session(tr).jitter_OC_RC;
                end
                Matrices.(Regions{teil}).mouse(uu, 1) = string(PVsmall.info(u).animal);
                % Create trial matrix;
                TM = NaN(1, 3, Trials);
                CS1 = [Session.curr_odorcue_odor_num];
                CS2 = [Session.curr_rewardcue_odor_num];
                US = [Session.drop_or_not];
                TM(1, 1, :) = CS1; TM(1, 2, :) = CS2; TM(1, 3, :) = US;
                Matrices.(Regions{teil}).trialMatrix(uu, :, :) = TM;
                Matrices.(Regions{teil}).mirko_session(uu, :, :) = mirko_session(u);
            end
        end
        save(Structure_directory + fileName, "Matrices");
    end  
end

