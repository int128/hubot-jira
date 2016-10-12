# hubot-jira-backlog

A Hubot script for creating backlogs on JIRA.


## How to use

Add the script into `scripts` of Hubot.

Add dependencies:

```sh
npm install --save request-promise bluebird
```

Set environment variables:

Key | Value | Example
----|-------|--------
JIRA_URL        | JIRA URL                    | `http://jira.example.com`
JIRA_USER       | JIRA user                   | `jira`
JIRA_PASSWORD   | JIRA password               | `jira`
JIRA_BACKLOG_ID | Issue type ID of backlogs   | `10001`
JIRA_SUBTASK_ID | Issue type ID of sub-tasks  | `10002`
