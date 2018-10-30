%% QEQC: Automatic Report Generation
% Version 1
% Created: 5/7/18 (RGH)
% Updated: 8/30/18
    % auto-email if last entry in imported files contains today's date
% Requires:
%   QEQC_viz.m
%   QEQC_vizHelper.m
%   QC_dates.m

    

global path
%Add the path to your data files here
path =  '____';
%Add the additional location of your dependent Matlab scripts
%Here it is assumed they are a subfolder in your initial path
addpath( genpath( [path '____'] ) );

% Email Prefs
%Insert the sending email address here
setpref('Internet','E_mail','_____');
setpref('Internet','SMTP_Server','smtp.gmail.com');
%setpref('Internet','E_mail','QEQC.Reports@gmail.com');
%Insert the username for your originating email address here
setpref('Internet','SMTP_Username','______');
%Insert the password for the originating email address here
setpref('Internet','SMTP_Password','______');
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
% Insert the recipient list for your automated report here
recipients = {'you@gmail.com'}

if (contains(timeFrame(end), TodaysDate))
   sendmail(recipients,['QEQC Report:', TodaysDate],[ 'Good Morning!', char(10),char(10), ['A new QC Report is available!']]) ; 
end
