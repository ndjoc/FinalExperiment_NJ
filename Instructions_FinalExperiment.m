Screen('Preference', 'SkipSyncTests', 1)
myScreen = 0; 
window = Screen('OpenWindow', 0, [128 128 128], [0 0 640 416]); 
white = WhiteIndex(window);
Screen('TextSize', window, 30);
Screen('TextFont', window, 'Courier');
DrawFormattedText(window, 'Welcome to this Experiment', 'center', 'center', white);
Screen('Flip', window);
KbStrokeWait;
DrawFormattedText(window, 'You will listen to different tones', 'center', 'center', white);
Screen('Flip', window);
KbStrokeWait;
DrawFormattedText(window, 'There will not be any visual stimulation.', 'center', 'center', white);
Screen('Flip', window);
KbStrokeWait;
DrawFormattedText(window, 'Focus on the fixation-cross during each block.', 'center', 'center', white);
Screen('Flip', window);    
KbStrokeWait;
Screen('CloseAll');