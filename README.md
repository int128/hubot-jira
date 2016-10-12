# hubot-jira-backlog

A Hubot script for creating backlogs on JIRA.


## How to use

Add the script into `scripts` of Hubot.

Set environment variables:

Key | Value
----|------
JIRA_URL        | JIRA URL such as `http://jira.example.com`
JIRA_USER       | JIRA user
JIRA_PASSWORD   | JIRA password
JIRA_BACKLOG_ID | Type ID of backlogs such as `10001`
JIRA_SUBTASK_ID | Type ID of sub-tasks such as `10002`
