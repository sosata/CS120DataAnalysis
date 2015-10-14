Instructions for using CS120DataAnalysis
========================================

1. Data Review

Step 1. Set the parameters in the config.m file:
	date_start: Start date (from 12:01am) of data review.
	date_end: End date (until 11:59pm) of data review.
	time_zone: Difference in hours with UTC.
	gap_max: Maximum gaps size allowed in seconds.
	data_dir: Location of data
	subjects_info: Location of subject_info file for the python script
Step 2. Run config.m
Step 3. Run evaluate_all.m

Results are written to 'log_matlab.txt' in the current directory.

To inspect and visualize data for each subject, run each of the following scrips:
	evaluate_activity.m
	evaluate_audio.m
	evaluate_communication.m
	evaluate_ema.m
	evaluate_light.m
	evaluate_screen.m
	evaluate_sleep.m
	evaluate_touch.m
using the following syntax:
	evaluate_xxx(<subject ID>, visualize)
where visualize is a boolean (1,0) determining whether the results are visualized or not.
