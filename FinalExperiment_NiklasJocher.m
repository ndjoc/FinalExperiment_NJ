%% Final Experiment 
%% Some Info on what's going on here
% It's an omission paradigm. You listen to pure tones and some (10%) are
% omitted. There are four tones (200, 431, 928 and 2000 Hz) at a sampling
% rate of 3 Hz. The priginal experiment had 8 blocks...I'll just use 4 and
% reduce the amount of stimuli per block to 800. 

%% Create Parameters (aka frequencies, number of blocks, stimuli per block etc)
Fs = 44100; toneDur = 0.1; 
freqs = [200, 431, 928, 2000];
toneISI = 1 / 3; %time between the onset of one tone and the onset of the next. since it's 3Hz -> 1/3
numBlocks = 4; %4 Blocks 
numStimuliPerBlock = 800; %with 800 stimuli each

%% Create the tones
samplesPerTone = round(toneDur * Fs);
tones = cellfun(@(f) sin(2 * pi * f * (0:samplesPerTone-1) / Fs), num2cell(freqs), 'UniformOutput', false);

%% Initialize PTB to actually play and display stuff and run the entire thing

InitializePsychSound;
pahandle = PsychPortAudio('Open', [], 1, 0, Fs, 1);
Screen('Preference', 'SkipSyncTests', 1);
[win, rect] = Screen('OpenWindow', 0, 128, [0 0 640 416]);
Screen('TextSize', win, 50);
xCenter = rect(3) / 2; yCenter = rect(4) / 2;

try
    for block = 1:numBlocks

        %Display a fixation cross (big plus)
        DrawFormattedText(win, '+', 'center', 'center', 255);
        Screen('Flip', win);

        % Randomized Tone sequence with omissions 
        seq = repelem(1:4, (1 - 0.1) * numStimuliPerBlock / 4);
        seq = [seq(randperm(numel(seq))), zeros(1, 0.1 * numStimuliPerBlock)];
        seq = seq(randperm(numel(seq)));

        % Play stimuli
        for s = seq
            if s > 0
                PsychPortAudio('FillBuffer', pahandle, tones{s});
                PsychPortAudio('Start', pahandle, 1, 0, 1);
                WaitSecs(toneDur); 
                PsychPortAudio('Stop', pahandle);
            end
            WaitSecs(toneISI - toneDur * (s > 0));
        end

        % Remove fixation cross between blocks
        Screen('Flip', win);
        fprintf('End of block %d. Press any key to continue.\n', block);
        KbWait;
    end
catch
    Screen('CloseAll');
    PsychPortAudio('Close', pahandle);
    rethrow;
end

% Close audio device and window
PsychPortAudio('Close', pahandle);
Screen('CloseAll');
