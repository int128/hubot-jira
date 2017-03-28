# Hubot script for JIRA

A Hubot script for notifying JIRA events and creating backlogs on JIRA.


## How to Use

Say below to create a backlog and each sub-tasks. `MINUTES` can be omitted.

```
@hubot create <JIRA_PROJECT> backlog <BACKLOG>,[<TASK><MINUTES>,]...
```

e.g.

```
@hubot create EXAMPLE backlog Customer can login to the portal,Design120,Implementation120,Test120
```

```
@hubot create EXAMPLE backlog Customer can login to the portal,Design,Implementation,Test
```

Say below to create a backlog without sub-tasks.

```
@hubot create <JIRA_PROJECT> backlog <BACKLOG>, - Create a backlog on JIRA
```

e.g.

```
@hubot create EXAMPLE backlog Bump version of dependencies,
```


## Install

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
BOT_CHANNEL_ID  | Channel ID                  | -
