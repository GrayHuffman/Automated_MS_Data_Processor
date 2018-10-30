%% QEQC: Automatic Report Generation
% Version 1
% Created: 5/7/18 (RGH)
% Updated: 8/30/18
    % auto-email if last entry in imported files contains today's date

global path
path =  'C:/Google_Drive/MS/';
addpath( genpath( [path 'bin/'] ) );

% Email Prefs
setpref('Internet','E_mail','QEQC.Reports@gmail.com');
setpref('Internet','SMTP_Server','smtp.gmail.com');
%setpref('Internet','E_mail','QEQC.Reports@gmail.com');
setpref('Internet','SMTP_Username','QEQC.Reports');
setpref('Internet','SMTP_Password','AutoMailer818');
props = java.lang.System.getProperties;
props.setProperty('mail.smtp.auth','true');
props.setProperty('mail.smtp.socketFactory.class', 'javax.net.ssl.SSLSocketFactory');
props.setProperty('mail.smtp.socketFactory.port','465');


% Establishing time range
timeFrame = QC_dates('One');
TodaysDate = [datestr((now), 'yymmdd')];
%TodaysDate = '180823_TwoWeeks'

% Generating QC plots
QEQC_viz(timeFrame, TodaysDate);

% Send e-mail report
recipients = {'nslavov@northeastern.edu' 'a.koller@northeastern.edu' 'chen.alb@husky.neu.edu' 'e.emmott@northeastern.edu' 'specht.h@husky.neu.edu' 'huffman.r@husky.neu.edu'}
%recipients = {'huffman.r@husky.neu.edu'}
if (contains(timeFrame(end), TodaysDate))
   sendmail(recipients,['QEQC Report:', TodaysDate],[ 'Good Morning!', char(10),char(10), ['A new QEQC Report is available at:',char(10) ,'https://web.northeastern.edu/slavov/qeqc/', TodaysDate, '/']]) ; 
end
