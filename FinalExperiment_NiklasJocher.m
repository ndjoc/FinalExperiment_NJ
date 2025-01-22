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
conditions = {'RR','OR', 'MM', 'MP'};

%% Create the tones
samplesPerTone = round(toneDur * Fs);
tones = cellfun(@(f) sin(2 * pi * f * (0:samplesPerTone-1) / Fs), num2cell(freqs), 'UniformOutput', false);

%% Define transition probabilities
transition.RR = [0.25, 0.25, 0.25, 0.25; 0.25, 0.25, 0.25, 0.25; 0.25, 0.25, 0.25, 0.25; 0.25, 0.25, 0.25, 0.25]
transition.OR = [0.25, 0.75, 0, 0; 0, 0.25, 0.75, 0; 0, 0, 0.25, 0.75; 0.75, 0, 0, 0.25];
transition.MM = [0.25, 0.38, 0.37, 0; 0, 0.25, 0.38, 0.37; 0.37, 0, 0.25, 0.38; 0.38, 0.37, 0, 0.25];
transition.MP = [0.25, 0.60, 0.15, 0; 0, 0.25, 0.60, 0.15; 0.15, 0, 0.25, 0.60; 0.60, 0.15, 0, 0.25];

%% Instructions for participants 
Screen('Preference', 'SkipSyncTests', 1);
[win, rect] = Screen('OpenWindow', 0, 128, [0 0 640 416]);
Screen('TextSize', win, 50);
xCenter = rect(3) / 2; yCenter = rect(4) / 2;

instructions = [ 
    'Welcome to our experiment.\n\n', ...
    'You will be listening to tones.\n\n', ...
    'Fixate your eyes on the fixation cross\n\n', ...
    'in the middle of the screen.\n\n', ...
    'Press any key to begin.' 
];  

% Text size and color: make color white 
Screen('TextSize', win, 24); 
textColor = [255, 255, 255];

% Show instructions on the screen 
DrawFormattedText(win, instructions, 'center', 'center', textColor);
Screen('Flip', win);

% participant can press a key to continue when done with reading the 
% instructions 
KbStrokeWait;
Screen('CloseAll') 
%% Initialize PTB to actually play and display stuff and run the entire thing

InitializePsychSound;
pahandle = PsychPortAudio('Open', [], 1, 0, Fs, 1);
Screen('Preference', 'SkipSyncTests', 1);
[win, rect] = Screen('OpenWindow', 0, 128, [0 0 640 416]);
Screen('TextSize', win, 50);
xCenter = rect(3) / 2; yCenter = rect(4) / 2;

try
    for block = 1:numBlocks
        % Randomly select a condition for the block
        condition = conditions{randi(length(conditions))};

        %Display a fixation cross (big plus)
        DrawFormattedText(win, '+', 'center', 'center', 255);
        Screen('Flip', win);

       % Generate stimulus sequence based on the transition matrix
        transMatrix = transition.(condition);
        seq = zeros(1, numStimuliPerBlock);
        seq(1) = randi(4); % Random start
        for i = 2:numStimuliPerBlock
            seq(i) = find(rand <= cumsum(transMatrix(seq(i-1), :)), 1);
        end

        % Play the tones
        for s = seq
            if s > 0
                PsychPortAudio('FillBuffer', pahandle, tones{s});
                PsychPortAudio('Start', pahandle, 1, 0, 1);
                WaitSecs(toneDur); PsychPortAudio('Stop', pahandle);
            end
            WaitSecs(toneISI - toneDur * (s > 0));
        end

        % Remove fixation cross between blocks
        Screen('Flip', win);
        fprintf('End of block %d. Press any key to continue.\n', block);
        KbStrokeWait;
    end
catch ME
    Screen('CloseAll');
    PsychPortAudio('Close', pahandle);
    rethrow(ME);
end

% Close audio device and window
PsychPortAudio('Close', pahandle);
Screen('CloseAll');
